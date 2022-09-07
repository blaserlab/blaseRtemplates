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
#' @import usethis fs rstudioapi rlang
#' @importFrom withr deferred_clear
#' @export
initialize_project <- function(path,
                               rstudio = rstudioapi::isAvailable(),
                               open = rlang::is_interactive()) {
  path_to_cache_root <- Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")
  if (path_to_cache_root == "") {
    cli::cli_abort("You must first set the BLASERTEMPLATES_CACHE_ROOT environmental variable.")

  }

  path <- usethis:::user_path_prep(path)
  name <- path_file(path_abs(path))
  usethis:::challenge_nested_project(path_dir(path), name)
  usethis:::challenge_home_directory(path)

  usethis:::create_directory(path)
  usethis::local_project(path, force = TRUE)

  usethis::use_directory("R")
  usethis::use_directory("library_catalogs")
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

  # make the custom R profile
  cat(
    "# Set the blaseRtemplates cache as an environment variable.\n",
    file = fs::path(path, ".Rprofile")
  )
  cat(
    paste0(
      'Sys.setenv("BLASERTEMPLATES_CACHE_ROOT" = "',
      path_to_cache_root,
      '")'
    ),
    file = fs::path(path, ".Rprofile"),
    sep = "\n",
    append = T
  )
  cat(
    "\n# Set the project libraries.",
    file = fs::path(path, ".Rprofile"),
    sep = "\n",
    append = T
  )
  cat(
    paste0(
      '.libPaths(c("',
      fs::path(
        path_to_cache_root,
        "user_project",
        Sys.getenv("USER"),
        fs::path_file(path)
      ),
      '", .libPaths()[2]))'

    ),
    file = fs::path(path, ".Rprofile"),
    sep = "\n",
    append = T
  )
  cat(
    readLines(
      fs::path_package("blaseRtemplates", "templates", "R_profile.R")
    ),
    file = fs::path(path, ".Rprofile"),
    sep = "\n",
    append = T
  )

  usethis::use_rstudio()

  # make the new project library
  fs::dir_create(path_to_cache_root,
                 "user_project",
                 Sys.getenv("USER"),
                 fs::path_file(path))
  if ("blaseRtemplates" %in% fs::dir_ls(fs::path(path_to_cache_root, "library"))) {
    usethis::with_project(path, code = {
      source(".Rprofile")
      get_new_library()
      write_project_library_catalog()
    })


  } else {
    usethis::with_project(path, code = {
      source(".Rprofile")
      install.packages("pak")
      pak::pkg_install("blaseRtemplates")
      get_new_library()
      write_project_library_catalog()
    })


  }

  if (open) {
    if (usethis::proj_activate(proj_get())) {
      # working directory/active project already set; clear the scheduled
      # restoration of the original project
      withr::deferred_clear()
    }
  }

  invisible(usethis:::proj_get())

}


#' @title Initialize a Package Using a Standard Template
#' @description This wraps `usethis::create_package()` and adds a few additional templates.
#' @param path path/name for the new package.  It should include letters and "." only to be CRAN-compliant.
#' @param fields named list of fields in addition to/overriding defaults for the DESCRIPTION file, Default: list()
#' @param rstudio makes an Rstudio project, default is true
#' @param roxygen do you plan to use roxygen2 to document package?, Default: TRUE
#' @param check_name check if name is CRAN-compliant, Default: TRUE
#' @param open to open or not, Default: rlang::is_interactive()
#' @seealso
#'  \code{\link[rstudioapi]{isAvailable}}
#'  \code{\link[rlang]{is_interactive}}
#'  \code{\link[usethis]{use_template}}
#'  \code{\link[withr]{defer}}
#' @rdname initialize_package
#' @export
#' @importFrom rstudioapi isAvailable
#' @importFrom rlang is_interactive
#' @importFrom withr deferred_clear
#' @import usethis fs
initialize_package <- function(path,
                               fields = list(),
                               rstudio = rstudioapi::isAvailable(),
                               roxygen = TRUE,
                               check_name = TRUE,
                               open = rlang::is_interactive()) {
  path_to_cache_root <- Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")
  if (path_to_cache_root == "") {
    cli::cli_alert_warning("No library cache is available.")
    path_to_cache_root <-
      readline(prompt = "Enter a valid path to build a new library cache:  ")
    fs::dir_create(fs::path(path_to_cache_root, "library"))


  }

  path <- usethis:::user_path_prep(path)
  usethis:::check_path_is_directory(fs::path_dir(path))
  name <- fs::path_file(fs::path_abs(path))
  if (check_name) {
    usethis:::check_package_name(name)
  }
  usethis:::challenge_nested_project(path_dir(path), name)
  usethis:::challenge_home_directory(path)
  usethis:::create_directory(path)
  usethis::local_project(path, force = TRUE)
  usethis::use_directory("R")
  usethis::use_description(fields, check_name = FALSE, roxygen = roxygen)
  usethis::use_namespace(roxygen = roxygen)

  fs::dir_create("inst/data-raw")

  usethis::use_template(template = "initialization.R",
                        save_as = "inst/data-raw/initialization.R",
                        package = "blaseRtemplates")
  usethis::use_template(template = "git_commands.R",
                        save_as = "inst/data-raw/git_commands.R",
                        package = "blaseRtemplates")
  usethis::use_template(template = "git_ignore",
                        save_as = ".gitignore",
                        package = "blaseRtemplates")

  # make the custom R profile
  cat(
    "# Set the blaseRtemplates cache as an environment variable.\n",
    file = fs::path(path, ".Rprofile")
  )
  cat(
    paste0(
      'Sys.setenv("BLASERTEMPLATES_CACHE_ROOT" = "',
      path_to_cache_root,
      '")'
    ),
    file = fs::path(path, ".Rprofile"),
    sep = "\n",
    append = T
  )
  cat(
    "\n# Set the project libraries.",
    file = fs::path(path, ".Rprofile"),
    sep = "\n",
    append = T
  )
  cat(
    paste0(
      '.libPaths(c("',
      fs::path(
        path_to_cache_root,
        "user_project",
        Sys.getenv("USER"),
        fs::path_file(path)
      ),
      '", .libPaths()[2]))'

    ),
    file = fs::path(path, ".Rprofile"),
    sep = "\n",
    append = T
  )
  cat(
    readLines(
      fs::path_package("blaseRtemplates", "templates", "R_profile.R")
    ),
    file = fs::path(path, ".Rprofile"),
    sep = "\n",
    append = T
  )

  # make the new project library
  fs::dir_create(path_to_cache_root,
                 "user_project",
                 Sys.getenv("USER"),
                 fs::path_file(path))
  usethis::with_project(path, code = {
    source(".Rprofile")
    get_new_library()
    write_project_library_catalog()
  })

  fs::dir_create("data/")
  fs::file_create("R/data.R")


  if (rstudio) {
    usethis::use_rstudio()
  }
  if (open) {
    if (usethis::proj_activate(usethis::proj_get())) {
      withr::deferred_clear()
    }
  }
  invisible(usethis::proj_get())
}
