`%notin%` <- Negate(`%in%`)

#' @title Find Unlinked Packages
#' @importFrom fs dir_info path_file
#' @importFrom dplyr filter pull
find_unlinked_packages <- function(lib_path) {
  fs::dir_info(lib_path) |>
    dplyr::filter(type == "directory") |>
    dplyr::filter(fs::path_file(path) != "_cache") |>
    dplyr::pull(path)
}

#' @title Hash a single package
#' @importFrom fs dir_info
#' @importFrom dplyr filter pull
#' @importFrom purrr map
#' @importFrom digest digest
hash_fun <- function(package) {
  files <- fs::dir_info(package, recurse = TRUE) |>
    dplyr::filter(type == "file") |>
    dplyr::pull(path)
  hashlist <- purrr::map(.x  = files,
                         .f = \(x) digest::digest(
                           object = x,
                           algo = "md5",
                           file = TRUE
                         ))
  digest::digest(object = hashlist, algo = "md5")
}


#' @title get all package dependencies
#' @importFrom fs path
#' @importFrom tibble as_tibble
#' @importFrom dplyr mutate
#' @importFrom stringr str_split str_remove_all
get_all_deps <- function(package) {
  package_desc <- fs::path(package, "DESCRIPTION")
  desc <- read.dcf(package_desc)
  desc <- tibble::as_tibble(desc)
  if ("Depends" %notin% colnames(desc))
    desc <- dplyr::mutate(desc, Depends = "")
  if ("Imports" %notin% colnames(desc))
    desc <- dplyr::mutate(desc, Imports = "")
  deps <- c(desc[, "Imports"], desc[, "Depends"]) |>
    stringr::str_split(pattern = ",") |>
    unlist() |>
    stringr::str_remove_all(" ") |>
    stringr::str_remove_all("\\n") |>
    stringr::str_remove_all("\\(.*\\)")
  deps <- deps[deps != "R"]
  deps <- deps[deps != ""]
  deps
}

get_version <- function(path) {
  desc <- read.dcf(fs::path(path, "DESCRIPTION"))
  desc[, "Version"]
}

#' @title  cache a single package
#' @importFrom tibble tibble
#' @importFrom fs path path_file dir_exists dir_copy dir_delete link_create
#' @importFrom cli cli_div cli_alert_info
cache_fun <-
  function(package,
           cache_loc = fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"), "library"),
           permissions) {
    cli::cli_div(theme = list(span.emph = list(color = "orange")))
    catch_blasertemplates_root()
    name <- fs::path_file(package)
    version <- get_version(package)
    hash <- hash_fun(package)
    to <- fs::path(cache_loc, name, version, hash, name)
    if (fs::dir_exists(to)) {
      cli::cli_alert_info("An identical version of {.emph {name}} is already cached.")
      fs::dir_delete(package)
      fs::link_create(path = to, new_path = package)

    } else {
      fs::dir_copy(path = package,
                   new_path = to,
                   overwrite = FALSE)
      fs::dir_delete(package)
      fs::link_create(path = to, new_path = package)
      # make sure the new entry has permissions 777
      newfiles <- fs::dir_info(fs::path(cache_loc, name, version, hash, name), recurse = TRUE)
      fs::file_chmod(newfiles$path, mode = permissions)
    }




  }

#' @title rewrite/update the package catalog
#' @importFrom fs dir_info path_file path_dir path
#' @importFrom dplyr anti_join select mutate
#' @importFrom readr write_tsv
update_package_catalog <-
  function() {
    catch_blasertemplates_root()
    cache_loc <- Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")
    lib_path <- fs::path(cache_loc, "library")
    package_paths <- fs::dir_ls(lib_path,
                                recurse = 2)[fs::dir_ls(lib_path,
                                                        recurse = 2) %notin% fs::dir_ls(lib_path,
                                                                                        recurse = 1)]

    fs::dir_info(package_paths, recurse = FALSE) |>
      dplyr::select(path, birth_time) |>
      dplyr::mutate(hash = fs::path_file(fs::path_dir(path))) |>
      dplyr::mutate(version = as.package_version(fs::path_file(fs::path_dir(
        fs::path_dir(path)
      )))) |>
      dplyr::mutate(name = fs::path_file(fs::path_dir(fs::path_dir(
        fs::path_dir(path)
      )))) |>
      dplyr::mutate(R_version = paste0(R.version$major, ".", R.version$minor)) |>
      dplyr::select(R_version,
                    name,
                    version,
                    date_time = birth_time,
                    hash,
                    binary_location = path) |>
      readr::write_tsv(file = fs::path(cache_loc, "package_catalog.tsv"))


  }

