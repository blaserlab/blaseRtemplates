
# renv --------------------------------------------------------------------

# set up the renv from scratch

# renv::init()

# restore the renv from the lockfile

# renv::restore()

# save the current renv to the lockfile

# renv::snapshot()


# package installation ----------------------------------------------------

# blaseRtemplates::easy_install("<package name>", how = "new_or_update")
# blaseRtemplates::easy_install("<package name>", how = "link_from_cache") # faster
# blaseRtemplates::easy_install("/path/to/tarball.tar.gz")

# # use "bioc::<package name>" for bioconductor packages
# # use "<repo/package name>" for github source packages

# load and attach packages ------------------------------------------------

library("blaseRtemplates")
library("conflicted")
library("tidyverse")
library("gert")

# install and load data package if using ----------------------------------------------
# requires installation of blaseRtools

# bb_renv_datapkg(path = "<path to data package directory>")
# lazyData::requireData("<data package name>")

