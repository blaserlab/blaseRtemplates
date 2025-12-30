clean_db <- function(db) {
  db |>
    dplyr::group_by(package, version) |>
    dplyr::mutate(n = dplyr::n()) |>
    dplyr::ungroup() |>
    dplyr::filter(n == 1) |>
    dplyr::select(-n)

}

get_new_biocs <- function(release, lib, db, cache) {
  db <- clean_db(db)
  db <- db |>
    dplyr::filter(bioc_version == release) |># gets teh right release
    dplyr::filter(package %in% lib$name)# gets only the packages being used in the project library catalog
  cache$version <- as.package_version(cache$version)
  dplyr::left_join(db, cache, by = dplyr::join_by(package == name, version == version)) |>
    filter(!is.na(bioc_version))
  # dplyr::left_join(lib, db, by = dplyr::join_by(name == package, version == version)) |>
  #   dplyr::filter(bioc_version != release)

}

find_bioc_release <- function(
  lib_cat = read_tsv("library_catalogs/blas02_blaseRtemplates.tsv"),
  bioc_db = read_tsv("/workspace/rst/cache_4_5/bioc_db.tsv")
) {
  bioc_db <- clean_db(bioc_db)
  bioc_release_table <- dplyr:: left_join(lib_cat, bioc_db |> select(-repo), by = dplyr::join_by(name == package, version == version)) |>
    dplyr::group_by(name) |>
    dplyr::summarise(bioc_version = list(unique(bioc_version)),
                     .groups = "drop") |>
    dplyr::count(bioc_version) |>
    dplyr::filter(!is.na(bioc_version))
  bioc_release_most_common <- bioc_release_table |>
    dplyr::slice_max(order_by = n, n = 1) |>
    dplyr::pull(bioc_version) |>
    unlist() |>
    as.character()
  bioc_release_table |>
    dplyr::mutate(bioc_version = paste0(bioc_version)) |>
    dplyr::mutate(ok = stringr::str_detect(bioc_version, bioc_release_most_common))
}



#' @importFrom BiocManager repositories
#' @importFrom withr local_options
bioc_pkg_versions <- function(bioc_version, repos = c("BioCsoft","BioCann","BioCexp","BioCworkflows")) {
  withr::local_options(list(BiocManager.check_repositories = FALSE))
  all_repos <- BiocManager::repositories(version = bioc_version)  # :contentReference[oaicite:3]{index=3}
  out <- lapply(repos, function(rn) {
    ap <- available.packages(repos = all_repos[rn], type = "source")
    data.frame(
      bioc_version = bioc_version,
      repo = rn,
      package = rownames(ap),
      version = ap[, "Version"],
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, out)
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param releases PARAM_DESCRIPTION
#' @param file PARAM_DESCRIPTION, Default: NULL
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso
#'  \code{\link[purrr]{map}}
#'  \code{\link[tibble]{as_tibble}}
#'  \code{\link[dplyr]{bind_rows}}
#'  \code{\link[cli]{cli_alert}}
#'  \code{\link[readr]{write_delim}}
#' @rdname update_bioc_db
#' @export
#' @importFrom purrr map
#' @importFrom tibble as_tibble
#' @importFrom dplyr bind_rows
#' @importFrom cli cli_alert_info
#' @importFrom readr write_tsv
update_bioc_db <- function(releases, file = NULL) {
  res <- purrr::map(.x = releases,
      .f = \(x) {
        bioc_pkg_versions(bioc_version = x) |>
          tibble::as_tibble()
      }) |>
    dplyr::bind_rows()

  if(!is.null(file)) {
    cli::cli_alert_info("Updating bioconductor database.")
    class(res)
    readr::write_tsv(x = res, file = file)
  } else {
    res
  }
}
