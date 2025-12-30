# Save a monocle3 cds object on disk

CDS objects can be large and because they are normally stored in memory
this can lead to prolonged loading time and possibly system crashes. Use
this function to save a monocle cds object to disk. The expected usage
is to provide the function a cds object to save, and two directories.
These directories should be within a datapackage project, but this is
not strictly required. The extdata directory is where the cds data will
be saved. This *must* be within inst (so, inst/extdata) for it to be
installed and loaded with the data package using project_data. The data
directory is where normal .rda files are saved for typical R objects.
This will be a placeholder object with the same name. The purpose is to
permit documentation of the cds object and to mitigate namespace
conflicts. When the real object is loaded, the placeholder is
overwritten.

## Usage

``` r
save_monocle_disk(cds_disk, data_directory, extdata_directory, alt_name = NULL)
```

## Arguments

- cds_disk:

  The cds object to save to disk.

- data_directory:

  The package data directory to save to.

- extdata_directory:

  The package extdata directory to save to.

- alt_name:

  An alternative name to save the cds under. Useful if the function is
  used programmatically.

## Value

nothing

## See also

[`file_access`](https://fs.r-lib.org/reference/file_access.html),
[`path`](https://fs.r-lib.org/reference/path.html),
[`path_file`](https://fs.r-lib.org/reference/path_file.html)
[`cli_abort`](https://cli.r-lib.org/reference/cli_abort.html),
[`cli_alert`](https://cli.r-lib.org/reference/cli_alert.html)
[`convert_counts_matrix`](https://rdrr.io/pkg/monocle3/man/convert_counts_matrix.html),
[`save_monocle_objects`](https://rdrr.io/pkg/monocle3/man/save_monocle_objects.html)
[`SaveAs`](https://andrisignorell.github.io/DescTools/reference/SaveAs.html)
