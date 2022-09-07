
# blaseRtemplates

The goal of blaseRtemplates is to provide a skeleton for project setup based on the ```usethis``` package.

```usethis``` is great but here we expand on the idea to provide additional R scripts that are always useful to have in your project.

This package provides some helpers for working with git via R.  These may be helpful for new users and convenient for experienced users.  The workflow provided in ```git_commands.R``` aims to minimize or avoid conflicts, but working in the terminal may still be necessary for complicated situations.

New from versions 0.0.0.0125 onward I have implemented a new cache structure.  The cacheing approach is similar to renv.  However the system of reconciliation between versions is much more straightforward.  In addition, by default when starting a new project, you will automatically have the latest versions of all packages available to you.  All project-specific libraries are symlinked to the main cache to save disk space.

See below for minimal examples

## Installation

You can install the development version of blaseRtemplates like so:

``` r
options(repos = c(
  blaserlab = 'https://blaserlab.r-universe.dev',
  CRAN = 'https://cloud.r-project.org'))

install.packages("blaseRtemplates")
```

## Initial configuration

Edit your .Renvironment file to set up the blaseRtemplates cache.  If you are a system administrator, edit the Renviron.site file:

```
BLASERTEMPLATES_CACHE_ROOT=<a convenient directory>
R_PKG_CACHE_DIR=<same as BLASERTEMPLATES_CACHE_ROOT>/pkgcache
```

This will set up the blaseRtemplates cache folder and will tell ```pak``` where to cache source files.  Then run:

``` r
dir.create(file.path(<same as BLASERTEMPLATES_CACHE_ROOT>, "library"))
```

Restart R.

## Initialize a New Project

``` r
blaseRtemplates::initialize_project(path = </path/to/project>)
```

If you have already set up the cache, the new projet will automatically have access to the latest version of all packages in the cache.  

If you have not set up the cache, you will have a list of 130 or so packages which are all the recursive dependencies of ```blaseRtemplates```.  You will want to install a long list of packages which you have already been using.  See the next section for how to install new packages.


## Install a new package

This is how you install a single package:

``` r
# install a new package or get the latest version from a repository

blaseRtemplates::install_one_package(package = "<package_name>", how = "new_or_update")

# get a fresh link to the newest version available in the cache

blaseRtemplates::install_one_package(package = "<package_name>", how = "link_from_cache")

# get a specific version in the cache

blaseRtemplates::install_one_package(package = "<package_name>", how = "link_from_cache", which_version = "1.0.0.")

```

You can find a human-readable table with all of the packages in the cache at BLASERTEMPLATES_CACHE_ROOT/package_catalog.tsv.

Use this trick to install a long list of packages which you may have been using:

``` r
packages_to_install <- c(<vector of package names>)

safely_install <- purrr::safely(blaseRtemplates::install_one_package)
  
installation <- purrr::map(
  .x = packages_to_install,
  .f = \(x) safely_install(x, how = "new_or_update")
  )

transposed_installation <- purrr::transpose(installation)

uninstalled <- purrr::map2_chr(.x = transposed_installation$error,
            .y = packages_to_install,
            .f = \(x, y) {
              if (!is.null(x)) {
                return(y)
              } else {
                return("ok")
              }
            }
)
uninstalled <- uninstalled[uninstalled != "ok"]
```

The code above will install your list of packages and capture error messages from those that fail to install.  Uninstalled will give you those package names.  These are likley going to be base packages which are not distributed in CRAN and you don't need to cahce or packages from non-standard repositories or local source files which you will have to install manually.

## Get a new project library

You can use this function to replace the entire project library with a new one.  By default, the function will install the newest version available.  After doing so it will generate a new project library catalog.  This is a tsv file that lives within the project.  It indicates all available and actively used packages, based on ```library()``` and ```package::``` calls in the R code.  This file is meant to be tracked by git and so can provide version control and reproducibility for the packages used in your project.

``` r
blaseRtemplates::get_new_library()
```

Say, however, that you are collaborating on this project.  Another person may be using a different set of packages.  This can in some circumstances change output.  To adopt the package library used by a different individual, supply this as the argument to ```get_new_library()```.

``` r
blaseRtemplates::get_new_library("other_user_projet.tsv")
```

These files are created in a structured way; the files should always be named <user>_<project>.tsv.  Therefore they should never cause git conflicts.  You can use a simple anti_join to preview the differences between two project library catalogs.

``` r
my_lib <- readr::read_tsv()
their_lib <- readr::read_tsv()
anti_join(my_lib, their_lib, by = c("name", "version")))
```
## Project Data Packages

BlaseRtemplates handles project data in slightly differnt way than regular packages.  Run this function to install, update, and load package data:

``` r
blaseRtemplates::project_data("/path/to/directory/containing/data_package")
```

This function:

1. Goes to the supplied directory.
2. Checks for the latest version of the package according to the standard version numbering scheme.
3. Compares this version to the installed version in the cache and in the project library.
4. Updates cache and/or project library to the newest version if and only if necessary.
5. If a specific version of the data package is supplied, e.g. *1.0.1.tar.gz, it will install and load that one.  This allows installation of old versions of data.  Note however, it may be faster in this case to install from the cache if it is present there using ```install_one_package()```.
6. Loads the package into a hidden environment as a pointer, from where it is loaded into memory only when called.  

This function should be executed together with all library calls for your project.  See dependencies.R.

## Upgrade a project

You may wish to convert an existing project to a project that uses the new blaseRtemplates cache.

To do this, run:

``` r
blaseRtemplates::upgrade_bt("/path/to/project")
```
This should will remove teh renv documents, create a new user_project folder and give you all of the newest versions available of all packages.  

In order to avoid conflicts, you need to stop tracking your .Rprofile document.  Activate the project, go to the terminal and run this command:

```
git rm --cached .Rprofile
```



