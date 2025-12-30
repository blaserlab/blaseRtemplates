# Install One Package

Use this to install a new package. Choosing "new_or_update" will go to
the package repository, get the latest version of the software, install
into your cache and link to your project library. Choosing
"link_from_cache" will get you the latest version in the cache, for
example if another user has added a new package you want, but you don't
want to update the whole library. Also, use this option with either
"which_version" or "which_hash" to install specific versions. When
installing via "new_or_update" it is possible to specify the permissions
for the cached package. Default for this is 777. =======

Use this to install a new package. Choosing "new_or_update" will go to
the package repository and get the latest version of the software.
Choosing "link_from_cache" will get you the latest version in the cache,
for example if another user has added a new package you want, but you
don't want to update the whole library. Also, use this option with
either "which_version" or "which_hash" to install specific versions.

\>\>\>\>\>\>\> Stashed changes

## Usage

``` r
install_one_package(
  package,
  how = c("ask", "new_or_update", "link_from_cache", "tarball"),
  which_version = NULL,
  which_hash = NULL,
  permissions = "777"
=======
  which_hash = NULL
>>>>>>> Stashed changes
)
```

## Arguments

package

:   Package name or path to tarball. Prefix with "repo\\" for github
    source packages and "bioc::" for bioconductor.

how

:   How to install the package, Default: c("ask", "new_or_update",
    "link_from_cache", "tarball")

which_version

:   Package version to install, Default: NULL

which_hash

:   Package hash to install, Default: NULL

:   Permissions for the package if installing a new version in the
    cahce. Default: 777

## Value

nothing
