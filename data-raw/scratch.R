devtools::load_all()
write_project_library_catalog()

install_one_package("blaseRtools")




renv::dependencies("./R") |>
  dplyr::pull(Package) |>
  unique()

pak::scan_deps("./R") |> as_tibble() |> pull(package) |> unique()
get_lib_pkg_hashes1 <- function() {
  tibble::tibble(path = fs::dir_ls(.libPaths()[1])) |>
    dplyr::filter(fs::is_link(path)) |>
    dplyr::mutate(path = fs::link_path(path)) |>
    dplyr::mutate(path1 = fs::path_dir(path)) |>
    dplyr::transmute(hash = fs::path_file(path1))



}
get_lib_pkg_hashes1()

get_lib_pkg_hashes <- function() {
  fs::dir_info(.libPaths()[1]) |>
    dplyr::filter(type == "symlink") |>
    dplyr::select(path) |>
    dplyr::mutate(path = fs::link_path(path)) |>
    dplyr::mutate(path1 = fs::path_dir(path)) |>
    dplyr::transmute(hash = fs::path_file(path1))
}
get_lib_pkg_hashes()
