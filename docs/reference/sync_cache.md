# Synchronize Project Library with Renv Cache

This function snapshots your current library, copies any packages
existing in the renv project library to the renv cache and then links
the package back into the project library. This leaves you with an
updated cache and a project library containing only symlinks, which is
usually the ideal status for your project.

## Usage

``` r
sync_cache()
```

## Value

nothing
