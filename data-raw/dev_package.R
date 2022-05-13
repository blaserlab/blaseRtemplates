# renv::activate()
# renv::init(bioconductor = TRUE)

# document
devtools::document()

# add, commit, push
gert::git_add("*")
gert::git_commit("version 0.0.0.9106")
gert::git_push()

renv::install("blaserlab/blaseRtemplates", library = "/opt/R/4.2.0/lib/R/library", type = "binary")

