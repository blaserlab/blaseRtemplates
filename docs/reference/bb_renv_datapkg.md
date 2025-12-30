# Install Or Update A Local R Data Package

If a directory is specified, this function will compare the currently
installed version to the latest available version in the directory. If
there is a newer version available (based on version number), it will
install this version. If a tarball is specifically requested it will
install that one. If the package hasn't ever been installed, it will
install the newest version.

## Usage

``` r
bb_renv_datapkg(path)
```

## Arguments

- path:

  Path to a directory containing one or more versions of the same data
  package.

## Value

noting

## See also

[`safely`](https://purrr.tidyverse.org/reference/safely.html),[`map`](https://purrr.tidyverse.org/reference/map.html)
[`str_detect`](https://stringr.tidyverse.org/reference/str_detect.html),[`str_glue`](https://stringr.tidyverse.org/reference/str_glue.html),[`str_split`](https://stringr.tidyverse.org/reference/str_split.html),[`str_replace`](https://stringr.tidyverse.org/reference/str_replace.html),[`str_sub`](https://stringr.tidyverse.org/reference/str_sub.html)
[`install`](https://rstudio.github.io/renv/reference/install.html)
[`as_tibble`](https://tibble.tidyverse.org/reference/as_tibble.html)
[`filter`](https://dplyr.tidyverse.org/reference/filter.html),[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html),[`slice`](https://dplyr.tidyverse.org/reference/slice.html),[`pull`](https://dplyr.tidyverse.org/reference/pull.html)
