# after running the initialization command, run these lines once to set up
# your project in a consistent manner.
# private github repos can be made public via the web interface

use_mit_license("<your name here>")
use_readme_md()
use_news_md()
use_git()
use_github(private = TRUE)
use_git_ignore(c("*.rda", "configs.local.R"))
