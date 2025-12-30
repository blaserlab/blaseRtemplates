# Initialize A Project By Forking A Github Repo

This function wraps usethis::create_from_github, making some useful
default choices. Because this function forks the project, git will set
up the originator as an upstream remote. Using
blaseRtemplates::git_push_all will push to both the originator and the
collaborator's github.

## Usage

``` r
initialize_github(repo, dest = NULL, open = TRUE)
```

## Arguments

- repo:

  The repo to clone. Must be in the form of github_user/repo_name. If
  private, you must be a collaborator and have permission to fork the
  repo from the owner.

- dest:

  Destination directory. This directory will become the parent directory
  for the project you are forking. If NULL, the default, it will put the
  project in the directory defined by the usethis.destdir option. Set
  this in ~/.Rprofile.

- open:

  Whether to open the forked project, Default: TRUE

## Value

nothing
