
# renv --------------------------------------------------------------------

# set up the renv from scratch

# renv::init()

# restore the renv from the lockfile

# renv::restore

# save the current renv to the lockfile

# renv::snapshot()


# package installation ----------------------------------------------------
# suggested minimum list of packages to install

# renv::install("conflicted")
# renv::install("tidyverse")
# renv::install("gert")
# renv::install("gitcreds")
# renv::install("usethis")
# renv::install("blaserlab/blaseRtemplates")

# load and attach packages ------------------------------------------------

library("conflicted")
library("tidyverse")


# install and load data package if using ----------------------------------------------
# requires installation of blaseRtools

# bb_renv_datapkg(path = "<path to data package directory>")
# lazyData::requireData("baiocchi.long.datapkg")

