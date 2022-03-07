#' Create a package or project using a structured template
#'
#' @description
#' These functions create an R project:
#'   * `create_project()` creates a non-package project, i.e. a data analysis
#'   project
#'
#' Both functions can be called on an existing project; you will be asked before
#' any existing files are changed.
#'
#' This function is a modification of usethis::create_project
#'
#' @param path A path. If it exists, it is used. If it does not exist, it is
#'   created, provided that the parent path exists.
#' @param roxygen Do you plan to use roxygen2 to document your package?
#' @param rstudio If `TRUE`, calls [use_rstudio()] to make the new package or
#'   project into an [RStudio
#'   Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects).
#' @param open If `TRUE`, [activates][proj_activate()] the new project:
#'
#'   * If RStudio desktop, the package is opened in a new session.
#'   * If on RStudio server, the current RStudio project is activated.
#'   * Otherwise, the working directory and active project is changed.
#'
#' @return Path to the newly created project or package, invisibly.
#' @import usethis fs withr
#' @export
initialize_project <- function(path,
                           rstudio = rstudioapi::isAvailable(),
                           open = rlang::is_interactive()) {
  path <- usethis:::user_path_prep(path)
  name <- path_file(path_abs(path))
  usethis:::challenge_nested_project(path_dir(path), name)
  usethis:::challenge_home_directory(path)

  usethis:::create_directory(path)
  usethis::local_project(path, force = TRUE)

  usethis::use_directory("R")
  usethis::use_template(template = "dependencies.R",
               save_as = "R/dependencies.R",
               package = "blaseRtemplates")
  usethis::use_template(template = "configs.R",
               save_as = "R/configs.R",
               package = "blaseRtemplates")
  usethis::use_template(template = "local_configs.R",
               save_as = "R/local_configs.R",
               package = "blaseRtemplates")
  usethis::use_template(template = "initialization.R",
               save_as = "R/initialization.R",
               package = "blaseRtemplates")

  usethis::use_rstudio()

  if (open) {
    if (usethis::proj_activate(proj_get())) {
      # working directory/active project already set; clear the scheduled
      # restoration of the original project
      withr::deferred_clear()
    }
  }

  invisible(usethis:::proj_get())
}
