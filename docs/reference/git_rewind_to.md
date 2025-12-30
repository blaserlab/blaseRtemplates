# Rewind Git History

This function uses git revert to rewind history to a prior commit. First
make sure all of your changes have been committed. Then run
gert::git_log() to identify the "good" commit you want to rewind to.
Supply this as the argument to this function. A new commit will be made
with a helpful message. Commit history is not changed so you can always
rewind the rewind etc....

## Usage

``` r
git_rewind_to(commit)
```

## Arguments

- commit:

  Hash of the commit you want to rewind the state of your repository to.
  Requires a minimum of 7 characters.

## Value

a tibble with the new git commit log after rewinding

## See also

[`git_commit`](https://docs.ropensci.org/gert/reference/git_commit.html)
