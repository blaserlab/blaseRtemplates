fs::dir_create("test_chmod_dir")
fs::file_create("test_chmod_dir/testfile.txt")
fs::dir_info("test_chmod_dir")
fs::dir_info(".")
fs::file_chmod("test_chmod_dir/testfile.txt", mode = "777")
fs::file_chmod("test_chmod_dir", mode = "777")


fs::dir_info("/workspace/rst/cache_R_4_2/library/codetools/0.2-19/a3cea41294c673e199128a6ba58455bc", recurse = TRUE)
fs::dir_info("/workspace/rst/cache_R_4_2/library/codetools", recurse = TRUE) |> pull(path)



