# Managing Project Data

## Handling Project Data

Data packages are an excellent way to guarantee portability and
reproducibility of your work. Think of packaging your data as a gift to
your future self. Typically data packages hold processed data that can
be used to generate some useful output with a minimum of computational
resources and without the introduction of non-reproducible calculations
(e.g. UMAP dimensions, though you can also store the underlying UMAP
models in some cases.) Although it is possible to package raw data, this
is not strictly necessary and is impractical for things like fastq
files, bam files etc.

Even after processing, a project data package can still be several GB or
more in size. To use these data in an R session, the data package has to
be attached and the data objects have to be loaded into memory. This can
take a few minutes for large data packages. If you really need
everything in the data package every time, you will just have to wait,
but usually this isn’t the case. BlaseRtemplates uses the lazyData
package to work around this. (Normally R can “lazy load” data but there
is a size limit which is avoided by lazyData). Run this function to
install, update, and load package data:

``` r
blaseRtemplates::project_data("/path/to/directory/containing/data_package")
```

This function:

1.  Goes to the supplied directory.
2.  Checks for the latest version of the package according to the
    standard version numbering scheme.
3.  Compares this version to the installed version in the cache and in
    the project library.
4.  Updates cache and/or project library to the newest version if and
    only if necessary.
5.  If a specific version of the data package is supplied,
    e.g. \*1.0.1.tar.gz, it will install and load that one. This allows
    installation of old versions of data.
6.  Loads the package into a hidden environment as a pointer, from where
    each object is loaded into memory only when called.

This function should be executed together with all library calls for
your project. See dependencies.R.
