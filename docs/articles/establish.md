# Establish a blaseRtemplates Installation

## Introduction

The goals of blaseRtemplates are:

1.  To establish an encapsulated computing environment for data analysis
    in R.

2.  To improve upon existing methods for installing software packages
    and maintaining version control

3.  To provide useful template scripts for setting up projects, working
    with git, and doing other common, repetitive tasks.

The result, I hope, will be reduced system footprint (storage), faster
package installation times, better reproducibility and an overall
improved user experience.

## Establishing an Installation

Unfortunately, the terms we use for setting up programs, files and
directories are overloaded. To distinguish the initial installation of
the directory structure for blaseRtemplates from other uses of the verb
“install”, I use the term “establish”. Sorry if that seems awkward.

First you must install the blaseRtemplates package using whatever
package installer you currently use. Assuming the base install function,
run:

``` r
install.packages('blaseRtemplates', repos = c('https://blaserlab.r-universe.dev', 'https://cloud.r-project.org'))
```

What is r-universe? Basically it is CRAN without rules. In this case, it
hosts blaseRtemplates linux source code and pre-compiled binaries for
Windows and Mac.

Next, simply run the following command:

``` r
library("blaseRtemplates")
establish_new_bt(cache_path = "<some_directory>/r_4_2_cache", project_path = "<some_directory>/projects")
```

What will this do?

- It will create directories where indicated, write a standard .Rprofile
  document, and modify the user .Renviron file to configure R
  properly.  
- It will not overwrite existing directories and will fail when an
  existing installation is already present in the same location.  
- The only modification outside of the provided directory is to the
  .Renviron file. If you have existing configurations in your .Renviron
  file, they will only be changed if they are conflicting. If this is
  problematic, then you should archive your .Renviron file before
  running. The new .Renviron file will cause R to use the new .Rprofile
  in the cache directory and skip existing user- and project-level
  .Rprofiles.

Briefly, when R starts a new session, it looks for a series of files to
configure itself. This configuration includes environment variables (in
the .Renviron file) and any desired R code (in the .Rprofile file). As
included in this function, these configurations only affect user
experience i.e. they should not affect the results produced by your
code. By user experience I mean connection to the proper package
libraries and repositories and some safeguards to prevent working
outside of projects.

For more information on how R starts, see [this
link.](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html "R startup").

## Directory Structure

    .
    |-- projects
    |   `-- baseproject
    `-- r_4_2_cache
        |-- library
        |-- logs
        |-- source
        |-- user_project
        |-- dependency_catalog.tsv
        |-- package_catalog.tsv
        `-- .Rprofile

First, note that two main subdirectories have been created in one parent
directory. This optional and can be specified by the function inputs,
but for a single user system it is recommended to keep them together for
the sake of organization.

- projects: where your projects should be initialized. They can go
  anywhere but you should keep them here. The baseproject is created by
  the establish_new_bt function. If you close a project without moving
  to a new one or try to start a session outside of a project, it will
  bounce you here. This prevents undesired operations in e.g. the home
  directory or elsewhere.

- r_4_2_cache: This holds all of the inner workings of the
  blaseRtemplates system.

  - library: The versioned/hashed package binary cache. Each package is
    stored under the following rubric: name \> version \> hash \> name
    \> contents. This structure is generated whenever blaseRtemplates
    installs a new package in any project.

  - logs: collection of .Rhistory files. Rather than 1 endless file
    (default), blaseRtemplates will store history files for each session
    by user and date/time

  - source: Package source files. Used by the installer, pak.

  - user_project: A collection of symlinks to versioned/hashed packages
    in the library. This is identified as the first entry in .libPaths()
    so it is where R looks first for packages. Why do this? 1. It allows
    reproducibility. If I update a package for one project, it may break
    something in an older project. This allows each project to have its
    own set of packages. (The list of what versions are used is kept as
    a tsv file within the project, so it is completely portable. Anyone
    who wants to replicate your code just has to install that list of
    packages.) 2. It makes the system lightweight. Package code and more
    significantly, data, is stored in one location and accessible to
    many projects, according to version. Unlike renv, all of this except
    the tsv file is done outside the project, so there are no broken
    links or large binaries to transfer if someone else wants to work
    with your code.

  - dependency_catalog.tsv: a list of package dependencies by package
    hash. Speeds up installation when linking packages from the cache to
    a project.

  - package_catalog.tsv: the master catalog of packages available in the
    cache.

  - .Rprofile: the Rprofile used on startup, as specified by the new
    .Renviron file

The library directory is initially populated using all packages
available to R the local libraries. Depending on what is in those
libraries, and processing/network speeds, this may take some time.

## Upgrading R versions

Since package binaries don’t work across minor version changes in R,
e.g. 4.2 -\> 4.3, you will have to create a new cache directory each
time this changes.
