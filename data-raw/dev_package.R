# document
devtools::document()

# add, commit, push
gert::git_add("*")
gert::git_commit("version 0.0.0.9074")
gert::git_push()

# build and insert into repos
blaseRtemplates::dratify(
  repo_name = "blaserX",
  repo_dir = "~/network/X/Labs/Blaser/share/data/R/drat/",
  cleanup = FALSE,
  drat_action = "archive",
  github = FALSE
)


blaseRtemplates::dratify(
  pkg = list.files("..", pattern = "blaseRtemplates.*gz", full.names = TRUE),
  repo_dir = "~/workspace_pipelines/drat/docs",
  repo_name = "blaserlab",
  cleanup = TRUE,
  drat_action = "prune",
  github = TRUE
)
