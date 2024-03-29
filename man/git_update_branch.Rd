% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/git_functions.R
\name{git_update_branch}
\alias{git_update_branch}
\title{Update a Working Git Branch}
\usage{
git_update_branch(branch = NULL, upstream = "main")
}
\arguments{
\item{branch}{The working branch you wish to update, Default: NULL}

\item{upstream}{The default upstream branch you wish to update from, Default: NULL}
}
\value{
nothing
}
\description{
This function updates a git branch via rebase from a default upstream branch (default is "main").  You can explicitly provide the names of your working branch and the default upstream branch.
}
\seealso{
\code{\link[usethis]{git-default-branch}}
\code{\link[gert]{git_branch}},\code{\link[gert]{git_stash}}
}
