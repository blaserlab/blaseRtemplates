# introduction ------------------------------------------------------------
# Do not source this file!
break

# These are common git commands which are scripted here for convenience.
# If you have not set up git, see the last section of the script to do so.
# If you use initialization.R to set up this project, the git_commands.R file
# will be in your gitignore.  This is encouraged because it is not helpful
# for git to be tracking this file.


# basic everyday commands for all git users -------------------------------

gert::git_add("*")
gert::git_status()
gert::git_commit("<commit message>")
gert::git_push()

# commands for collaborating via git --------------------------------------
# create a branch for your day's work
gert::git_branch_create(branch = "user_working")


gert::git_branch_checkout("user_working")

usethis::git_default_branch()

system("git updatebranch test_branch main")


# commands to configure git -----------------------------------------------
# make sure you have a github account
# https://github.com/join

# install git
## Windows ->  https://git-scm.com/download/win
## Mac     ->  https://git-scm.com/download/mac
## Linux   ->  https://git-scm.com/download/linux

# configure git in Rstudio
usethis::use_git_config(user.name = "YourName", user.email = "your@mail.com")

# create a personal access token at the github website
# set the expiration date as desired
# permissions should be set automatically
usethis::create_github_token()

# run this and enter your token at the prompt
gitcreds::gitcreds_set()

# if you have trouble accessing github, you may need to edit the .Renviron file
# this is the third usage of the term environment (sorry)
# to edit this file, run
usethis::edit_r_environ()
# if there is a line there starting GITHUB_PAT=xxx,
# it may be interfering with your credentials.  Delete it.
# press enter to generate a new line and then save
# restart R

# If you wish to collaborate via git run this command
# to encourage a smooth workflow:
blaseRtemplates::setup_git_collab()

