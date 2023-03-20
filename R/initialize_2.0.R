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
                               open = rlang::is_interactive(),
                               fresh_install = FALSE,
                               path_to_cache_root = Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")) {
  if (path_to_cache_root == "") {
    cli::cli_abort("You must first set the BLASERTEMPLATES_CACHE_ROOT environmental variable.")

  }

  # path <- usethis:::user_path_prep(path)
  path <- fs::path_abs(path)
  name <- fs::path_file(path)
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
  # usethis::use_template(template = "local_configs.R",
  #                       save_as = "R/local_configs.R",
  #                       package = "blaseRtemplates")
  usethis::use_template(template = "initialization.R",
                        save_as = "R/initialization.R",
                        package = "blaseRtemplates")
  usethis::use_template(template = "git_commands.R",
                        save_as = "R/git_commands.R",
                        package = "blaseRtemplates")
  usethis::use_template(template = "git_ignore",
                        save_as = ".gitignore",
                        package = "blaseRtemplates")
  # usethis::use_template(template = "R_profile.R",
  #                       save_as = ".Rprofile",
  #                       package = "blaseRtemplates")


  usethis::use_rstudio()

  # make the new project library
  fs::dir_create(path_to_cache_root,
                 "user_project",
                 Sys.info()[["user"]],
                 fs::path_file(path))

  if (!fresh_install) {
    if ("blaseRtemplates" %in% fs::path_file(fs::dir_ls(fs::path(path_to_cache_root, "library")))) {
      usethis::with_project(path, code = {
        .libPaths(c(
          file.path(
            Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
            "user_project",
            Sys.info()[["user"]],
            basename(getwd())
          ),
          .libPaths()[2]
        ))
        get_new_library()
        write_project_library_catalog()
      })


    } else {
      usethis::with_project(path, code = {
        .libPaths(c(
          file.path(
            Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
            "user_project",
            Sys.info()[["user"]],
            basename(getwd())
          ),
          .libPaths()[2]
        ))
        install.packages("pak")
        pak::pkg_install("blaserlab/blaseRtemplates")
        get_new_library()
        write_project_library_catalog()
      })


    }
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
                               roxygen = TRUE,
                               check_name = TRUE,
                               rstudio = rstudioapi::isAvailable(),
                               open = rlang::is_interactive(),
                               fresh_install = FALSE,
                               path_to_cache_root = Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")
                               ) {
  if (path_to_cache_root == "") {
    cli::cli_abort("You must first set the BLASERTEMPLATES_CACHE_ROOT environmental variable.")

  }

  # path <- usethis:::user_path_prep(path)
  path <- fs::path_abs(path)
  name <- fs::path_file(path)
  usethis:::challenge_nested_project(path_dir(path), name)
  usethis:::challenge_home_directory(path)

  usethis:::create_directory(path)
  usethis::local_project(path, force = TRUE)

  usethis::use_directory("R")
  usethis::use_description(fields, check_name = FALSE, roxygen = roxygen)
  usethis::use_namespace(roxygen = roxygen)
  usethis::use_directory("inst/data-raw")
  usethis::use_directory("data/")
  fs::file_create("R/data.R")
  usethis::use_directory("library_catalogs")
  usethis::use_template(template = "initialization.R",
                        save_as = "inst/data-raw/initialization.R",
                        package = "blaseRtemplates")
  usethis::use_template(template = "git_commands.R",
                        save_as = "inst/data-raw/git_commands.R",
                        package = "blaseRtemplates")
  usethis::use_template(template = "git_ignore",
                        save_as = ".gitignore",
                        package = "blaseRtemplates")


  usethis::use_rstudio()

  # make the new project library
  fs::dir_create(path_to_cache_root,
                 "user_project",
                 Sys.info()[["user"]],
                 fs::path_file(path))

  if (!fresh_install) {
    if ("blaseRtemplates" %in% fs::path_file(fs::dir_ls(fs::path(path_to_cache_root, "library")))) {
      usethis::with_project(path, code = {
        .libPaths(c(
          file.path(
            Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
            "user_project",
            Sys.info()[["user"]],
            basename(getwd())
          ),
          .libPaths()[2]
        ))
        get_new_library()
        write_project_library_catalog()
      })


    } else {
      usethis::with_project(path, code = {
        .libPaths(c(
          file.path(
            Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
            "user_project",
            Sys.info()[["user"]],
            basename(getwd())
          ),
          .libPaths()[2]
        ))
        install.packages("pak")
        pak::pkg_install("blaserlab/blaseRtemplates")
        get_new_library()
        write_project_library_catalog()
      })


    }
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

#' @title Initialize A Project By Forking A Github Repo
#' @description This function wraps usethis::create_from_github, making some useful default choices and building the user project library compatible with the blaseRtemplates R system.  Because this function forks the project, git will set up the originator as an upstream remote.  Using blaseRtemplates::git_push_all will push to both the originator and the collaborator's github.
#' @param repo The repo to clone.  Must be in the form of github_user/repo_name.  If private, you must be a collaborator and have permission to fork the repo from the owner.
#' @param dest Destination directory.  This directory will become the parent directory for the project you are forking.
#' @param library Optional blaseRtemplates library catalog to use when making the project package library.  If nothing is entered, the newest available versions will be installed.  Otherwise, enter a library catalog file in the form of "library_catalogs/user_repo_name.tsv.  Of course replace user and repo_name.  This file will have to exist in the project you are forking., Default: 'newest'
#' @param open Whether to open the forked project, Default: FALSE
#' @return nothing
#' @seealso
#'  \code{\link[stringr]{str_remove}}
#'  \code{\link[cli]{cli_abort}}
#'  \code{\link[usethis]{create_from_github}}, \code{\link[usethis]{proj_utils}}, \code{\link[usethis]{proj_activate}}
#'  \code{\link[fs]{create}}, \code{\link[fs]{path}}
#'  \code{\link[withr]{defer}}
#' @rdname initialize_github
#' @export
#' @importFrom stringr str_remove
#' @importFrom cli cli_abort
#' @importFrom usethis create_from_github with_project proj_activate proj_get
#' @importFrom fs dir_create path
#' @importFrom withr deferred_clear
initialize_github <- function(repo,
                              dest,
                              library = "newest",
                              open = FALSE) {
  repo_owner <- stringr::str_remove(repo, "/.*")
  repo_name <- stringr::str_remove(repo, ".*/")
  if (repo_owner == repo_name)
    cli::cli_abort("You must enter repo in the form repo_owner/repo_name.")

  usethis::create_from_github(
    repo_spec = repo,
    destdir = dest,
    fork = TRUE,
    open = FALSE
  )
  # make the user project library
  fs::dir_create(fs::path(
    Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
    "user_project",
    Sys.info()[["user"]],
    repo_name
  ))

  # populate the user project library
  usethis::with_project(fs::path(dest, repo_name), code = {
    source(".Rprofile")
    get_new_library(newest_or_file = library)
    write_project_library_catalog()
  })

  if (open) {
    if (usethis::proj_activate(usethis::proj_get())) {
      withr::deferred_clear()
    }
  }


}
