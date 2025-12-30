# Upgrade a Project to Use the Latest Version of BlaseRtemplates

This function converts an renv-based project to a blaseRtemplates
project using the new cache structure. Specifically, it will take the
following actions on the provided project:

1.  delete the renv folder

2.  delete the renv lock file

3.  write a new .Rprofile which in turn will

4.  create a new user_project directory. This will be the primary
    package library for the project. It will contain symlinks pointing
    to the newest versions of packages in the main cache.

5.  write a new file listing the packages actively used by the project
    into a new "library_catalogs" directory

## Usage

``` r
upgrade_bt(path, path_to_cache_root = Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"))
```

## Arguments

- path:

  path to the project to upgrade. By default will upgrade the current
  project, Default: fs::path_wd()

- path_to_cache_root:

  PARAM_DESCRIPTION, Default: Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")
