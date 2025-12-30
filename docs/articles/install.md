# Installing Packages

## Installing one package

- Install a new package or get the latest version from a repository

``` r
blaseRtemplates::install_one_package(package = "<package_name>", how = "new_or_update")
```

- Get a fresh link to the newest version available in the cache

``` r
blaseRtemplates::install_one_package(package = "<package_name>", how = "link_from_cache")
```

- Get a specific version from the cache

``` r
blaseRtemplates::install_one_package(package = "<package_name>", how = "link_from_cache", which_version = "1.0.0.")
```

- Versioned package installations are supported for cran only. If
  unavailable, the latest version will be installed.

``` r
blaseRtemplates::install_one_package(package = "<cran_package_name>", how = "new_or_update", which_version = "1.0.0.")
```

You can find a human-readable table with all of the packages in the
cache at BLASERTEMPLATES_CACHE_ROOT/package_catalog.tsv.

You can find a human-readable table with all of the packages used by a
given project in the library_catalogs directory of the project. There is
at least one file in there. For projects collaborating through git,
there will be one for each user. These files indicate all available and
actively used packages in the R code. This file is meant to be tracked
by git and so can provide version control and reproducibility for the
packages used in your project.

## Get a new project library

You can use this function to replace the entire project library with a
new one. By default, the function will install the newest version
available.

``` r
blaseRtemplates::get_new_library()
```

Say, however, that you are collaborating on this project. Another person
may be using a different set of packages. This can in some circumstances
change output. To adopt the package library used by a different
individual, supply their project library catalog as the argument to
[`get_new_library()`](../reference/get_new_library.md).

``` r
blaseRtemplates::get_new_library("library_catalogs/<file>.tsv")
```

These files are created in a structured way; the files should always be
named \_.tsv. Therefore they should never cause git conflicts. You can
use a simple anti_join to preview the differences between two project
library catalogs.

``` r
my_lib <- readr::read_tsv("library_catalogs/<my_file>.tsv")
their_lib <- readr::read_tsv("library_catalogs/<their_file>.tsv")
dplyr::anti_join(my_lib, their_lib, by = c("name", "version")))
```
