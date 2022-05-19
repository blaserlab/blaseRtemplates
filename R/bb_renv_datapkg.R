#' @title Install Or Update A Local R Data Package
#' @description If a directory is specified, this function will compare the currently installed version to the latest available version in the directory.  If there is a newer version available (based on version number), it will install this version.  If a tarball is specifically requested it will install that one. If the package hasn't ever been installed, it will install the newest version.
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
        cli::cli_alert_warning("Installing {path}.  There may be newer versions available.")
        install_targz(tarball = path)
        sync_cache()
      } else {
        latest_version <- file.info(list.files(path, full.names = T)) |>
          tibble::as_tibble(rownames = "file") |>
          dplyr::filter(stringr::str_detect(file, pattern = ".tar.gz")) |>
          dplyr::arrange(desc(mtime)) |>
          dplyr::slice(1) |>
          dplyr::pull(file) |>
          basename()
        datapackage_stem <-
          stringr::str_replace(latest_version, "_.*", "")
        latest_version_number <-
          stringr::str_replace(latest_version, "^.*_", "")
        latest_version_number <-
          stringr::str_replace(latest_version_number, ".tar.gz", "") |>
          as.package_version()

        # check if the newest version is available in renv cache
        cat <- get_cache_binary_pkg_catalog()

        latest_cached <- cat |>
          dplyr::filter(package == datapackage_stem) |>
          dplyr::arrange(desc(version), desc(modification_time)) |>
          dplyr::slice_head(n = 1) |>
          dplyr::pull(version)

        in_cache <- FALSE
        cache_up_to_date <- FALSE
        project_up_to_date <- FALSE

        if (length(latest_cached) > 0) in_cache <- TRUE
        if (in_cache) {
          if (latest_cached >= latest_version_number) cache_up_to_date <- TRUE
        }
        if (possibly_packageVersion(datapackage_stem) == latest_version_number) project_up_to_date <- TRUE

        if (project_up_to_date) {
          cli::cli_alert_success("Your current version of {datapackage_stem} is up to date.")
        } else {
          # check to see if cache is up to date and install from there if so
          if (cache_up_to_date) {
            easy_install(paste(datapackage_stem, latest_cached, sep = "@"), "link_from_cache")
          } else {
            cli::cli_alert_info("Installing the latest version of {datapackage_stem}.")
            install_datapackage(path, latest_version)
          }
        }



        }

    }
    ,
    error = function(cond) {
      message("Here's the original error message:\n\n")
      message(cond)
      message(
        "\n\nThe most common reason for this function to err is that the path to the datapkg directory has changed.\nCheck this and retry.\n\n"
      )
      message(
        "\n\nThe second most common reason for this function to err is you are disconnected from the OSUMC network drive.\n"
      )
      message(
        "Try reconnecting to the network by going to the Terminal tab and entering cccnetmount at the prompt.\n"
      )
      message("You will have to enter your network password.  Then try running the function again.\n")
    }
  )
}

install_datapackage <-
  function(path, latest_version) {
    if (stringr::str_sub(path, -1) == "/") {
      install_targz(tarball = paste0(path, latest_version))
      sync_cache()
    } else {
      install_targz(tarball = paste0(path, "/", latest_version))
      sync_cache()
    }
  }

