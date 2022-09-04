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
      .f = \(x) digest::digest(object = x, algo = "md5", file = TRUE)
      )
  digest::digest(object = hashlist, algo = "md5")
}


#' @title get all package dependencies
#' @importFrom tibble as_tibble
#' @importFrom dplyr mutate
#' @importFrom fs path
#' @importFrom stringr str_split str_remove_all
get_all_deps <- function(package) {
  package_desc <- fs::path(package, "DESCRIPTION")
  desc <- read.dcf(package_desc)
  desc <- tibble::as_tibble(desc)
  if("Depends" %notin% colnames(desc))
    desc <- dplyr::mutate(desc, Depends = "")
  if("Imports" %notin% colnames(desc))
    desc <- dplyr::mutate(desc, Imports = "")
  deps <- c(desc[,"Imports"], desc[,"Depends"]) |>
    stringr::str_split(pattern = ",") |>
    unlist() |>
    stringr::str_remove_all(" ") |>
    stringr::str_remove_all("\\n") |>
    stringr::str_remove_all("\\(.*\\)")
  deps <- deps[deps != "R"]
  deps <- deps[deps != ""]
  deps
}


#' @title cache a sinlge package
#' @importFrom cli cli_div cli_alert_info
#' @importFrom fs path_file path dir_exists dir_copy dir_delete link_create
#' @importFrom tibble tibble
cache_fun <-
  function(package,
           cache_loc = fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"), "library")) {
    cli::cli_div(theme = list(span.emph = list(color = "orange")))
    catch_blasertemplates_root()
    name <- fs::path_file(package)
    version <- packageVersion(name)
    hash <- hash_fun(package)
    to <- fs::path(cache_loc, name, version, hash, name)
    if (fs::dir_exists(to)) {
      cli::cli_alert_info("An identical version of {.emph {name}} is already cached.")
    } else {
      fs::dir_copy(path = package,
                   new_path = to,
                   overwrite = FALSE)
      fs::dir_delete(package)
      fs::link_create(path = to, new_path = package)
    }

    deps <- get_all_deps(package)

    dep_tbl <-
      tibble::tibble(hashes = hash,
                     name = name,
                     dependencies = deps)
    return(dep_tbl)

  }


