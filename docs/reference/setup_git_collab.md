# Install Scripts to Support Git Collaboration

This function installs two scripts that bundle git commands to help
avoid conflicts. gitupdatebranch switches from working branch to main,
updates from remote, then rebases working branch. Git safemerge swtiches
to main and pulls before merging. Both scripts are written to
~/.local/bin and the global git config is edited to provide these
aliases: git updatebranch, git safemerge.

## Usage

``` r
setup_git_collab()
```

## Value

nothing