#' @title update the dependency catalog
#' @importFrom purrr map_dfr
#' @importFrom fs path_dir dir_ls path path_file
#' @importFrom tibble tibble
#' @importFrom readr write_tsv
update_dependency_catalog <-
  function() {
    catch_blasertemplates_root()
    cache_loc <- Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")
    purrr::map_dfr(.x = fs::path_dir(
      fs::dir_ls(
        path = fs::path(cache_loc, "library"),
        recurse = 4,
        regexp = "DESCRIPTION"
      )
    ),
    .f = \(x) {
      dependencies <- get_all_deps(x)
      name <- fs::path_file(x)
      hashes <- fs::path_file(fs::path_dir(x))
      tibble::tibble(name = name,
                     hashes = hashes,
                     dependencies = dependencies)
    }) |> readr::write_tsv(file = fs::path(cache_loc, "dependency_catalog.tsv"))

  }





#' @title Make sure you are in a properly-formatted blaseRtemplates project.
#' @importFrom cli cli_abort
catch_blasertemplates_root <- function() {
  if (Sys.getenv("BLASERTEMPLATES_CACHE_ROOT") == "")
    cli::cli_abort(c("x" = "BLASERTEMPLATES_CACHE_ROOT must be set to use this function."))
}

#' @title hash one or more functions and then cache them and update the catalogs.  Default permissions are set to 777.
#' @importFrom fs path
#' @importFrom purrr walk
#' @export
hash_n_cache <- function(lib_loc = .libPaths()[1],
                         cache_loc = fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"), "library"),
                         verbose = TRUE,
                         permissions = "777") {
  catch_blasertemplates_root()
  packages <- find_unlinked_packages(lib_path = lib_loc)

  if (length(packages) > 0) {
    cli::cli_alert_info("Cacheing {length(packages)} package(s).")

  } else {
    if (verbose) cli::cli_alert_info("The library is cached.")
  }
  purrr::walk(.x = packages,
              .f = \(x, loc = cache_loc, perm = permissions) {
                cache_fun(package = x, cache_loc = loc, permissions = perm)
              })
  update_package_catalog()
  update_dependency_catalog()
  cli::cli_alert_success("Done.")
}



#' @title Write A New Project Library Catalog
#' @description In the current version of blaseRtemplates, the package library is cached at the location designated by the environment variable "BLASERTEMPLATES_CACHE_ROOT".  There is a single cache for all users and projects.  The cache holds the binary software used by each package.  The packages for each project are connected to the cache by symlinks. The cache is versioned so that different projects can use different versions if desired.  Use this function to write a tab-delimited file listing the packages used by each project.
#'
#' This file will be written to the "library_catalogs" directory within each project.  The filename incorporates the user name so everyone working on the project will have their own.  Use `get_new_library()` to adopt a new version of all packages

#' @return returns nothing
#' @rdname write_project_library_catalog
#' @export
#' @importFrom fs path path_file dir_ls is_link link_path path_dir dir_create
#' @importFrom usethis proj_get
#' @importFrom purrr map_dfr
#' @importFrom tibble tibble
#' @importFrom dplyr mutate transmute pull filter case_when
#' @importFrom renv dependencies
#' @importFrom readr read_tsv cols write_tsv
write_project_library_catalog <-
  function() {
    catch_blasertemplates_root()
    hash_n_cache()
    lib_loc <- .libPaths()[1]
    cache_loc <- fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"))
    user <- Sys.info()[["user"]]
    project <- fs::path_file(usethis::proj_get())
    lib_pkg_hashes <- purrr::map_dfr(.x = fs::dir_ls(lib_loc),
                                     .f = \(x) {
                                       x <- x[fs::is_link(x)]
                                       tibble::tibble(path = fs::link_path(x))
                                     }) |>
      dplyr::mutate(path1 = fs::path_dir(path)) |>
      dplyr::transmute(hash = fs::path_file(path1))

    active_pkgs <- renv::dependencies() |>
      dplyr::pull(Package)

    fs::dir_create("library_catalogs")

    readr::read_tsv(fs::path(cache_loc, "package_catalog.tsv"),
                    col_types = readr::cols()) |>
      dplyr::mutate(version = as.package_version(version)) |>
      dplyr::filter(hash %in% lib_pkg_hashes$hash) |>
      dplyr::mutate(
        status = dplyr::case_when(
          name %in% active_pkgs ~ "active",
          name %in% rownames(installed.packages(priority =
                                                  "base")) ~ "base",
          TRUE ~ "available"
        )
      ) |>
      readr::write_tsv(fs::path("library_catalogs", paste0(user, "_", project), ext = "tsv"))
  }

