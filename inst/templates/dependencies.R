
# renv --------------------------------------------------------------------

# set up the renv from scratch

# renv::init()

# restore the renv from the lockfile

# renv::restore()

# save the current renv to the lockfile

# renv::snapshot()


# package installation ----------------------------------------------------

# use renv::hydrate() to link packages already in your cache into this project
# use renv::install() to update or install new packages and then link them

# renv::hydrate("<package name>")
# renv::install("<package name>") # CRAN packages
# renv::install("bioc::<package name>") # bioconductor packages
# renv::install("<repo/package name>") # github source packages

# load and attach packages ------------------------------------------------

library("conflicted")
library("tidyverse")
library("gert")

# install and load data package if using ----------------------------------------------
# requires installation of blaseRtools

# bb_renv_datapkg(path = "<path to data package directory>")
# lazyData::requireData("<data package name>")

