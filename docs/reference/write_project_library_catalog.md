# Write A New Project Library Catalog

In the current version of blaseRtemplates, the package library is cached
at the location designated by the environment variable
"BLASERTEMPLATES_CACHE_ROOT". There is a single cache for all users and
projects. The cache holds the binary software used by each package. The
packages for each project are connected to the cache by symlinks. The
cache is versioned so that different projects can use different versions
if desired. Use this function to write a tab-delimited file listing the
packages used by each project.

This file will be written to the "library_catalogs" directory within
each project. The filename incorporates the user name so everyone
working on the project will have their own. Use
[`get_new_library()`](get_new_library.md) to adopt a new version of all
packages

## Usage

``` r
write_project_library_catalog()
```

## Value

returns nothing
