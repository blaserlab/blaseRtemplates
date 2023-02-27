#' @title Upgrade a Project to Use the Latest Version of BlaseRtemplates
#' @description This function converts an renv-based project to a blaseRtemplates project using the new cache structure.  Specifically, it will take the following actions on the provided project:
#'
#' 1. delete the renv folder
#' 2. delete the renv lock file
#' 3. write a new .Rprofile which in turn will
#' 4. create a new user_project directory.  This will be the primary package library for the project.  It will contain symlinks pointing to the newest versions of packages in the main cache.
#' 5. write a new file listing the packages actively used by the project into a new "library_catalogs" directory
#'
#' @param path path to the project to upgrade.  By default will upgrade the current project, Default: fs::path_wd()
#' @param path_to_cache_root PARAM_DESCRIPTION, Default: Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")
#' @rdname upgrade_bt
#' @export
#' @importFrom cli cli_alert_warning
#' @importFrom fs dir_create path dir_delete file_delete path_file path_package
#' @importFrom purrr safely
#' @importFrom usethis with_project
upgrade_bt <-
  function(path,
           path_to_cache_root = Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")) {
    if (path_to_cache_root == "") {
      cli::cli_alert_warning("No library cache was provided.")
      path_to_cache_root <-
        readline(prompt = "Enter a valid path to build a new library cache:  ")
      fs::dir_create(fs::path(path_to_cache_root, "library"))


    }
    # if (path == ".") path <- fs::path_wd()

    safe_dir_delete <- purrr::safely(fs::dir_delete)
    safe_file_delete <- purrr::safely(fs::file_delete)
    safe_dir_delete(fs::path(path, "renv"))
    safe_file_delete(fs::path(path, "renv.lock"))
    safe_file_delete(fs::path(path, ".Rprofile"))
    safe_file_delete(fs::path(path, ".Renviron"))
    safe_file_delete(fs::path(path, ".gitignore"))

    usethis::with_project(path, code = {
      usethis::use_template(template = "git_ignore",
                            save_as = ".gitignore",
                            package = "blaseRtemplates")

    })

    # make the new project library
    fs::dir_create(path_to_cache_root,
                   "user_project",
                   Sys.getenv("USER"),
                   fs::path_file(path))

    usethis::with_project(path, code = {
      get_new_library()
    })



  }



