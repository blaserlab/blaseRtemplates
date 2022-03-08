
# blaseRtemplates

The goal of blaseRtemplates is to provide a skeleton for project setup based on the ```usethis``` package.

```usethis``` is great but here we expand on the idea to provide additional R scripts that are always useful to have in your project.

In addition this package provides some helpers for working with git via R.  These may be helpful for new users and convenient for experienced users.  The workflow provided in ```git_commands.R``` aims to minimize or avoid conflicts, but working in the terminal may still be necessary for complicated situations.

## Installation

You can install the development version of blaseRtemplates like so:

``` r
renv::install("blaserlab/blaseRtemplates")
```

## Example

Start a new R project like so:

``` r
blaseRtemplates::initialize_project()
```

