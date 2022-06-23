#' @title Easily Initiate an renv Project
#' @description Behave similarly to renv::init but instead of downloading and building everything, will first attempt to link to the latest versions of packages available in your cache.
#' @return Nothing
#' @seealso
#'  \code{\link[renv]{init}}, \code{\link[renv]{dependencies}}
#'  \code{\link[purrr]{map}}, \code{\link[purrr]{safely}}
#' @rdname easy_init
#' @export
#' @importFrom usethis proj_get
#' @importFrom renv init dependencies
#' @importFrom dplyr group_by arrange slice_head filter mutate
#' @importFrom purrr walk2 walk
#' @importFrom cli cli_alert_success
easy_init <- function() {
  # check to be sure you are in an r project
  usethis::proj_get()
  # intitiate an renv project without installing anything
  renv::init(bioconductor = TRUE,
             bare = TRUE,
             restart = FALSE)
  # get the packages we need
  packages <- renv::dependencies()$Package
  purrr::walk(.x = packages,
              .f = safely_hydrate)

  sync_cache()
  write_cache_binary_pkg_catalog()
  cli::cli_alert_success("\nInitiated a new renv project.\n")


}


#' @title Easily restore a project from an RENV Lockfile
#' @description Reads the project lockfile or another lockfile supplied as an argument.  Then attempts to link to a binary version of each package in the cache.  If unavailable it will attempt to link to the newest version in the cache.  If that is unavailable it will install the package from the available repositories.
#' @param lockfile Optional non-default lock file to restore from.  Otherwise will use "renv.lock", Default: 'default'
#' @return Nothing
#' @seealso
#'  \code{\link[rjson]{fromJSON}}
#'  \code{\link[purrr]{map}}
#' @rdname easy_restore
#' @export
#' @importFrom rjson fromJSON
#' @importFrom purrr map_dfr walk2 walk
#' @importFrom tibble tibble
#' @importFrom dplyr left_join filter select mutate
#' @importFrom cli cli_alert_info cli_alert_success cli_alert_warning cli_div
easy_restore <- function(lockfile = "default") {
  cli::cli_div(theme = list(span.emph = list(color = "orange")))
  stopifnot("You must be in an active renv project to use this function." = "RENV_PROJECT" %in% names(Sys.getenv()))
  if (lockfile == "default") {
    lockfile = "renv.lock"
  }
  cli::cli_alert_info("Attempting to restore the library from {lockfile}.\n", )
  lock <- rjson::fromJSON(file = lockfile)
  packages <- names(lock$Packages)
  inst <- purrr::map_dfr(.x = packages,
                         .f = \(x, lck = lock) {
                           ind <- lck[["Packages"]][[x]]
                           if ("Hash" %in% names(ind)) {
                             res <- tibble::tibble(package = x, hash = ind[["Hash"]])
                           } else {
                             res <- tibble::tibble(package = x, hash = "no hash")
                           }
                         })
  cat <- get_cache_binary_pkg_catalog()
  bin_paths_inst <- dplyr::left_join(
    inst |>
      dplyr::filter(hash != "no hash") |>
      dplyr::select(hash),
    cat |>
      dplyr::select(c(path, hash, package)),
    by = "hash"
  ) |>
    dplyr::filter(path != "") |>
    dplyr::filter(!is.na(path)) |>
    dplyr::mutate(path = file.path(path, package))


  purrr::walk2(.x = bin_paths_inst$path,
               .y = bin_paths_inst$package,
               .f = \(x, y) {
                 library_link_path <- file.path(.libPaths()[1], y)
                 if (dir.exists(library_link_path))
                   unlink(library_link_path, recursive = T)
                 cli::cli_alert_info("Linking to {.emph {y}} in renv cache.")
                 invisible(file.symlink(to = library_link_path, from = x))

               })

  remainder <-
    inst$package[which(inst$package %notin% bin_paths_inst$package)]

  if (length(remainder) > 0) {
    cli::cli_alert_warning("Attempting to install packages not found in the cache.")
    purrr::walk(.x = remainder,
                .f = \(x) safely_hydrate(package = x))
    sync_cache()
    write_cache_binary_pkg_catalog()
  }

  cli::cli_alert_success("\nRestored project library from lock file.\n")

}


