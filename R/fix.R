#' @title Fix a User-Project Library
#' @description Sometimes, the user_project library can break.  This can happen if there are failures in the upstream install functions.  Or if the links are deleted for some reason.  If everything is broken, you may need to repair the user project library.  To do this, exit the project and enter a working project.  Delete the links in the offending user project library.  Then run this function to relink.  Use either the library catalog file from the project itself, or if this is also corrupted with bad information, run an older version that worked or a version from another project that worked.  If you can identify the problematic package in the course of these fixes, then you should probably delete it from your cache entirely.
#' @param file The library catalog tsv file to read from.
#' @param dir The user project library to repair.
#' @return Nothing
#' @seealso
#'  \code{\link[fs]{path_math}}, \code{\link[fs]{create}}, \code{\link[fs]{path}}, \code{\link[fs]{path_file}}
#'  \code{\link[readr]{read_delim}}
#'  \code{\link[dplyr]{pull}}
#' @rdname fix_another_library
#' @export
#' @importFrom fs path_abs dir_create path path_file link_create
#' @importFrom readr read_tsv
#' @importFrom dplyr pull
fix_another_library <- function(file, dir) {
  dir <- fs::path_abs(dir)
  fs::dir_create(dir)
  from <- readr::read_tsv(file) |>
    dplyr::pull(binary_location) |>
    fs::path()
  to <- fs::path(dir, fs::path_file(from))
  fs::link_create(path = from, new_path = to)
}


