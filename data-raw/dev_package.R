# document
devtools::document()

# add, commit, push
gert::git_add("*")
gert::git_commit("version 0.0.0.9064")
gert::git_push()

# build and insert into repo
blaseRtemplates::dratify(repo_name = "blaserX", repo_dir = "~/network/X/Labs/Blaser/share/data/R/drat/")