#' @title recursively get package dependencies
#' @importFrom fs path
#' @importFrom readr read_tsv cols
#' @importFrom dplyr filter pull
rec_get_deps <-
  function(needed,
           checked = character(0),
           deps = character(0),
           catalog = fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
                              "dependency_catalog.tsv")) {
    # base case
    catalog <- readr::read_tsv(catalog, col_types = readr::cols())
    if (length(deps) == 0) {
      deps <- dplyr::filter(catalog, name == needed) |>
        dplyr::pull(dependencies)
      needed <- deps
    }

    # exit case
    if (length(needed) == 0) {
      deps <- unique(deps)
      return(deps)
    }

    # recursive case
    new_deps <- dplyr::filter(catalog, name %in% needed) |>
      dplyr::pull(dependencies)
    deps <- c(deps, new_deps)
    checked <- needed
    needed <- new_deps[new_deps %notin% checked]
    rec_get_deps(
      needed = needed,
      checked = checked,
      deps = deps,
      catalog = fs::path(
        Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
        "dependency_catalog.tsv"
      )
    )

  }


#' @title Get A New Project Library
#' @description Use this to replace the current symlinked library with a new version.  By default, the function will link to the newest version of all packages available in the cache.  Alternatively, identify another project library catalog to replace the current version.
#' @param newest_or_file Which set of packages to symlink, Default: 'newest'
#' @return Uninstalled packages hashes.
#' @rdname get_new_library
#' @export
#' @importFrom fs path link_create
#' @importFrom readr read_tsv cols
#' @importFrom cli cli_alert_info cli_alert_warning cli_alert_success
#' @importFrom dplyr group_by arrange slice_head select filter
#' @importFrom purrr walk2
get_new_library <- function(newest_or_file = "newest") {
  catch_blasertemplates_root()
  # make sure the library is hashed
  hash_n_cache(verbose = FALSE)
  failed_all <-
    tibble::tibble(name = character(0), version = character(0))


  cache_catalog <-
    fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
             "package_catalog.tsv")
  project_library <- .libPaths()[1]
  # load the catalog
  pkg_cat <-
    readr::read_tsv(cache_catalog, col_types = readr::cols())

  # get the list of paths to link to
  if (newest_or_file == "newest") {
    cli::cli_alert_info("Linking to the newest versions of all available packages.")
    from <- pkg_cat |>
      dplyr::group_by(name) |>
      dplyr::arrange(desc(version), desc(date_time), .by_group = TRUE) |>
      dplyr::slice_head(n = 1) |>
      dplyr::select(binary_location, name)
    cant_install <- tibble::tibble(name = character(0), version = character(0), status = character(0))
  } else {
    cli::cli_alert_info("Attempting to link to cached packages from the provided file.")
    to_install <-
      readr::read_tsv(newest_or_file, col_types = readr::cols()) |>
      dplyr::select(name, version, status)
    cant_install <-
      dplyr::anti_join(to_install, pkg_cat, by = c("name", "version"))

    from <- pkg_cat |>
      dplyr::filter(name %in% to_install$name) |>
      dplyr::filter(version %in% to_install$version) |>
      dplyr::group_by(name) |>
      dplyr::arrange(desc(date_time), .by_group = TRUE) |>
      dplyr::slice_head(n = 1) |>
      dplyr::select(binary_location, name)
  }

    purrr::walk2(.x = from$binary_location,
                 .y = from$name,
                 .f = \(x, y, proj_lib = project_library) {
                   # first delete the exisitng link
                   if (fs::link_exists(fs::path(project_library, y)))
                     fs::link_delete(fs::path(project_library, y))

                   # now create the new link
                   fs::link_create(path = x,
                                   new_path = fs::path(project_library, y))
                 })

    if (nrow(cant_install) > 0) {
      cli::cli_alert_warning(
        '{nrow(cant_install)} packages could not be found in the catalog.\nOf these, only {nrow(dplyr::filter(cant_install, status == "active"))} are actively used by the project.\nYou can install all packages or only the active packages'
      )
      answer <-
        menu(c("active only", "all"), title = "How do you wish to proceed?")
      if (answer == 1)
        cant_install <-
        dplyr::filter(cant_install, status == "active")
      cli::cli_alert_info("Attempting to install these packages from the accessible repositories.")
      failed_cran <- purrr::map2_dfr(.x = cant_install$name,
                                     .y = cant_install$version,
                                     .f = \(x, y) {
                                       tryCatch(
                                         expr = pak_plus(pkg = x, ver = y),
                                         error = function(cond)
                                           return(tibble::tibble(
                                             name = x, version = y
                                           ))
                                       )

                                     })
      failed_cran <- filter(failed_cran, !is.na(name))
      if (nrow(failed_cran) > 0) {
        failed_all <-
          purrr::map2_dfr(
            .x = paste0("bioc::", failed_cran$name),
            .y = failed_cran$version,
            .f = \(x, y) {
              tryCatch(
                expr = pak_plus(pkg = x, ver = NULL),
                error = function(cond)
                  return(tibble::tibble(
                    name = stringr::str_remove(x, "bioc::"),
                    version = y
                  ))
              )
            }
          )

      }
    }


  hash_n_cache(verbose = FALSE)
  write_project_library_catalog()
  if (nrow(failed_all) > 0) {
    dt_stamp <- stringr::str_remove_all(Sys.time(), "\\D")
    cli::cli_alert_info(
      "{nrow(failed_all)} package(s) could not be installed.  Writing these to library_catalogs/uninstalled_packages_{dt_stamp}.tsv"
    )
    readr::write_tsv(
      failed_all,
      file = fs::path(
        "library_catalogs",
        paste0("uninstalled_packages_",
        dt_stamp,
        ".tsv")
      )
    )

  } else {
    cli::cli_alert_success("Success!")

  }


}


