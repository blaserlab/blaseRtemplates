# Easily restore a project from an RENV Lockfile

Reads the project lockfile or another lockfile supplied as an argument.
Then attempts to link to a binary version of each package in the cache.
If unavailable it will attempt to link to the newest version in the
cache. If that is unavailable it will install the package from the
available repositories.

## Usage

``` r
easy_restore(lockfile = "default")
```

## Arguments

- lockfile:

  Optional non-default lock file to restore from. Otherwise will use
  "renv.lock", Default: 'default'

## Value

Nothing

## See also

[`fromJSON`](https://rdrr.io/pkg/rjson/man/fromJSON.html)
[`map`](https://purrr.tidyverse.org/reference/map.html)