#' @title Easily Install Packages
#' @description Typically we would like to use existing copies of packages in our renv cache, rather than taking time to re-download them all and rebuild them all.  You can specify this option with how = "link_from_cache".  Providing only the package name will install the latest available version.  Providing package @@1.2.3" will install package version 1.2.3.  Providing package#hash will install a unique version of the package, identified by the hash.  You can get the package hash list with ```get_cache_binary_pkg_catalog()```.
#'
#' Alternatively we may want to install a new package or update a package from CRAN, bioconductor or another repository.  Specify this with "new_or_update".
#'
#' When installing local packages from tarball files, "how" is ignored, but an option for "tarball" is there for completeness.  If "tarball" is selected but the package is not a tarball, a message to that effect is returned.
#' @param package Package you wish to install.  "<package name>" will attempt to install from CRAN.  "bioc::<package name>" will attempt to install from bioconductor.  "<github repo owner>/<package>" will attempt to install from github.  Providing a file path to a tarball(.tar.gz) will move that package to the source cache and attempt to install from there.
#' @param how installation method.  If nothing is chosen the default is to "ask", Default: c("ask", "new_or_update", "link_from_cache", "tarball")
#' @return will install packages and return nothing
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  easy_install("praise")
#'  }
#' }
#' @rdname easy_install
#' @export
#' @importFrom stringr str_detect str_replace
#' @importFrom pak pkg_install
#' @importFrom cli cli_alert_success cli_div
easy_install <-
  function(package,
           how = c("ask", "new_or_update", "link_from_cache", "tarball")) {
    cli::cli_div(theme = list(span.emph = list(color = "orange")))
    how <- match.arg(how)
    stopifnot("You must be in an renv project to use this function." = "RENV_PROJECT" %in% names(Sys.getenv()))
    if (stringr::str_detect(package, "\\.tar\\.gz")) {
      cat("Installing tarball\n")
      install_targz(tarball = package)
    } else {
      package_name <-
        stringr::str_replace(package, "bioc::|.*/", "")

      if (how == "ask") {
        cat("Do you want to update a package or install a new package?\n")
        cat("Or do you want to link to the existing version in your renv cache?\n")
        cat("Linking is faster if the package is available\n")
        answer <-
          menu(c("New/Update", "Link from cache"), title = "How do you wish to proceed?")

        if (answer == 1) {
          pak::pkg_install(package, ask = FALSE)
          sync_cache()
          write_cache_binary_pkg_catalog()
        } else {
          # message("Attempting to link to ", package_name, " in cache...")
          safely_hydrate(package = package_name)
          sync_cache()
          write_cache_binary_pkg_catalog()
          cli::cli_alert_success("Successfully installed {.emph {package}} and its recursive dependencies.")
        }
      } else if (how == "new_or_update") {
        pak::pkg_install(package, ask = FALSE)
        sync_cache()
        write_cache_binary_pkg_catalog()
      } else if (how == "link_from_cache") {
        # message("Attempting to link to ", package_name, " in cache...")
        safely_hydrate(package = package_name)
        sync_cache()
        write_cache_binary_pkg_catalog()
        cli::cli_alert_success("Successfully installed {.emph {package}} and its recursive dependencies.")
      } else if (how == "tarball") {
        stop("You must supply a valid path to the tarball file.")

      }

    }


  }

#' @importFrom fs path_file
#' @importFrom dplyr pull filter
#' @importFrom stringr str_remove
#' @importFrom digest digest
#' @importFrom pkgcache pkg_cache_add_file
#' @importFrom pak cache_list pkg_install
install_targz <- function(tarball) {
  # parse the tarball file path
  tarball_file <- fs::path_file(tarball)
  package_name <- stringr::str_remove(tarball_file, "_.*")
  package_version <- stringr::str_remove(tarball_file, ".*_") |>
    stringr::str_remove(".tar.gz")
  package_hash <-
    digest::digest(tarball, file = TRUE, algo = "sha256")
  # put the targz in the pkgcache
  pkgcache::pkg_cache_add_file(
    file = tarball,
    relpath = paste0("src/contrib/", tarball_file),
    package = package_name,
    version = package_version,
    platform = "source"
  )

  # now install from the cache so you don't have to transfer large files twice
  # get the path to the cached version
  install_path <- file.path(pkgcache::pkg_cache_summary()$cachepath,
                            "src",
                            "contrib",
                            tarball_file)

  # install the tarball
  pak::pkg_install(install_path, ask = FALSE)
  sync_cache()
  write_cache_binary_pkg_catalog()


}

