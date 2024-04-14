#' @title Make an Rmd Report from the Saved Template
#' @description Shortcut function to save the blaseRtemplates report template in Rmd format within an Rmd folder.
#' @param report_name Name for the Rmd file, Default: NULL
#' @return Returns nothing
#' @details Makes a new Rmd file with the supplied file name
#' @seealso
#'  \code{\link[stringr]{str_detect}}
#'  \code{\link[cli]{cli_alert}}
#'  \code{\link[fs]{create}}, \code{\link[fs]{path}}
#'  \code{\link[usethis]{use_template}}
#' @rdname report_template_rmd
#' @export
#' @importFrom stringr str_detect
#' @importFrom cli cli_alert_info
#' @importFrom fs dir_create path
#' @importFrom usethis use_template
report_template_rmd <- function(report_name = NULL) {
  if (is.null(report_name)) report_name <- "report.Rmd"
  if (stringr::str_detect(report_name, "Rmd", negate = TRUE)) {
    cli::cli_alert_info("Adding the .Rmd file extension.")
    report_name <- paste0(report_name, ".Rmd")
  }
  fs::dir_create("Rmd")
  usethis::use_template(template = "report_template.Rmd",
                        package = "blaseRtemplates",
                        save_as = fs::path("Rmd", report_name))
}
