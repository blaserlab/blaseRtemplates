# Upgrading a Project to use blaseRtemplates

## Upgrade a project

You may wish to convert an existing project (possibly using *renv*) to a
project that uses the new blaseRtemplates cache.

To do this, run:

``` r
blaseRtemplates::upgrade_bt("/path/to/project")
```

This will

1.  Remove the renv documents and library
2.  Create a new user_project folder and give you all of the newest
    versions available of all packages in your cache.
3.  Remove your project-level .Rprofile if present.
4.  Remove your project-level .Renviron if present.
5.  Give you a new .gitigore.
