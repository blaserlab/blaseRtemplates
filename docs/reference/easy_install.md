# Easily Install Packages

Typically we would like to use existing copies of packages in our renv
cache, rather than taking time to re-download them all and rebuild them
all. You can specify this option with how = "link_from_cache". Providing
only the package name will install the latest available version.
Providing package @1.2.3" will install package version 1.2.3. Providing
package#hash will install a unique version of the package, identified by
the hash. You can get the package hash list with
`get_cache_binary_pkg_catalog()`.

Alternatively we may want to install a new package or update a package
from CRAN, bioconductor or another repository. Specify this with
"new_or_update".

When installing local packages from tarball files, "how" is ignored, but
an option for "tarball" is there for completeness. If "tarball" is
selected but the package is not a tarball, a message to that effect is
returned.

## Usage

``` r
easy_install(
  package,
  how = c("ask", "new_or_update", "link_from_cache", "tarball")
)
```

## Arguments

- package:

  Package you wish to install. "package name" will attempt to install
  from CRAN. "bioc::package_name" will attempt to install from
  bioconductor. "github repo owner/package" will attempt to install from
  github. Providing a file path to a tarball(.tar.gz) will move that
  package to the source cache and attempt to install from there.

- how:

  installation method. If nothing is chosen the default is to "ask",
  Default: c("ask", "new_or_update", "link_from_cache", "tarball")

## Value

will install packages and return nothing

## Examples

``` r
if (FALSE) {
if(interactive()){
 #EXAMPLE1
 easy_install("praise")
 }
}
```
