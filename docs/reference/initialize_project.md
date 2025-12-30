# Create a package or project using a structured template

These functions create an R project:

- `create_project()` creates a non-package project, i.e. a data analysis
  project

Both functions can be called on an existing project; you will be asked
before any existing files are changed.

This function is a modification of usethis::create_project

## Usage

``` r
initialize_project(
  path,
  rstudio = rstudioapi::isAvailable(),
  open = rlang::is_interactive(),
  fresh_install = FALSE,
  path_to_cache_root = Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")
)
```

## Arguments

- path:

  A path. If it exists, it is used. If it does not exist, it is created,
  provided that the parent path exists.

- rstudio:

  If `TRUE`, calls
  [`usethis::use_rstudio()`](https://usethis.r-lib.org/reference/use_rstudio.html)
  to make the new package or project into an [RStudio
  Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects).

- open:

  If `TRUE`,
  [activates](https://usethis.r-lib.org/reference/proj_activate.html)
  the new project:

  - If RStudio desktop, the package is opened in a new session.

  - If on RStudio server, the current RStudio project is activated.

  - Otherwise, the working directory and active project is changed.

## Value

Path to the newly created project or package, invisibly.