#' @importFrom renv paths hydrate
#' @importFrom fs dir_exists
#' @importFrom pak pkg_install
#' @importFrom cli cli_alert_warning cli_div
safely_hydrate <- function(package) {
  cli::cli_div(theme = list(span.emph = list(color = "orange")))
  cache_path <- renv::paths$cache()
  if (stringr::str_detect(package, "@")) {
    package_min <- stringr::str_remove(package, "@.+")
  } else if (stringr::str_detect(package, "#")) {
    package_min <- stringr::str_remove(package, "#.+")
  } else {
    package_min <- package
  }
  if (fs::dir_exists(file.path(cache_path, package_min))) {
    link_cache_to_proj(package = package)

  } else {
    cli::cli_alert_warning("{.emph {package}} is not in your cache.\nAttempting a new installation ")
    tryCatch({
      pak::pkg_install(package, ask = FALSE)

    }, error = function(cond) {
      cli::cli_alert_danger("{.emph {package}} could not be installed.  Moving on...")
    })

  }
}


#' @title Synchronize Project Library with Renv Cache
#' @description This function snapshots your current library, copies any packages existing in the renv project library to the renv cache and then links the package back into the project library.  This leaves you with an updated cache and a project library containing only symlinks, which is usually the ideal status for your project.
#' @return nothing
#' @rdname sync_cache
#' @export
#' @import renv
sync_cache <- function() {
  if ("RENV_PROJECT" %in% names(Sys.getenv())) {
    renv::snapshot(prompt = FALSE)
    lib <- renv::paths$library()
    lock <- renv:::renv_lockfile_load(".")
    packages <- lock$Packages
    invisible(lapply(
      X = packages,
      FUN = \(x) renv:::renv_cache_synchronize(record = x, linkable = TRUE)
    ))
  }


}


`%notin%` <- Negate(`%in%`)

#' @export
#' @importFrom fs dir_ls dir_info
#' @importFrom renv paths
#' @importFrom dplyr filter select mutate
#' @importFrom stringr str_remove str_extract
get_cache_binary_pkg_catalog <- function() {
  stopifnot("You must be in an renv project." = "RENV_PROJECT" %in% names(Sys.getenv()))
  remove <- fs::dir_ls(renv::paths$cache(), recurse = 1)
  fs::dir_info(renv::paths$cache(), recurse = 2) |>
    dplyr::filter(path %notin% remove) |>
    dplyr::select(path, modification_time) |>
    dplyr::mutate(package = stringr::str_remove(path, paste0(renv::paths$cache(), "/"))) |>
    dplyr::mutate(package = stringr::str_remove(package, "/.*")) |>
    dplyr::mutate(version = stringr::str_remove(path, paste0(renv::paths$cache(), "/"))) |>
    dplyr::mutate(version = stringr::str_remove(version, "[^/]+/")) |>
    dplyr::mutate(version = stringr::str_remove(version, "/.*")) |>
    dplyr::mutate(version = as.package_version(version)) |>
    dplyr::mutate(hash = stringr::str_extract(path, "/[:alnum:]+$")) |>
    dplyr::mutate(hash =  stringr::str_remove(hash, "/"))


}

#' @importFrom renv paths
#' @importFrom readr write_tsv
write_cache_binary_pkg_catalog <- function(path = NULL) {
  if (is.null(path)) {
    path <- renv::paths$root()
  }
  catalog <- get_cache_binary_pkg_catalog()
  readr::write_tsv(catalog, file.path(path, "cache_binary_pkg_catalog.tsv"))
}



