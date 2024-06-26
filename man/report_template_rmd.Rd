% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/templates.R
\name{report_template_rmd}
\alias{report_template_rmd}
\title{Make an Rmd Report from the Saved Template}
\usage{
report_template_rmd(report_name = NULL)
}
\arguments{
\item{report_name}{Name for the Rmd file, Default: NULL}
}
\value{
Returns nothing
}
\description{
Shortcut function to save the blaseRtemplates report template in Rmd format within an Rmd folder.
}
\details{
Makes a new Rmd file with the supplied file name
}
\seealso{
\code{\link[stringr]{str_detect}}
\code{\link[cli]{cli_alert}}
\code{\link[fs]{create}}, \code{\link[fs]{path}}
\code{\link[usethis]{use_template}}
}
