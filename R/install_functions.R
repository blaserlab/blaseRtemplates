#' @title Easily Install Packages
#' @description Typically we would like to use existing copies of packages in our renv cache, rather than taking time to re-download them all.  Renv::hydrate provides this internal function.  You can specify this option with how = "link_from_cache".  Alternatively we may want to install a new package or update a package from CRAN, bioconductor or another repository.  Specify this with "new_or_update".  When installing local packages from tarball files, "how" is ignored, but an option for "tarball" is there for completeness.  If "tarball" is selected but the package is not a tarball, a message to that effect is returned.
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
easy_install <-
  function(package,
           how = c("ask", "new_or_update", "link_from_cache", "tarball")
           ) {
    how <- match.arg(how)
    stopifnot("You must be in an renv project to use this function." = "RENV_PROJECT" %in% names(Sys.getenv()))
    if (stringr::str_detect(package, "\\.tar\\.gz")) {
      cat("Installing tarball\n")
      install_targz(tarball = package, inst_fun = install_fun)
      sync_cache()
    } else {
      package_name <-
        stringr::str_replace(package, "bioc::|.*/", "")

      if (how == "ask") {
        cat("Do you want to update a package or install a new package?\n")
        cat("Or do you want to link to the existing version in your renv cache?\n")
        cat("Linking is faster if the package is unavailable\n")
        answer <-
          menu(c("New/Update", "Link from cache"), title = "How do you wish to proceed?")

        if (answer == 1) {
          pak::pkg_install(package, ask = FALSE)
          sync_cache()
        } else {
          message("Attempting to link to ", package_name, " in cache...")
          safely_hydrate(packages = package_name)
        }
      } else if (how == "new_or_update") {
        pak::pkg_install(package, ask = FALSE)
        sync_cache()
      } else if (how == "link_from_cache") {
        message("Attempting to link to ", package_name, " in cache...")
        safely_hydrate(packages = package_name)
      } else if (how == "tarball") {
        stop("You must supply a valid path to the tarball file.")

      }

    }


  }

#' @importFrom fs path_file
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
  package_hash <- digest::digest(tarball, file = TRUE, algo = "sha256")

  # put the targz in the pkgcache
  pkgcache::pkg_cache_add_file(file = tarball, relpath = paste0("src/contrib/", tarball_file),
                               package = package_name,
                               version = package_version,
                               platform = "source")

  # now install from the cache so you don't have to transfer large files twice
  # get the path to the cached version
  install_path <- pak::cache_list() |>
    filter(sha256 == package_hash) |>
    pull(fullpath) |>
    unique()

  if (length(install_path) > 1) {
    warning("It looks like the tarball is duplicated in the source code cache.\n\n")
  }

  # install the tarball
  pak::pkg_install(install_path, ask = FALSE)
  sync_cache()


}


#' @importFrom renv paths hydrate
#' @importFrom fs dir_exists
#' @importFrom pak pkg_install
safely_hydrate <- function(packages) {
  cache_path <- renv::paths$cache()
  if (fs::dir_exists(file.path(cache_path, packages))) {
    renv::hydrate(packages, update = TRUE)
  } else {
    message("The package is not in your cache.\n Attempting a new installation ")
    pak::pkg_install(packages, ask = FALSE)
    sync_cache()
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
