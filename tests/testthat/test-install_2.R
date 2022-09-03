devtools::load_all()

test_that("find_unlinked_packages works", {
  fs::dir_create(fs::path_temp("test_find_unlinked_packages"))
  expect_equal(find_unlinked_packages(lib_path = fs::path_temp()),
               fs::path_temp("test_find_unlinked_packages"))
  fs::dir_delete(fs::path_temp("test_find_unlinked_packages"))
})

test_that("package hashing works", {
  fs::dir_create(fs::path_temp("pretend_package"))
  fs::file_create(fs::path_temp("pretend_package", "testfile1"))
  fs::dir_create(fs::path_temp("pretend_package", "testdir"))
  fs::file_create(fs::path_temp("pretend_package", "testdir","testfile2"))
  hash_list <- list(digest::digest(fs::path_temp("pretend_package", "testfile1"), algo = "md5", file = TRUE),
                    digest::digest(fs::path_temp("pretend_package", "testdir","testfile2"), algo = "md5", file = TRUE))
  expected_hash <- digest::digest(hash_list, algo = "md5")
  expect_equal(hash_fun(fs::path_temp("pretend_package")),
               expected_hash)
  fs::dir_delete(fs::path_temp("pretend_package"))
})

test_that("get_all_deps works", {
  path_to_stats <- find.package("stats")
  expect_equal(get_all_deps(path_to_stats),
               c("utils", "grDevices", "graphics"))
})


test_that("cache_fun works", {

  path_to_stats <- find.package("stats")
  fs::dir_copy(path = path_to_stats, new_path = fs::path_temp("stats"))
  expected_val <- fs::path_temp("cache",
                                "stats",
                                packageVersion("stats"),
                                hash_fun(fs::path_temp("stats")),
                                "stats")
  test_val <- cache_fun(package = fs::path_temp("stats"),
            cache_loc = fs::path_temp("cache"))
  test_val <- test_val$pkg_tbl$binary_location
  expect_equal(test_val, expected_val)
  expect_true(unname(fs::is_link(fs::path_temp("stats"))))
  fs::dir_delete(fs::path_temp("cache"))
  fs::link_delete(fs::path_temp("stats"))
})

test_that("update package catalog works", {
  path_to_stats <- find.package("stats")
  fs::dir_copy(path = path_to_stats, new_path = fs::path_temp("stats"))
  expected_val <- fs::path_temp("cache",
                                "stats",
                                packageVersion("stats"),
                                hash_fun(fs::path_temp("stats")),
                                "stats")
  expected_val
  expected_val <- as.character(expected_val)
  update <- cache_fun(package = fs::path_temp("stats"), cache_loc = fs::path_temp("cache"))
  update <- update$pkg_tbl
  update
  update_package_catalog(cache_loc = fs::path_temp("cache"),
                         pkg_update = update)

  test_val <- readr::read_tsv(fs::path_temp("cache", "package_catalog.tsv"))
  test_val <- test_val$binary_location
  expect_equal(test_val, expected_val)
  fs::dir_delete(fs::path_temp("cache"))
  fs::link_delete(fs::path_temp("stats"))
})


test_that("update dependency catalog works", {
  path_to_stats <- find.package("stats")
  fs::dir_copy(path = path_to_stats, new_path = fs::path_temp("stats"))
  expected_val <- hash_fun(fs::path_temp("stats"))
  update <- cache_fun(package = fs::path_temp("stats"), cache_loc = fs::path_temp("cache"))
  update <- update$dep_tbl
  update_dependency_catalog(cache_loc = fs::path_temp("cache"),
                         dep_update = update)
  test_val <- readr::read_tsv(fs::path_temp("cache", "dependency_catalog.tsv"))
  test_val <- unique(test_val$hashes)
  expect_equal(test_val, expected_val)
  fs::dir_delete(fs::path_temp("cache"))
  fs::link_delete(fs::path_temp("stats"))
})

test_that("hash_n_cache works", {
  path_to_stats <- find.package("stats")
  fs::dir_copy(path = path_to_stats, new_path = fs::path_temp("stats"))
  path_to_graphics <- find.package("graphics")
  fs::dir_copy(path = path_to_graphics, new_path = fs::path_temp("graphics"))
  hash_n_cache(lib_loc = fs::path_temp(), cache_loc = fs::path_temp("cache"))
  expect_equal(digest::digest(fs::path_temp("cache", "dependency_catalog.tsv"), file = TRUE, algo = "md5"),
               "88233bc6cc14fab4001d9296ca732355")
  fs::dir_delete(fs::path_temp("cache"))
  fs::link_delete(fs::path_temp("stats"))
  fs::link_delete(fs::path_temp("graphics"))
})

test_that("write_project_library_catalog works", {
  path_to_stats <- find.package("stats")
  fs::dir_copy(path = path_to_stats, new_path = fs::path_temp("stats"))
  path_to_graphics <- find.package("graphics")
  fs::dir_copy(path = path_to_graphics, new_path = fs::path_temp("graphics"))
  hash_n_cache(lib_loc = fs::path_temp(), cache_loc = fs::path_temp("cache"))
  usethis::create_project(fs::path_temp("temp_proj"), open = F)
  usethis::with_project(fs::path_temp("temp_proj"), code =
  write_project_library_catalog(lib_loc = fs::path_temp(),
                                cache_loc = fs::path_temp("cache"),
                                user = Sys.getenv("USER"),
                                project = "temp_proj"))
  test_val <- readr::read_tsv(fs::path_temp("temp_proj", "library_catalogs", paste0(Sys.getenv("USER"), "_temp_proj.tsv")))
  expect_equal(digest::digest(fs::path_temp("cache", "dependency_catalog.tsv"), file = TRUE, algo = "md5"),
               "88233bc6cc14fab4001d9296ca732355")
  fs::dir_delete(fs::path_temp("cache"))
  fs::link_delete(fs::path_temp("stats"))
  fs::link_delete(fs::path_temp("graphics"))
  fs::dir_delete(fs::path_temp("temp_proj"))
})



