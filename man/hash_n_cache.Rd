% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/install_2.0.R
\name{hash_n_cache}
\alias{hash_n_cache}
\title{hash one or more functions and then cache them and update the catalogs.  Default permissions are set to 777.}
\usage{
hash_n_cache(
  lib_loc = .libPaths()[1],
  cache_loc = fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"), "library"),
  verbose = TRUE,
  permissions = "777"
)
}
\description{
hash one or more functions and then cache them and update the catalogs.  Default permissions are set to 777.
}
