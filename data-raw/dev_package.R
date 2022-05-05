# renv::activate()
# renv::init(project = "/workspace/brad_workspace/blaseRtemplates", bioconductor = TRUE)

# document
devtools::document()

# add, commit, push
gert::git_add("*")
gert::git_commit("version 0.0.0.9095")
gert::git_push()


