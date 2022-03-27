#' @title Easily Install Packages
#' @description This provides some logic to renv and pak install methods.  Typically when starting a project from scratch we would like to use exisitng copies of packages in our renv cache, rather than taking time to re-download them all.  Renv::hydrate provides this internal function.  You cen specify this option with how = "link_from_cache".  Alternatively we may want to install a new package or update a package.  Specify with "new_or_update" and pak will install the package and renv will link it to your project.
#' @param package Package you wish to install.  "<package name>" will attempt to install from CRAN.  "bioc::<package name>" will attempt to install from bioconductor.  "<github repo owner>/<package>" will attempt to install from github.
#' @param how installation method.  If nothing is chosen the default is to "ask", Default: c("ask", "new_or_update", "link_from_cache", "tarball")
#' @return will install packages and return nothing
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  easy_install("praise")
#'  }
#' }
#' @seealso
#'  \code{\link[stringr]{str_detect}}
#'  \code{\link[renv]{install}},\code{\link[renv]{hydrate}}
#' @rdname easy_install
#' @export
#' @importFrom stringr str_detect str_replace
#' @importFrom pak pkg_install
#' @importFrom renv hydrate install
easy_install <-
  function(package,
           how = c("ask", "new_or_update", "link_from_cache", "tarball")) {
    how <- match.arg(how)
    if (Sys.getenv("PAK_LIB_USER") == "") {
      pak_lib <- Sys.getenv("R_LIBS_USER")
    } else {
      pak_lib <- Sys.getenv("PAK_LIB_USER")
    }

    if (stringr::str_detect(package, "\\.tar\\.gz")) {
      cat("Installing tarball\n")
      # install_targz(tarball = package)
      pak::pkg_install(package, lib = pak_lib)
      package_name <- basename(package)
      package_name <- gsub(pattern = "_.*", replacement = "", x = package_name)
      renv::hydrate(packages = package)
    } else if (stringr::str_detect(package, "@")) {
      cat("Installing", package, "...")
      renv::install(package)
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
          pak::pkg_install(package, lib = pak_lib)
          renv::hydrate(packages = package_name)
        } else {
          message("Attempting to link to ", package_name, " in cache...")
          renv::hydrate(packages = package_name)
        }
      } else if (how == "new_or_update") {
          pak::pkg_install(package, lib = pak_lib)
          renv::hydrate(packages = package_name)
      } else if (how == "link_from_cache") {
        message("Attempting to link to ", package_name, " in cache...")
          renv::hydrate(packages = package_name)
      } else if (how == "tarball") {
        stop("You must supply a valid path to the tarball file.")

      }

    }


  }

