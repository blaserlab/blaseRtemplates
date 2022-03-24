#' @title Build a Package and Send to Local CRAN-like Repository
#' @description Use this to build a package that can be installed like a CRAN package.  This wraps around function from the drat package.  A source package is built, inserted into the local drat repository, and the user session is checked to be sure the designated repository is available.  If not, it modifies the main .Rprofile file to make it accessible.  In order for this to work, the file path must be accessible on the local network.
#' @param repo_name Name for the repository.  Check to see if it has been added using options("repos")
#' @param repo_dir Directory to send the package source file to.  On linux at least, this can start with "~".
#' @return nothing
#' @seealso
#'  \code{\link[devtools]{build}}
#'  \code{\link[drat]{insertPackage}}
#' @rdname dratify
#' @export
#' @importFrom devtools build
#' @importFrom drat insertPackage
dratify <- function(repo_name, repo_dir) {
  # build the temporary tar.gz
  pkg_build <- devtools::build()

  # copy to drat repo
  drat::insertPackage(file = pkg_build,
                      repodir = repo_dir,
                      action = "archive")

  # delete the temporary tar.gz
  unlink(pkg_build)

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



