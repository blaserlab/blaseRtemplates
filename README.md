# blaseRtemplates

This is a test.
## Installation

blaseRtemplates is available on our R-Universe repository.

You can install the latest version of blaseRtemplates like so:

``` r
install.packages('blaseRtemplates', repos = c('https://blaserlab.r-universe.dev', 'https://cloud.r-project.org'))
```

Linux, mac and windows-compatible versions are available.

## Quick-Start Guide

1.  Establish a new installation of the blaseRtemplates directory structure.
    -   will also modify the user-level .Renviron file

``` r
blaseRtemplates::establish_new_bt(cache_path = "<path/to/directory>/cache_r_4_2",
                                  project_path = "<path/to/directory>/projects")
```

1.  Switch to the new baseproject using the Rstudio project chooser.

2.  Initialize a new project in the same projects directory:

``` r
blaseRtemplates::initialize_project(path = "../project_name")
```

## For more information

See linked articles on:

-   [establishing a new installation of blaseRtemplates for a single user](https://blaserlab.github.io/blaseRtemplates/articles/establish.html)
-   [establishing a multi-user blaseRtemplates installation](https://blaserlab.github.io/blaseRtemplates/articles/multiuser.html)
-   [initializing projects (de novo and from github)](https://blaserlab.github.io/blaseRtemplates/articles/initialize.html)
-   [installing packages](https://blaserlab.github.io/blaseRtemplates/articles/install.html)
-   [managing project data](https://blaserlab.github.io/blaseRtemplates/articles/project_data.html)
-   [using git](https://blaserlab.github.io/blaseRtemplates/articles/using_git.html)
