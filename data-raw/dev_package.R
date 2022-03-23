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
gert::git_commit("version 0.0.0.9047")
gert::git_push()

# install
blaseRtemplates::easy_install("blaserlab/blaseRtemplates", how = "new_or_update")
