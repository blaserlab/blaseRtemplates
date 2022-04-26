#' @title Easily Install Packages
#' @description This provides some logic to renv install methods.  Typically when starting a project from scratch we would like to use exisitng copies of packages in our renv cache, rather than taking time to re-download them all.  Renv::hydrate provides this internal function.  You cen specify this option with how = "link_from_cache".  Alternatively we may want to install a new package or update a package.  Renv::install handles this; specify with "new_or_update".  When installing local packages from tarball files, renv can get confused.  This function detects that you are trying to do that, copies the tarball to the renv cellar and allows it to install from there.  In this case "how" is ignored, but an option for "tarball" is there for completeness.  If "tarball" is selected but the package is not a tarball, a message to that effect is returned.
#' @param package Package you wish to install.  "<package name>" will attempt to install from CRAN.  "bioc::<package name>" will attempt to install from bioconductor.  "<github repo owner>/<package>" will attempt to install from github.  Providing a file path to a tarball(.tar.gz) will move that package to the cellar and attempt to install from there.
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
#' @importFrom pak pak
#' @importFrom renv install
#' @importFrom stringr str_detect str_replace
easy_install <-
  function(package,
           how = c("ask", "new_or_update", "link_from_cache", "tarball"),
           use_pak = FALSE) {
    how <- match.arg(how)
    if (use_pak) {
      install_fun <- pak::pak
    } else {
      install_fun <- renv::install
    }
    if (stringr::str_detect(package, "\\.tar\\.gz")) {
      cat("Installing tarball\n")
      install_targz(tarball = package, inst_fun = install_fun)
      if(use_pak) sync_cache()
    } else {
      package_name <-
        stringr::str_replace(package, "bioc::|.*/", "")

      if (how == "ask") {
        cat("Do you want to update a package or install a new package?\n")
        cat("Or do you want to link to the existing version in your renv cache?\n")
        cat("Linking is faster but will fail if the package is unavailable\n")
        answer <-
          menu(c("New/Update", "Link from cache"), title = "How do you wish to proceed?")

        if (answer == 1) {
          install_fun(package)
          if(use_pak) sync_cache()
        } else {
          message("Attempting to link to ", package_name, " in cache...")
          safely_hydrate(packages = package_name)
        }
      } else if (how == "new_or_update") {
        install_fun(package)
        if(use_pak) sync_cache()
      } else if (how == "link_from_cache") {
        message("Attempting to link to ", package_name, " in cache...")
        safely_hydrate(packages = package_name)
      } else if (how == "tarball") {
        stop("You must supply a valid path to the tarball file.")

      }

    }


  }

#' @importFrom fs file_copy path_file
#' @importFrom stringr str_replace
#' @importFrom renv install
install_targz <- function(tarball, inst_fun = install_fun) {
  cellar <- getormake_renv_cellar()
  fs::file_copy(path = tarball,
                new_path = cellar,
                overwrite = TRUE)
  # install_string <- fs::path_file(tarball) |>
  #   stringr::str_replace("_", "@") |>
  #   stringr::str_replace(".tar.gz", "")
  install_string <- file.path(cellar, fs::path_file(tarball))
  inst_fun(install_string)

}


#' @importFrom renv paths hydrate install
#' @importFrom fs dir_exists
safely_hydrate <- function(packages, inst_fun = install_fun) {
  cache_path <- renv::paths$cache()
  if (fs::dir_exists(file.path(cache_path, packages))) {
    renv::hydrate(packages, update = TRUE)
  } else {
    message("The package is not in your cache.\n Attempting a new installation ")
    inst_fun(packages)
  }
}


#' @importFrom renv paths
#' @importFrom fs dir_create
getormake_renv_cellar <- function() {
  # check if cellar is set in environment variable
  env <- Sys.getenv()
  if ("RENV_PATHS_CELLAR" %in% names(env)) {
    cellar <- env[["RENV_PATHS_CELLAR"]]
  } else {
    cellar <- paste0(renv::paths$root(), "/cellar")
    fs::dir_create(cellar)
  }

  return(cellar)

}


#' @title Synchronize Project Library with Renv Cache
#' @description This function snapshots your current library, copies any packages existing in the renv project library to the renv cache and then links the package back into the project library.  This leaves you with an updated cache and a project library containing only symlinks, which is usually the ideal status for your project.
#' @return nothing
#' @rdname sync_cache
#' @export
#' @import renv
sync_cache <- function() {
  renv::snapshot(prompt = FALSE)
  lib <- renv::paths$library()
  lock <- renv:::renv_lockfile_load(".")
  packages <- lock$Packages
  invisible(lapply(
    X = packages,
    FUN = \(x) renv:::renv_cache_synchronize(record = x, linkable = TRUE)
  ))

}
