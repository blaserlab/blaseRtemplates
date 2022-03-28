# document
devtools::document()

# add, commit, push
gert::git_add("*")
gert::git_commit("version 0.0.0.9079")
gert::git_push()

dratify(pkg = ".",
        repo_dir = "~/workspace_pipelines/drat/docs",
        repo_name = "blaserlab",
        cleanup = F,
        drat_action = "prune",
        github = TRUE)

dratify(pkg = ".",
        repo_dir = "~/network/X/Labs/Blaser/share/data/R/drat",
        repo_name = "blaserlab",
        cleanup = T,
        drat_action = "archive",
        github = FALSE)
