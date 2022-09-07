# Set the blaseRtemplates cache as an environment variable.
Sys.setenv("BLASERTEMPLATES_CACHE_ROOT" = "/workspace/rst/cache_R_4_2")

# Set the project libraries.
.libPaths(c("/workspace/rst/cache_R_4_2/user_project/blas02/blaseRtemplates", .libPaths()[2]))

# set default git protocol to https
options(usethis.protocol  = "https")



# Enable universe(s) by blaserlab
options(repos = c(
  blaserlab = 'https://blaserlab.r-universe.dev',
  CRAN = 'https://cloud.r-project.org'))

if (file.exists("~/.Rprofile")) source("~/.Rprofile")