#' @title link one new package
#' @importFrom cli cli_div cli_alert_warning cli_alert_danger cli_alert_info cli_abort
#' @importFrom readr read_tsv cols
#' @importFrom fs path link_exists link_delete link_create
#' @importFrom pak pkg_install
#' @importFrom dplyr filter pull arrange slice_head
link_one_new_package <- function(package,
                                 version = NULL,
                                 hash = NULL) {
  ver <- version
  cli::cli_div(theme = list(span.emph = list(color = "orange")))
  catch_blasertemplates_root()
  if (length(package) != 1)
    cli::cli_abort("You can only install 1 package at a time with this function.")
  stopifnot(
    "You can only supply version OR hash identifiers but not both." = is.null(version) |
      is.null(hash)
  )
  project_library <- .libPaths()[1]

  # first check to be sure the package exists in the cache
  # if not, then install it from the repository
  pkg_cat <-
    readr::read_tsv(fs::path(
      Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
      "package_catalog.tsv"
    ),
    col_types = readr::cols())
  ok <- package %in% pkg_cat$name

  if (!ok) {
    cli::cli_alert_warning("{.emph {package}} is not in your cache.\nAttempting a new installation ")
    tryCatch({
      pak_plus(pkg = package, ver = version)
      hash_n_cache()

    }, error = function(cond) {
      cli::cli_alert_danger("{.emph {package}} could not be installed.")
    })

  } else {
    method <- "install.specific"
    if (!is.null(ver)) {
      available_versions <- pkg_cat |>
        dplyr::filter(name == package) |>
        dplyr::pull(version)

      ok <- ver %in% available_versions

      if (!ok) {
        cli::cli_alert_warning("The requested version of {.emph {package}} is not available in the cache.")
        method <- "install.latest"

      } else {
        cli::cli_alert_info("Linking to {.emph {package}} version: {.emph {version}}.")

        hash_to_link <- pkg_cat |>
          dplyr::filter(name == package) |>
          dplyr::filter(version == ver) |>
          dplyr::arrange(desc(date_time)) |>
          dplyr::slice_head(n = 1) |>
          dplyr::pull(hash)

      }

    } else if (!is.null(hash)) {
      ok <- hash %in% pkg_cat$hash

      if (!ok) {
        cli::cli_alert_warning("The requested hash of {.emph {package}} is not available.")
        method <- "install.latest"

      } else {
        cli::cli_alert_info("Linking to {.emph {package}} hash: {.emph {hash}}")
        hash_to_link <- hash
      }

    } else {
      method <- "install.latest"
    }

    if (method == "install.latest") {
      cli::cli_alert_info(
        "Linking to newest available version of {.emph {package}} in the {.emph binary} cache."
      )
      hash_to_link <- pkg_cat |>
        dplyr::filter(name == package) |>
        dplyr::arrange(desc(date_time)) |>
        dplyr::slice_head(n = 1) |>
        dplyr::pull(hash)


    }
    path_to_link <- pkg_cat |>
      dplyr::filter(hash == hash_to_link) |>
      dplyr::pull(binary_location)

    version <- pkg_cat |>
      dplyr::filter(hash == hash_to_link) |>
      dplyr::pull(version)

    if (fs::link_exists(fs::path(.libPaths()[1], package)))
      fs::link_delete(fs::path(.libPaths()[1], package))
    fs::link_create(path = path_to_link,
                    new_path = fs::path(.libPaths()[1], package))
    link_deps(package = package)
  cli::cli_alert_success(
    "Successfully linked to {.emph {package}} version {.emph {version}} and its recursive dependencies in the binary cache."
  )

  }
}

