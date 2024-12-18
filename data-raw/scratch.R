# a change
# another change
devtools::load_all()
project_data("~/network/X/Labs/Blaser/share/collaborators/lapalombella_pu_network/datapkg")
test <- c(1, 2, 3, 4)
tail(test, )
test_name <- "test_value"
eval(test_name)
blaseRtemplates::get_new_library()

bpcells_dir <-
  fs::dir_ls(fs::path_package("lapalombella.pu.datapkg"),
             recurse = 2,
             regexp = "bpcells_matrix_dir")
bpcells_dir
bp_paths <- fs::path_split(bpcells_dir[1]) |> unlist()
bp_paths
obj_name <- bp_paths[length(bp_paths) - 1]
obj_name
bpcells_dir
fs::path_dir(bpcells_dir)
