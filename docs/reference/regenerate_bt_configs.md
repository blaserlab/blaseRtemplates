# Regenerate .Rprofile and .Renviron Files

If you have deleted or otherwise broken your .Rprofile or .Renviron
files, you may have difficulty connecting to the package cache. This
function will regenerate both for you. The existing .Rprofile must be
deleted manually. You can choose to archive the old version if you wish.
It will be replaced with the standard .Rprofile from blaseRtemplates.
The .Renviron file will be modified by removing the damaged lines and
replacing them with the correct ones. You must supply the correct file
path locations to your cache directory and project directory, otherwise
your R installation will be configured incorrectly.

## Usage

``` r
regenerate_bt_configs(cache_path, project_path)
```

## Arguments

- cache_path:

  path to the cache directory

- project_path:

  path to the projects directory

## Value

nothing

## See also

[`file_access`](https://fs.r-lib.org/reference/file_access.html),
[`path`](https://fs.r-lib.org/reference/path.html),
[`copy`](https://fs.r-lib.org/reference/copy.html),
[`path_package`](https://fs.r-lib.org/reference/path_package.html)
[`cli_abort`](https://cli.r-lib.org/reference/cli_abort.html),
[`cli_alert`](https://cli.r-lib.org/reference/cli_alert.html)
[`str_detect`](https://stringr.tidyverse.org/reference/str_detect.html),
[`str_replace`](https://stringr.tidyverse.org/reference/str_replace.html)
