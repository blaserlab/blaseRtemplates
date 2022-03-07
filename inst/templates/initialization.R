# after running the initialization command, run these lines once to set up
# your project in a consistent manner.
# private github repos can be made public via the web interface

# make a software license
usethis::use_mit_license("<your name here>")

# generate a readme file to explain your work
usethis::use_readme_md()

# generate a news file to document updates to your package
usethis::use_news_md()

# initialize git
usethis::use_git()

# initialize github
usethis::use_github(private = TRUE)

# modify git ignore file
usethis::use_git_ignore(c("*.rda", "local_configs.R"))

### Delete this file after initializing the project! ###
