# Safely Merge your Working Branch

This function updates default branch (usually "main") from remote. This
pulls in any changes from other contributors. Then it merges the working
branch into the upstream branch.

## Usage

``` r
git_safe_merge(branch = NULL, upstream = NULL)
```

## Arguments

- branch:

  The working branch you wish to merge, Default: NULL

- upstream:

  The default upstream branch you wish to merge into, Default: NULL

## Value

nothing

## See also

[`git-default-branch`](https://usethis.r-lib.org/reference/git-default-branch.html)
[`git_branch`](https://docs.ropensci.org/gert/reference/git_branch.html),[`git_commit`](https://docs.ropensci.org/gert/reference/git_commit.html)
