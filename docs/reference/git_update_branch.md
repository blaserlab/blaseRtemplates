# Update a Working Git Branch

This function updates a git branch via rebase from a default upstream
branch (usually "main"). You can explicitly provide the names of your
working branch and the default upstream branch. If not provided, the
function will use the current branch as your working branch and will
automatically identify the default upstream branch. Internally this
calls a system file that must be installed using
blaseRtemplates::setup_git_collab(). The upstream branch also needs to
be connected to a remote (e.g. github).

## Usage

``` r
git_update_branch(branch = NULL, upstream = NULL)
```

## Arguments

- branch:

  The working branch you wish to update, Default: NULL

- upstream:

  The default upstream branch you wish to update from, Default: NULL

## Value

nothing

## See also

[`git-default-branch`](https://usethis.r-lib.org/reference/git-default-branch.html)
[`git_branch`](https://docs.ropensci.org/gert/reference/git_branch.html),[`git_stash`](https://docs.ropensci.org/gert/reference/git_stash.html)
