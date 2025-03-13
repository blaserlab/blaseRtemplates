#' @title Save a monocle3 cds object on disk
#' @description CDS objects can be large and because they are normally stored in memory this can lead to prolonged loading time and possibly system crashes.  Use this function to save a monocle cds object to disk.  The expected usage is to provide the function a cds object to save, and two directories.  These directories should be within a datapackage project, but this is not strictly required.  The extdata directory is where the cds data will be saved.  This *must* be within inst (so, inst/extdata) for it to be installed and loaded with the data package using project_data.  The data directory is where normal .rda files are saved for typical R objects.  This will be a placeholder object with the same name.  The purpose is to permit documentation of the cds object and to mitigate namespace conflicts.  When the real object is loaded, the placeholder is overwritten.
#' @param cds_disk The cds object to save to disk.
#' @param data_directory The package data directory to save to.
#' @param extdata_directory The package extdata directory to save to.
#' @param alt_name An alternative name to save the cds under.  Useful if the function is used programmatically.
#' @return nothing
#' @seealso
#'  \code{\link[fs]{file_access}}, \code{\link[fs]{path}}, \code{\link[fs]{path_file}}
#'  \code{\link[cli]{cli_abort}}, \code{\link[cli]{cli_alert}}
#'  \code{\link[monocle3]{convert_counts_matrix}}, \code{\link[monocle3]{save_monocle_objects}}
#'  \code{\link[DescTools]{SaveAs}}
#' @rdname save_monocle_disk
#' @export
#' @importFrom fs dir_exists path path_file path_dir file_exists
#' @importFrom cli cli_abort cli_alert_warning cli_alert_success
#' @importFrom monocle3 convert_counts_matrix save_monocle_objects
#' @importFrom DescTools SaveAs
save_monocle_disk <- function(cds_disk,
                              data_directory,
                              extdata_directory,
                              alt_name = NULL) {
  # check the directories
  if (!fs::dir_exists(fs::path(data_directory)))
    cli::cli_abort("{.emph {data_directory}} does not exist.")
  if (!fs::dir_exists(fs::path(extdata_directory)))
    cli::cli_abort("{.emph {extdata_directory}} does not exist.")
  data_check <- fs::path_file(data_directory)
  extdata_check <- fs::path_file(extdata_directory)
  inst_check <- fs::path_file(fs::path_dir(extdata_directory))

  if (data_check != "data") {
    cli::cli_alert_warning("Normally data_directory should be named 'data' and be within a data package.")
    answer <-
      menu(c("Yes", "No"), title = "Do you wish to proceed?")
    if (answer == 2) {
      cli::cli_abort("Aborting")
    }

  }

  if (paste0(inst_check, extdata_check) != "instextdata") {
    cli::cli_alert_warning(
      "Normally extdata_directory should be named 'inst/extdata' and be within a data package."
    )
    answer <-
      menu(c("Yes", "No"), title = "Do you wish to proceed?")
    if (answer == 2) {
      cli::cli_abort("Aborting")
    }

  }


  # get the name of the object
  if (is.null(alt_name)) {
    cds_name <- deparse(substitute(cds_disk))
  } else {
    cds_name <- alt_name
  }

  new_rda <- "This is a placeholder object."

  # convert the counts matrix
  cds_disk <-
    monocle3::convert_counts_matrix(cds = cds_disk,
                                    matrix_control = list(matrix_class = "BPCells"))

  # save the monocle object first
  monocle3::save_monocle_objects(
    cds = cds_disk,
    directory_path = fs::path(extdata_directory, cds_name),
    archive_control = list(archive_type = "none")
  )

  cli::cli_alert_success("Saved the monocle3 cds to {extdata_directory}")

  if (fs::file_exists(fs::path(data_directory, cds_name, ext = "rda"))) {
    cli::cli_alert_warning("{cds_name}.rda already exists in the data directory")
    answer <-
      menu(c("Yes", "No"), title = "Do you wish to proceed?")
    if (answer == 1) {
      # save the rda
      DescTools::SaveAs(
        x = new_rda,
        objectname = cds_name,
        file = fs::path(data_directory, cds_name, ext = "rda")
      )
      cli::cli_alert_success("Done")

    } else {
      cli::cli_abort(
        "Aborting.  To generate a placeholder .rda file for this object, move the existing .rda file and rerun."
      )
    }

  } else {
    # save the rda
    DescTools::SaveAs(
      x = new_rda,
      objectname = cds_name,
      file = fs::path(data_directory, cds_name, ext = "rda")
    )

    cli::cli_alert_success("Done")

  }



}
