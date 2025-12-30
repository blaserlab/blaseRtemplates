# Get A New Project Library

Use this to replace the current symlinked library with a new version. By
default, the function will link to the newest version of all packages
available in the cache. Alternatively, identify another project library
catalog to replace the current version.

## Usage

``` r
get_new_library(newest_or_file = "newest")
```

## Arguments

- newest_or_file:

  Which set of packages to symlink, Default: 'newest'

## Value

Uninstalled packages hashes.
