# recursively get package dependencies

recursively get package dependencies

## Usage

``` r
rec_get_deps(
  needed,
  checked = character(0),
  deps = character(0),
  catalog = fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"), "dependency_catalog.tsv")
)
```
