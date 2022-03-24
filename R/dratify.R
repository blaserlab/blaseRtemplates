#' @title Build a Package and Send to Local CRAN-like Repository
#' @description Use this to build a package that can be installed like a CRAN package.  This wraps around function from the drat package.  A source package file is built from the current package, or explicitly chosen, inserted into the local drat repository, and the user session is checked to be sure the designated repository is available.  If not, it modifies the main .Rprofile file to make it accessible.  In order for this to work, the file path must be accessible on the local network.
#' @param pkg The package to install into the local repository.  If "." (default), the current working directory will be built, assuming you are running from inside a package.  Otherwise select a .tar.gz source file to add to the local repository.
#' @param repo_name Name for the local repository.  Check to see if it has been added using options("repos")
#' @param repo_dir Directory to send the package source file to.  Must be of the form "~/<path>/<to>/<repo>/R/drat".  If it does not exist it will be created.
#' @param cleanup Whether or not to delete the original .tar.gz file.  Defaults to TRUE.
#' @return nothing
#' @seealso
#'  \code{\link[devtools]{build}}
#'  \code{\link[drat]{insertPackage}}
#' @rdname dratify
#' @export
#' @importFrom devtools build
#' @importFrom drat insertPackage
#' @importFrom stringr str_detect
#' @importFrom fs dir_create
dratify <- function(pkg = ".", repo_name, repo_dir, cleanup = TRUE) {
  # build the temporary tar.gz
  if (pkg == ".") {
    pkg_build <- devtools::build()
  } else {
    stopifnot("You must choose a package source file, i.e. .tar.gz." = stringr::str_detect(pkg, ".tar.gz"))
    pkg_build <- pkg
  }

  if (!file.exists(file.path(repo_dir, "index.html"))) {
    file.copy(from = system.file("templates/index.html",
                                 package = "blaseRtemplates"), to = repo_dir)
  }

  fs::dir_create(file.path(repo_name, "src/contrib"))

  # copy to drat repo
  drat::insertPackage(file = pkg_build,
                      repodir = repo_dir,
                      action = "archive")



  # delete the tar.gz
  if (cleanup) unlink(pkg_build)

  # edit the user R profile
  if (!(repo_name %in% names(options("repos")$repos))) {
    message("Editing your ~/.Rprofile to include this local repository\n")
    message("It should be available after restarting your R session.")
    line1 <- paste0("# Activate the ", repo_name, " repo\n")
    line2 <-
      "suppressMessages(if (!require('drat')) install.packages('drat'))\n"
    line3 <-
      paste0("drat:::addRepo('", repo_name, "', 'file:", repo_dir, "')\n")
    cat(c(line1, line2, line3), file = "~/.Rprofile", append = TRUE,sep = "")

  }
}



