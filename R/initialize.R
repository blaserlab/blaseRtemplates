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
#' @inheritParams use_description
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
#' @import usethis
#' @export
initialize_project <- function(path,
                           rstudio = rstudioapi::isAvailable(),
                           open = rlang::is_interactive()) {
  path <- user_path_prep(path)
  name <- path_file(path_abs(path))
  challenge_nested_project(path_dir(path), name)
  challenge_home_directory(path)

  create_directory(path)
  local_project(path, force = TRUE)

  use_directory("R")
  use_template(template = "dependencies.R",
               save_as = "R/dependencies.R",
               package = "blaseRtemplates")
  use_template(template = "configs.R",
               save_as = "R/configs.R",
               package = "blaseRtemplates")
  use_template(template = "configs.local.R",
               save_as = "R/configs.local.R",
               package = "blaseRtemplates")
  use_template(template = "initialization.R",
               save_as = "R/initialization.R",
               package = "blaseRtemplates")

  if (rstudio) {
    use_rstudio()
  } else {
    ui_done("Writing a sentinel file {ui_path('.here')}")
    ui_todo("Build robust paths within your project via {ui_code('here::here()')}")
    ui_todo("Learn more at <https://here.r-lib.org>")
    file_create(proj_path(".here"))
  }

  if (open) {
    if (proj_activate(proj_get())) {
      # working directory/active project already set; clear the scheduled
      # restoration of the original project
      withr::deferred_clear()
    }
  }

  invisible(proj_get())
}
