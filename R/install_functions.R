#' @title Easily Initiate an renv Project
#' @description Behave similarly to renv::init but instead of downloading and building everything, will first attempt to link to the latest versions of packages available in your cache.
#' @return Nothing
#' @seealso
#'  \code{\link[renv]{init}}, \code{\link[renv]{dependencies}}
#'  \code{\link[purrr]{map}}, \code{\link[purrr]{safely}}
#' @rdname easy_init
#' @export
#' @importFrom renv init dependencies
#' @importFrom purrr walk
easy_init <- function() {
  # intitiate an renv lockfile without installing anything
  renv::init(bioconductor = TRUE, bare = TRUE, restart = FALSE)
  packages <- renv::dependencies()$Package
  purrr::walk(
    .x = packages,
    .f = \(x) safely_hydrate(x)
  )
  sync_cache()
  write_cache_binary_pkg_catalog()
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
#' @importFrom purrr map_chr walk
easy_restore <- function(lockfile = "default") {
  if (lockfile == "default") {
    lockfile = "renv.lock"
  }
  message("Attempting to restore the library from ", lockfile, ".\n")
  lock <- rjson::fromJSON(file = lockfile)
  packages <- names(lock$Packages)
  inst <- purrr::map_chr(.x = packages,
                         .f = \(x, lck = lock) {
                           ind <- lck[["Packages"]][[x]]
                           if ("Hash" %in% names(ind)) {
                             res <- paste0(x, "#", ind[["Hash"]])
                           } else {
                             res <- x
                           }
                         })
  purrr::walk(
    .x = inst,
    .f = \(x) safely_hydrate(x)

  )
  sync_cache()
  write_cache_binary_pkg_catalog()

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
easy_install <-
  function(package,
           how = c("ask", "new_or_update", "link_from_cache", "tarball")
           ) {
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
          message("Successfully installed ", package, " and its recursive dependencies.")
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
        message("Successfully installed ", package, " and its recursive dependencies.")
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
  package_hash <- digest::digest(tarball, file = TRUE, algo = "sha256")
  # put the targz in the pkgcache
  pkgcache::pkg_cache_add_file(file = tarball,
                               relpath = paste0("src/contrib/", tarball_file),
                               package = package_name,
                               version = package_version,
                               platform = "source")

  # now install from the cache so you don't have to transfer large files twice
  # get the path to the cached version
  install_path <- file.path(pkgcache::pkg_cache_summary()$cachepath,
                            "src","contrib", tarball_file)

  # install the tarball
  pak::pkg_install(install_path, ask = FALSE)
  sync_cache()
  write_cache_binary_pkg_catalog()


}

#' @importFrom renv paths hydrate
#' @importFrom fs dir_exists
#' @importFrom pak pkg_install
safely_hydrate <- function(package) {
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
    message(package, " is not in your cache.\nAttempting a new installation ")
    pak::pkg_install(package, ask = FALSE)
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
link_cache_to_proj <- function(package) {
  method <- "install.specific"
  if (stringr::str_detect(package, "@")) {
    pname <- stringr::str_remove(package, "@.+")
    pversion <- stringr::str_remove(package, ".+@")
    message("Attempting to link to ", pname, " version: ", pversion)
    link_path <- get_cache_binary_pkg_catalog() |>
      dplyr::filter(package == pname) |>
      dplyr::filter(version == pversion) |>
      dplyr::mutate(path_plus = file.path(path, package)) |>
      dplyr::pull(path_plus)
    if (length(link_path) == 0) method <- "install.latest"
    if (length(link_path) > 1) method <- "install.latest"
  } else if (stringr::str_detect(package, "#")) {
    pname <- stringr::str_remove(package, "#.+")
    phash <- stringr::str_remove(package, ".+#")
    message("Attempting to link to ", pname, " hash: ", phash)
    link_path <- get_cache_binary_pkg_catalog() |>
      dplyr::filter(hash == phash) |>
      dplyr::mutate(path_plus = file.path(path, package)) |>
      dplyr::pull(path_plus)
    if (length(link_path) == 0) method <- "install.latest"
    if (length(link_path) > 1) method <- "install.latest"
  } else {
    pname <- package
    method <- "install.latest"
  }

  if (method == "install.latest") {
    message("Linking to newest available version of ", pname, " in the *binary* cache.")
    link_path <- get_cache_binary_pkg_catalog() |>
      dplyr::group_by(package) |>
      dplyr::arrange(package, desc(version), desc(modification_time)) |>
      dplyr::slice_head(n = 1) |>
      dplyr::filter(package == pname) |>
      dplyr::mutate(path_plus = file.path(path, package)) |>
      dplyr::pull(path_plus)
  } else {
    message("Linking to ", package, " in the *binary* cache.")
  }

  new_link_path <- file.path(.libPaths()[1], pname)
  unlink(new_link_path, recursive = T)
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
  deps[which(deps != "")]

  if (is.null(deps)) {
    needed <- character(0)
  } else {

    # get the installed packages
    installed <- installed.packages() |>
      tibble::as_tibble() |>
      dplyr::pull(Package)

    # find out which ones are still needed
    needed <- deps[which(deps %notin% installed)]
    needed <- needed[which(needed != "R")]

  }


# recursively apply safely hydrate
  if (length(needed) > 0) {
    purrr::walk(.x = needed,
                .f = safely_hydrate)
  }



}

