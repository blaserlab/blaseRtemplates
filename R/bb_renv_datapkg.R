#' @title Install Or Update A Local R Data Package
#' @description If a directory is specified, this function will compare the currently installed version to the latest available version in the directory.  If there is a newer version available (based on version number), it will install this version.  If a binary is specifically requested it will install that one. If the package hasn't been installed, it will install it.
#' @param path Path to a directory containing one or more versions of the same data package.
#' @return noting
#' @seealso
#'  \code{\link[purrr]{safely}},\code{\link[purrr]{map}}
#'  \code{\link[stringr]{str_detect}},\code{\link[stringr]{str_glue}},\code{\link[stringr]{str_split}},\code{\link[stringr]{str_replace}},\code{\link[stringr]{str_sub}}
#'  \code{\link[renv]{install}}
#'  \code{\link[tibble]{as_tibble}}
#'  \code{\link[dplyr]{filter}},\code{\link[dplyr]{arrange}},\code{\link[dplyr]{slice}},\code{\link[dplyr]{pull}}
#' @rdname bb_renv_datapkg
#' @export
#' @importFrom purrr possibly map
#' @importFrom stringr str_detect str_glue str_split str_replace str_sub
#' @importFrom renv install
#' @importFrom tibble as_tibble
#' @importFrom dplyr filter arrange slice pull
bb_renv_datapkg <- function(path) {
  possibly_packageVersion <-
    purrr::possibly(packageVersion, otherwise = "0.0.0.0000")
  tryCatch(
    expr = {
      if (stringr::str_detect(string = path, pattern = ".tar.gz")) {
        message(stringr::str_glue("Installing {path}.  There may be newer versions available."))
        renv::install(path)
      } else {
        latest_version <- file.info(list.files(path, full.names = T)) %>%
          tibble::as_tibble(rownames = "file") %>%
          dplyr::filter(str_detect(file, pattern = ".tar.gz")) %>%
          dplyr::arrange(desc(mtime)) %>%
          dplyr::slice(1) %>%
          dplyr::pull(file) %>%
          stringr::str_split(pattern = "/") %>%
          purrr::map(tail, n = 1) %>%
          unlist()
        datapackage_stem <- stringr::str_replace(latest_version, "_.*", "")
        latest_version_number <- stringr::str_replace(latest_version, "^.*_", "")
        latest_version_number <-
          stringr::str_replace(latest_version_number, ".tar.gz", "")
        if (possibly_packageVersion(datapackage_stem) == "0.0.0.0000") {
          message(stringr::str_glue("Installing {datapackage_stem} for the first time."))
          if (stringr::str_sub(path,-1) == "/") {
            renv::install(paste0(path, latest_version))
          } else {
            renv::install(paste0(path, "/", latest_version))
          }
        } else {
          if (packageVersion(datapackage_stem) < latest_version_number) {
            message(
              stringr::str_glue(
                "A newer data package version is available.  Installing {latest_version}."
              )
            )
            if (stringr::str_sub(path,-1) == "/") {
              renv::install(paste0(path, latest_version))
            } else {
              renv::install(paste0(path, "/", latest_version))
            }

          } else {
            message(str_glue(
              "Your current version of {datapackage_stem} is up to date."
            ))

          }

        }
      }
    },
    error = function(cond) {
      message(
        "The most common reason for this function to err is you are disconnected from the OSUMC network drive.\n"
      )
      message("Here's the original error message:\n\n")
      message(cond)
      message(
        "\nTry reconnecting to the network by going to the Terminal tab and entering cccnetmount at the prompt.\n"
      )
      message("You will have to enter your network password.  Then try running the function again.\n")
    }
  )
}
