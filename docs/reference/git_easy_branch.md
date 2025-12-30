# Easily Create or Switch Git Branches

Supply this function with a branch name. If the branch exists it will
switch to the branch. If not, it will pull any changes from remote and
then create the branch. Any uncommitted work will be carried over to the
new branch in the same state. Avoid repeatedly switching branches with
work in different states of completion since this may cause conflicts

## Usage

``` r
git_easy_branch(branch)
```

## Arguments

- branch:

  A character string with the branch name to create or switch to.

## Value

nothing
[`git_branch`](https://docs.ropensci.org/gert/reference/git_branch.html)