#' @title update the package catalog
#' @importFrom fs path file_exists
#' @importFrom readr read_tsv write_tsv
#' @importFrom dplyr bind_rows group_by arrange slice_head ungroup
update_package_catalog <-
  function() {
    catch_blasertemplates_root()
    cache_loc <- Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")
    fs::dir_info("/workspace/rst/cache_R_4_2/library", recurse = 3) |>
      dplyr::anti_join(
        fs::dir_info("/workspace/rst/cache_R_4_2/library", recurse = 2),
        by = c(
          "path",
          "type",
          "size",
          "permissions",
          "modification_time",
          "user",
          "group",
          "device_id",
          "hard_links",
          "special_device_id",
          "inode",
          "block_size",
          "blocks",
          "flags",
          "generation",
          "access_time",
          "change_time",
          "birth_time"
        )
      ) |>
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
#' @importFrom fs path file_exists
#' @importFrom readr read_tsv write_tsv
#' @importFrom dplyr bind_rows distinct
update_dependency_catalog <-
  function(dep_update) {
    catch_blasertemplates_root()
    cache_loc <- Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")
    dep_cat <- fs::path(cache_loc, "dependency_catalog.tsv")
    if (fs::file_exists(dep_cat)) {
      readr::read_tsv(dep_cat, col_types = readr::cols()) |>
        dplyr::bind_rows(dep_update) |>
        dplyr::distinct() |>
        readr::write_tsv(fs::path(cache_loc, "dependency_catalog.tsv"))

    } else {
      readr::write_tsv(dep_update,
                       file = fs::path(cache_loc, "dependency_catalog.tsv"))
    }
  }


catch_blasertemplates_root <- function() {
  if (Sys.getenv("BLASERTEMPLATES_CACHE_ROOT") == "")
    cli::cli_abort(c("x" = "BLASERTEMPLATES_CACHE_ROOT must be set to use this function."))
}

#' @title hash one or more functions and then cache them and update the catalogs
#' @importFrom purrr map_dfr
hash_n_cache <- function() {
  catch_blasertemplates_root()
  lib_loc <- .libPaths()[1]
  cache_loc <- fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"), "library")
  packages <- find_unlinked_packages(lib_path = lib_loc)
  if (length(packages) > 1) {
    pkg_dep <- purrr::map_dfr(.x = packages,
                              .f = \(x, loc = cache_loc) {
                                cache_fun(package = x, loc)
                              })
  } else {
    pkg_dep <- cache_fun(package = packages, cache_loc)
  }
  update_package_catalog()
  update_dependency_catalog(dep_update = pkg_dep)
}


#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param lib_loc PARAM_DESCRIPTION, Default: cache_paths$user_project
#' @param cache_loc PARAM_DESCRIPTION, Default: cache_paths$library
#' @param user PARAM_DESCRIPTION, Default: Sys.getenv()[["USER"]]
#' @param project PARAM_DESCRIPTION, Default: fs::path_file(usethis::proj_get())
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso
#'  \code{\link[fs]{path_file}}, \code{\link[fs]{dir_ls}}, \code{\link[fs]{is_file}}, \code{\link[fs]{link_path}}, \code{\link[fs]{create}}, \code{\link[fs]{path}}
#'  \code{\link[usethis]{proj_utils}}
#'  \code{\link[purrr]{map}}
#'  \code{\link[tibble]{tibble}}
#'  \code{\link[dplyr]{mutate}}, \code{\link[dplyr]{pull}}, \code{\link[dplyr]{filter}}, \code{\link[dplyr]{case_when}}
#'  \code{\link[renv]{dependencies}}
#'  \code{\link[readr]{read_delim}}, \code{\link[readr]{write_delim}}
#' @rdname write_project_library_catalog
#' @export
#' @importFrom fs path_file dir_ls is_link link_path path_dir dir_create path
#' @importFrom usethis proj_get
#' @importFrom purrr map_dfr
#' @importFrom tibble tibble
#' @importFrom dplyr mutate transmute pull filter case_when
#' @importFrom renv dependencies
#' @importFrom readr read_tsv write_tsv
write_project_library_catalog <-
  function() {
    catch_blasertemplates_root()
    lib_loc <- .libPaths()[1]
    cache_loc <- fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"))
    user <- Sys.getenv()[["USER"]]
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

    readr::read_tsv(fs::path(cache_loc, "package_catalog.tsv"), col_types = readr::cols()) |>
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

# recursively get package dependencies

rec_get_deps <-
  function(needed,
           checked = character(0),
           deps = character(0),
           catalog = fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"), "dependency_catalog.tsv")) {
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
      catalog = fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"), "dependency_catalog.tsv")
    )

  }
#' @export
get_new_library <- function(newest_or_hashes = "newest") {
  catch_blasertemplates_root()
  cache_catalog <- fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"), "package_catalog.tsv")
  project_library <- .libPaths()[1]
  # load the catalog
  pkg_cat <- readr::read_tsv(cache_catalog, col_types = readr::cols())

  # get the list of paths to link to

  if (newest_or_hashes == "newest") {
    cli::cli_alert_info("Linking to the newest versions of all available packages.")
    from <- pkg_cat |>
      dplyr::group_by(name) |>
      dplyr::arrange(version, date_time, .by_group = TRUE) |>
      dplyr::slice_head(n = 1) |>
      dplyr::select(binary_location, name)
    cant_install <- 0
  } else {
    cli::cli_alert_info("Attempting to link to cached packages with the provided hashes.")
    cant_install <- sum(newest_or_hashes %notin% pkg_cat$hash)
    not_installed <-
      newest_or_hashes[newest_or_hashes %notin% pkg_cat$hash]
    from <- pkg_cat |>
      dplyr::filter(hash %in% newest_or_hashes) |>
      dplyr::select(binary_location, name)

  }

  purrr::walk2(.x = from$binary_location,
        .y = from$name,
        .f = \(x, y, proj_lib = project_library) {
          fs::link_create(path = x,
                          new_path = fs::path(project_library, y))
        })

  if (cant_install > 0) {
    cli::cli_alert_warning(
      paste0(
        cant_install,
        " hashes could not be found in the cache catalog and may be invalid."
      )
    )
    return(not_installed)
  } else {
    cli::cli_alert_success("Success!")
  }

}

link_one_new_package <- function(package,
                             version = NULL,
                             hash = NULL) {
  cli::cli_div(theme = list(span.emph = list(color = "orange")))
  catch_blasertemplates_root()
  stopifnot("You can only install 1 package at a time with this function." = length(package) == 1)
  stopifnot(
    "You can only supply version OR hash identifiers but not both." = is.null(version) |
      is.null(hash)
  )
  project_library <- .libPaths()[1]

  # first check to be sure the package exists in the cache
  # if not, then install it from the repository
  pkg_cat <-
    readr::read_tsv(fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"), "package_catalog.tsv"), col_types = readr::cols())
  ok <- package %in% pkg_cat$name

  if (!ok) {
    cli::cli_alert_warning("{.emph {package}} is not in your cache.\nAttempting a new installation ")
    tryCatch({
      pak::pkg_install(package, ask = FALSE)
      hash_n_cache()

    }, error = function(cond) {
      cli::cli_alert_danger("{.emph {package}} could not be installed.")
    })

  } else {
    method <- "install.specific"
    if (!is.null(version)) {
      available_versions <- pkg_cat |>
        dplyr::filter(name == package) |>
        dplyr::pull(version)

      ok <- version %in% available_versions

      if (!ok) {
        cli::cli_alert_warning("The requested package is not available.")
        method <- "install.latest"

      } else {
        cli::cli_alert_info("Linking to {.emph {package}} version: {.emph {version}}.")
        hash_to_link <- pkg_cat |>
          dplyr::filter(name == package,
                        version == version) |>
          dplyr::arrange(desc(date_time)) |>
          dplyr::slice_head(n = 1) |>
          dplyr::pull(hash)

      }

    } else if (!is.null(hash)) {
      ok <- hash %in% pkg_cat$hash

      if (!ok) {
        cli::cli_alert_warning("The requested package is not available.")
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

    if(fs::link_exists(fs::path(.libPaths()[1], package)))
      fs::link_delete(fs::path(.libPaths()[1], package))
    fs::link_create(path = path_to_link,
                    new_path = fs::path(.libPaths()[1], package))

  }
}

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


#' @title Install One Package
#' @description FUNCTION_DESCRIPTION
#' @param package PARAM_DESCRIPTION
#' @param which_version PARAM_DESCRIPTION, Default: NULL
#' @param which_hash PARAM_DESCRIPTION, Default: NULL
#' @param how PARAM_DESCRIPTION, Default: c("ask", "new_or_update", "link_from_cache", "tarball")
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso
#'  \code{\link[cli]{cli_div}}, \code{\link[cli]{cli_alert}}
#'  \code{\link[stringr]{str_detect}}, \code{\link[stringr]{str_replace}}
#'  \code{\link[pak]{pkg_install}}
#' @rdname install_one_package
#' @export
#' @importFrom cli cli_div cli_alert_info cli_alert_success
#' @importFrom stringr str_detect str_replace
#' @importFrom pak pkg_install
install_one_package <-
  function(package,
           which_version = NULL,
           which_hash = NULL,
           how = c("ask", "new_or_update", "link_from_cache", "tarball")) {
    cli::cli_div(theme = list(span.emph = list(color = "orange")))
    catch_blasertemplates_root()
    how <- match.arg(how)
    if (stringr::str_detect(package, "\\.tar\\.gz")) {
      cli::cli_alert_info("Installing tarball")
      pak::pkg_install(package)
      hash_n_cache()
    } else {
      package_name <-
        stringr::str_replace(package, "bioc::|.*/", "")

      if (how == "ask") {
        cat("Do you want to update or install a new package from a repository?\n")
        cat("Or do you want to link to a new version in the package cache?\n")
        cat("Linking is faster if the package is available\n")
        answer <-
          menu(c("New/Update", "Link from cache"), title = "How do you wish to proceed?")

        if (answer == 1) {
          pak::pkg_install(package, ask = FALSE)
          hash_n_cache()
        } else {
          link_one_new_package(package = package_name, version = which_version, hash = which_hash)
          link_deps(package = package_name)
          cli::cli_alert_success("Successfully linked to {.emph {package}} and its recursive dependencies in the binary cache.")
        }
      } else if (how == "new_or_update") {
        pak::pkg_install(package, ask = FALSE)
        hash_n_cache()
      } else if (how == "link_from_cache") {
        link_one_new_package(package = package_name, version = which_version, hash = which_hash)
        link_deps(package = package_name)
        cli::cli_alert_success("Successfully linked to {.emph {package}} and its recursive dependencies in the binary cache.")
      } else if (how == "tarball") {
        stop("You must supply a valid path to the tarball file.")

      }

    }


  }