#' @importFrom stringr str_detect str_remove
#' @importFrom dplyr filter mutate pull group_by arrange slice_head
#' @importFrom cli cli_alert_info cli_alert_success cli_div
link_cache_to_proj <- function(package) {
  cli::cli_div(theme = list(span.emph = list(color = "orange")))
  method <- "install.specific"
  if (stringr::str_detect(package, "@")) {
    pname <- stringr::str_remove(package, "@.+")
    pversion <- stringr::str_remove(package, ".+@")
    cli::cli_alert_info("Attempting to link to {.emph {pname}} version: {.emph {pversion}}.")
    link_path <- get_cache_binary_pkg_catalog() |>
      dplyr::filter(package == pname) |>
      dplyr::filter(version == pversion) |>
      dplyr::mutate(path_plus = file.path(path, package)) |>
      dplyr::pull(path_plus)
    if (length(link_path) == 0)
      method <- "install.latest"
    if (length(link_path) > 1)
      method <- "install.latest"
  } else if (stringr::str_detect(package, "#")) {
    pname <- stringr::str_remove(package, "#.+")
    phash <- stringr::str_remove(package, ".+#")
    cli::cli_alert_info("Attempting to link to {.emph {pname}} hash: {.emph {phash}}")
    link_path <- get_cache_binary_pkg_catalog() |>
      dplyr::filter(hash == phash) |>
      dplyr::mutate(path_plus = file.path(path, package)) |>
      dplyr::pull(path_plus)
    if (length(link_path) == 0)
      method <- "install.latest"
    if (length(link_path) > 1)
      method <- "install.latest"
  } else {
    pname <- package
    method <- "install.latest"
  }

  if (method == "install.latest") {
    cli::cli_alert_info("Linking to newest available version of {.emph {pname}} in the {.emph binary} cache.")
    link_path <- get_cache_binary_pkg_catalog() |>
      dplyr::group_by(package) |>
      dplyr::arrange(package, desc(version), desc(modification_time)) |>
      dplyr::slice_head(n = 1) |>
      dplyr::filter(package == pname) |>
      dplyr::mutate(path_plus = file.path(path, package)) |>
      dplyr::pull(path_plus)
  } else {
    cli::cli_alert_success("Linking to {.emph {package}} in the {.emph binary} cache.")
  }

  # create the new link path into the project library
  new_link_path <- file.path(.libPaths()[1], pname)

  # double check to be sure you don't recursively delete the parent directory which is the project library
  # this happens if the package name is "" which happens if there is a trailing comma in dependency list
  # this should also be caught later down where we strip out empty strings from deps
  if (pname %in% list.dirs(.libPaths()[1L], full.names = FALSE, recursive = FALSE)) {
    # unlink any old versions of the package existing in the project library
    unlink(new_link_path, recursive = T)

  }

  # create the new symlink from teh cached version to the project library
  invisible(file.symlink(to = new_link_path, from = link_path))

  # get the list of dependencies for the package you just installed
  deps <- read.dcf(file.path(new_link_path, "DESCRIPTION")) |>
    tibble::as_tibble()
  deps <- suppressWarnings(c(deps$Imports, deps$Depends)) |>
    stringr::str_remove_all("\\n") |>
    stringr::str_remove_all("\\([^()]+\\)") |>
    stringr::str_remove_all(" ") |>
    stringr::str_split(",") |>
    unlist()
  # strip out empty strings which will destroy your project lib
  deps <- deps[which(deps != "")]

  if (is.null(deps)) {
    needed <- character(0)
  } else {
    # get the installed packages
    installed <- list.files(.libPaths())

    # find out which ones are still needed
    needed <- deps[which(deps %notin% installed)]
    needed <- needed[which(needed != "R")]

  }


  # recursively apply safely hydrate
  if (length(needed) > 0) {
    purrr::walk(.x = needed,
                .f = \(x) {
                  # check if x is still needed at this point in the recursion
                  if (x %notin% list.files(.libPaths()))
                    safely_hydrate(x)
                }
                  )
  }



}
