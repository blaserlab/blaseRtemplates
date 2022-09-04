devtools::load_all()

test_that("initialize works", {
  initialize_project(path = ("~/temp_proj13"), open = F)
  usethis::with_project("~/temp_proj", code = {
    .libPaths()
  })

  })
