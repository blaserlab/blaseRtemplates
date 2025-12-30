# Initialize a Package Using a Standard Template

This wraps
[`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html)
and adds a few additional templates.

## Usage

``` r
initialize_package(
  path,
  fields = list(),
  roxygen = TRUE,
  check_name = TRUE,
  rstudio = rstudioapi::isAvailable(),
  open = rlang::is_interactive(),
  fresh_install = FALSE,
  path_to_cache_root = Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")
=======
  rstudio = rstudioapi::isAvailable(),
  roxygen = TRUE,
  check_name = TRUE,
  open = rlang::is_interactive()
>>>>>>> Stashed changes
)
```

## Arguments

path

:   path/name for the new package. It should include letters and "."
    only to be CRAN-compliant.

fields

:   named list of fields in addition to/overriding defaults for the
    DESCRIPTION file, Default: list()

:   makes an Rstudio project, default is true

roxygen

:   do you plan to use roxygen2 to document package?, Default: TRUE

check_name

:   check if name is CRAN-compliant, Default: TRUE

:   makes an Rstudio project, default is true

open

:   to open or not, Default: rlang::is_interactive()

## See also

[`isAvailable`](https://rstudio.github.io/rstudioapi/reference/isAvailable.html)
[`is_interactive`](https://rlang.r-lib.org/reference/is_interactive.html)
[`use_template`](https://usethis.r-lib.org/reference/use_template.html)
[`defer`](https://withr.r-lib.org/reference/defer.html)
