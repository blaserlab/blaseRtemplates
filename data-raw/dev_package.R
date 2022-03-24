# package setup
# library(usethis)
# create_package("/workspace/workspace_pipelines/blaseRtemplates")
# use_mit_license("Brad Blaser")
# use_readme_md()
# use_news_md()
# use_git()
# use_github(private = TRUE)
# use_git_ignore(c("*.rda", "configs.local.R"))
# use_package("usethis")
# usethis::use_package("fs")
# usethis::use_package("gert")
# usethis::use_package("stringr")
# usethis::use_package("prompt")
# usethis::use_package("dplyr")
# usethis::use_package("gitcreds")
# usethis::use_package("renv")
# usethis::use_package("withr")

# document
devtools::document()

# add, commit, push
gert::git_add("*")
gert::git_commit("version 0.0.0.9056")
gert::git_push()

# build and insert into repo
pkg_build <- devtools::build()

drat::insertPackage(file = pkg_build,
                    repodir = "/home/OSUMC.EDU/blas02/network/X/Labs/Blaser/share/data/R/drat/",
                    action = "archive")