#' @title link package dependencies
#' @importFrom readr read_tsv cols
#' @importFrom fs path path_file path_dir link_exists link_delete link_create
#' @importFrom dplyr filter group_by arrange slice_head pull
#' @importFrom purrr walk2
#' @importFrom cli cli_alert_info
link_deps <- function(package) {
  deps <- rec_get_deps(needed = package)
  dep_paths <-
    readr::read_tsv(fs::path(
      Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
      "package_catalog.tsv"
    ),
    col_types = readr::cols()) |>
    dplyr::filter(name %in% deps) |>
    dplyr::group_by(name) |>
    dplyr::arrange(desc(date_time)) |>
    dplyr::slice_head(n = 1) |>
    dplyr::pull(binary_location)
  dep_path_names <-
    fs::path_file(fs::path_dir(fs::path_dir(fs::path_dir(dep_paths))))
  purrr::walk2(.x = dep_paths,
               .y = dep_path_names,
               .f = \(x, y) {
                 if (fs::link_exists(fs::path(.libPaths()[1], y)))
                   fs::link_delete(fs::path(.libPaths()[1], y))
                 cli::cli_alert_info("Linking to newest available version of {.emph {y}} in the {.emph binary} cache.")
                 fs::link_create(path = x,
                                 new_path = fs::path(.libPaths()[1], y))
               })
}

#' @importFrom cli cli_alert_warning
#' @importFrom pak pkg_install
#' @importFrom stringr str_detect
pak_plus <- function(pkg, ver) {
  # check if bioc
  bioc <- stringr::str_detect(pkg, "bioc")
  if (bioc & !is.null(ver)) {
    cli::cli_alert_warning("Installing versioned bioconductor packages is not supported.")
    pak::pkg_install(pkg, ask = FALSE, upgrade = TRUE)
  } else if (bioc & is.null(ver)) {
    pak::pkg_install(pkg, ask = FALSE, upgrade = TRUE)
  } else if (!is.null(ver)) {
    install_string <- paste0("cran/", pkg, "@", ver)
    tryCatch(
      expr = pak::pkg_install(install_string, ask = FALSE, upgrade = TRUE),
      error = function(cond) {
        cli::cli_alert_warning("The requested version of {.emph {pkg}} is not available on CRAN.")
        cli::cli_alert_warning("Attempting to install the latest version.")
        pak::pkg_install(pkg, ask = FALSE, upgrade = TRUE)
      }
    )

  } else {
    pak::pkg_install(pkg, ask = FALSE, upgrade = TRUE)
  }

}

#' @title Install One Package
#' @description Use this to install a new package.  Choosing "new_or_update" will go to the package repository, get the latest version of the software, install into your cache and link to your project library.  Choosing "link_from_cache" will get you the latest version in the cache Also, use this option with either "which_version" or "which_hash" to install specific versions.
#' @param package Package name or path to tarball.  Prefix with "repo\/" for github source packages and "bioc::" for bioconductor.
#' @param which_version Package version to install, Default: NULL
#' @param which_hash Package hash to install, Default: NULL
#' @param how How to install the package, Default: c("link_from_cache", "new_or_update", "tarball")
#' @return nothing
#' @rdname install_one_package
#' @export
#' @importFrom cli cli_div cli_alert_info cli_alert_success
#' @importFrom stringr str_detect str_replace
#' @importFrom pak pkg_install
install_one_package <-
  function(package,
           how = c("link_from_cache", "new_or_update", "tarball"),
           which_version = NULL,
           which_hash = NULL) {
    permissions <- "777"
    cli::cli_div(theme = list(span.emph = list(color = "orange")))
    catch_blasertemplates_root()
    how <- match.arg(how)
    if (stringr::str_detect(package, "\\.tar\\.gz")) {
      cli::cli_alert_info("Installing tarball")
      pak::pkg_install(package, ask = FALSE)
      hash_n_cache(permissions = permissions)
    } else {
      package_name <-
        stringr::str_replace(package, "bioc::|.*/", "")

      if (how == "new_or_update") {
        pak_plus(pkg = package, ver = which_version)
        hash_n_cache(permissions = permissions)
      } else if (how == "link_from_cache") {
        link_one_new_package(package = package_name,
                             version = which_version,
                             hash = which_hash)
        # link_deps(package = package_name)
      } else if (how == "tarball") {
        stop("You must supply a valid path to the tarball file.")

      }

    }


  }

