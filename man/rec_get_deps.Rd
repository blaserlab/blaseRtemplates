% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/install_2.0.R
\name{rec_get_deps}
\alias{rec_get_deps}
\title{recursively get package dependencies}
\usage{
rec_get_deps(
  needed,
  checked = character(0),
  deps = character(0),
  catalog = fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"), "dependency_catalog.tsv")
)
}
\description{
recursively get package dependencies
}
