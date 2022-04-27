# document
devtools::document()

# add, commit, push
gert::git_add("*")
gert::git_commit("version 0.0.0.9093")
gert::git_push()

pak::pk("blaserlab/blaseRtemplates")

