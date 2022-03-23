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
  usethis::use_template(template = "git_commands.R",
               save_as = "R/git_commands.R",
               package = "blaseRtemplates")
  usethis::use_template(template = "git_ignore",
               save_as = ".gitignore",
               package = "blaseRtemplates")
  usethis::use_template(template = "R_profile",
               save_as = ".Rprofile",
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




#' @title Fork A Project From Github
#' @description This wraps usethis::create_from_github and adds 2 templates which are not tracked by git and are missed by the base function:  git_commands.R, local_configs.R.  This also enforces fork = TRUE and opens the project in a new session. You will need to have write access to the originator's repo for this to work correctly and you should provide write access for the originator to your repo for them to be able to update your shared work directly.
#' @param repo Repository name in the form of <owner>/<repo> or a url
#' @param dest Parent directory in which to create the forked project, Default: NULL
#' @seealso
#'  \code{\link[usethis]{create_from_github}},\code{\link[usethis]{use_template}},\code{\link[usethis]{proj_activate}}
#'  \code{\link[stringr]{str_replace}},\code{\link[stringr]{str_extract}}
#' @rdname fork_github_project
#' @export
#' @importFrom usethis create_from_github proj_activate
#' @importFrom stringr str_replace str_extract str_replace_all
#' @importFrom fs dir_create file_copy
fork_github_project <- function(repo, dest = NULL) {
  # fork the project
  usethis::create_from_github(repo_spec = repo,
                     destdir = dest,
                     fork = TRUE,
                     open = FALSE)

  # get the repo core name
  repo_name <- stringr::str_replace(repo,  "\\.git", "") |>
    stringr::str_extract("/.*$") |>
    stringr::str_replace_all("/", "//") |>
    stringr::str_replace_all("/.*/", "")

  newproj <- file.path(dest, repo_name)

  fs::dir_create(file.path(newproj, "R"),)
  fs::file_copy(path = system.file("templates/git_commands.R", package = "blaseRtemplates"),
                new_path = file.path(newproj, "R"))
  fs::file_copy(path = system.file("templates/local_configs.R", package = "blaseRtemplates"),
                new_path = file.path(newproj, "R"))

  usethis::proj_activate(newproj)

}
