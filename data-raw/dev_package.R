# renv::init()

# document
devtools::document()

# add, commit, push
gert::git_add("*")
gert::git_commit("version 0.0.0.9094")
gert::git_push()

pak::pkg_install("blaseRtemplates", lib = "/home/OSUMC.EDU/blas02/.cache/R/renv/library/blaseRtemplates-f5bc625c/R-4.2/x86_64-pc-linux-gnu")
pak::pkg_install("blaseRtemplates", lib = "/opt/R/4.2.0/lib/R/library")

