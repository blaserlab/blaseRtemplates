# document
devtools::document()

# add, commit, push
gert::git_add("*")
gert::git_commit("version 0.0.0.9073")
gert::git_push()

# build and insert into repo
blaseRtemplates::dratify(repo_name = "blaserX", repo_dir = "~/network/X/Labs/Blaser/share/data/R/drat/")
getOption("dratRepo")
drat::insertPackage(file = "~/network/X/Labs/Blaser/share/data/R/drat/src/contrib/blaseRtemplates_0.0.0.9072.tar.gz", repodir = "~/workspace_pipelines/drat", action = "prune", commit = "test commit", location = "docs")
drat::insertPackage

# test
dratify(pkg = "~/network/X/Labs/Blaser/share/data/R/drat/src/contrib/blaseRtemplates_0.0.0.9072.tar.gz",
        repo_dir = "~/workspace_pipelines/drat/docs",
        repo_name = "blaserlab",
        cleanup = F,
        drat_action = "prune",
        github = TRUE)
