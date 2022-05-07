# renv::activate()
# renv::init(bioconductor = TRUE)

# document
devtools::document()

# add, commit, push
gert::git_add("*")
gert::git_commit("version 0.0.0.9102")
gert::git_push()

blaseRtemplates::easy_install("blaserlab/blaseRtemplates", "new_or_update")


