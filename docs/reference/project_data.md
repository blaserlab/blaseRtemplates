# Activate Project Data

Use this to update, install and/or load project data. Usual practice is
to provide the path to a directory holding data package tarballs. This
function will find the newest version, compare that to the versions in
the cache and used in the package and give you the newest version.
Alternatively, provide the path to a specific .tar.gz file to install
and activate that one.

If a specific version is requested, i.e. a specific .tar.gz file, and
this version is already cached, it will be linked and not reinstalled.
If for some reason there are multiple hashes with the same version
number (usually because a package was rebuilt without incrementing the
version), then the latest hash of that version will be linked.

This function accepts multiple paths, i.e. multiple independent data
packages, in the form of a character vector of length \>= 1. After
deciding which version to install based on the inputs, the function will
load all of the data objects into a single environment called
deconflicted.data. The problem with loading multiple data packages into
the same environment is that there may be name conflicts and objects get
overridden. The problem with keeping them in separate environments is
that they are difficult to specify and access. Here is how this function
deals with these problems:

- If `length(path) > 1`, the function will require a vector for the
  argument deconflict_string of the same length. The first element of
  deconflict_string will be added as a suffix to the data object from
  the first package in path, etc. For example if the first value of the
  argument deconflict_string is ".my.project.data", then all objects in
  the package will be suffixed with .my.project.data.

- Note that you will have to reference the object correctly in your code
  using the proper suffix.

- Also note that all of the elements of deconflict_string must be
  unique. But an empty string, i.e. "", is also a valid input which
  means that all of the names of the data objects from that package will
  be unchanged. This is helpful if you have a lot of code using one data
  package but at a later time decide you need to add a different data
  package. Make the deconflict string `c("", ".my.new.data")` and you
  don't have to change any of your old code.

- Make sure you include a separator like . or \_ but not a space as the
  first character of each element of deconflict_string.

- If only a single package is loaded, there will be no conflicts and by
  default, deconflict_string is set to "".

As before, all data elements are loaded as promises which means that
they are loaded into memory only when called.

Since version 9211, this function also handles on-disk storage for
monocle3 cds objects. If such an object is detected within extdata, it
will be loaded into the same deconflicted.data environment using the
functions provided by monocle.

## Usage

``` r
project_data(path, deconflict_string = "")
```

## Arguments

- path:

  Path or vector of paths to data directory/ies.

- deconflict_string:

  Character vector used to disambiguate objects from packages in path,
  Default: ”

## Value

loads data as promises as a side effect

## See also

[`cli_abort`](https://cli.r-lib.org/reference/cli_abort.html),
[`cli_alert`](https://cli.r-lib.org/reference/cli_alert.html)
[`read_delim`](https://readr.tidyverse.org/reference/read_delim.html),
[`cols`](https://readr.tidyverse.org/reference/cols.html)
[`path`](https://fs.r-lib.org/reference/path.html),
[`path_file`](https://fs.r-lib.org/reference/path_file.html)
[`pmap`](https://purrr.tidyverse.org/reference/pmap.html),
[`map`](https://purrr.tidyverse.org/reference/map.html)
[`str_detect`](https://stringr.tidyverse.org/reference/str_detect.html),
[`str_extract`](https://stringr.tidyverse.org/reference/str_extract.html),
[`str_remove`](https://stringr.tidyverse.org/reference/str_remove.html),
[`str_replace`](https://stringr.tidyverse.org/reference/str_replace.html)
[`filter`](https://dplyr.tidyverse.org/reference/filter.html),
[`pull`](https://dplyr.tidyverse.org/reference/pull.html),
[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html),
[`slice`](https://dplyr.tidyverse.org/reference/slice.html)
[`as_tibble`](https://tibble.tidyverse.org/reference/as_tibble.html)
