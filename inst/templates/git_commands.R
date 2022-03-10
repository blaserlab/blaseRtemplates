# introduction ------------------------------------------------------------
#
# Do not source this file!
break
#
# These are common git commands which are scripted here for convenience.
# If you have not set up git, see the last section of the script to do so.
# If you use initialization.R to set up this project, the git_commands.R file
# will be in your gitignore.  This is encouraged because it is not helpful
# for git to be tracking this file.

# comment or uncomment the code blocks as desired.

# basic everyday commands for all git users -------------------------------

gert::git_status()
gert::git_add("*")
gert::git_commit("<commit message>")
blaseRtemplates::git_push_all()

# run these commands to rewind to a prior "good" commit ----------------------

# make sure git status is "clean" (all changes committed) before rewinding
# gert::git_log() #find the id of the good commit
# blaseRtemplates::git_rewind_to(commit = "<good commit id>")



# # commands for collaborating via git --------------------------------------

# # Run once per user to collaborate smoothly -------------------------------

# blaseRtemplates::setup_git_collab()



# # Run these commands to set remote repositories as necessary --------------

# # Case 1:  You forked the originator's repository.
# #          You should have cloned the repository from
# #          https://github.com/<orignator>/<repo>.git
# gert::git_remote_add("https://github.com/<your username>/<repo>.git", name = "forked_<your username>")
# #
# # Case 2:  You are the originator.
# #          You want to push to a collaborator's site to keep them in sync
# gert::git_remote_add("https://github.com/<collaborators username>/<repo>.git, name = "forked_<collaborators username>")
# #
# # In both cases these commands will err if the github sites do not exist or
# # if you do not have access as a collaborator.
# #
# # You should run gert::git_remote_list() and check to be sure "origin" and
# # "forked_<name>" are set correctly.  If not, run gert::git_remote_remove(<remote name>)
# # and re-add the correct site.
# #
# # The command sequences scripted below will only pull from origin to reduce
# # the possibility of complicated three (or more)-way merges.



# # Run these commands regularly for branching, updating and merging --------

# # For more complicated situations, you should
# # consider using the terminal or a gui program.
#
# # create a working branch for your day's work
# blaseRtemplates::git_easy_branch(branch = "user_working")
#
# # save, add and commit your work but don't push
# gert::git_add("*")
# gert::git_commit("<commit message>")
#
# # frequently update your working branch from main or master branch
# # this will first update main or master from remote
# blaseRtemplates::git_update_branch()
#

# # once you are done with your day's work, merge back into main
# blaseRtemplates::git_safe_merge()
#
# # remember to delete your branch when you are done merging:
# gert::git_branch_delete(branch = "user_working")
#
# # remember to push your changes to github so we can all get them:
# blaseRtemplates::git_push_all()



# conflict resolution -----------------------------------------------------

# # any conflicting updates will be marked and the files will need to be edited
# # to resolve the conflicts.
#
# # in extreme circumstances you may need to accept all changes in one file from one source
# # to accept all changes from the main or master branch (pulled from remote) run in the terminal:
# # git checkout --ours
#
# # to accept all changes from working branch
# # git checkout --theirs
# #
# # then run in the terminal
# # git add .
# # git rebase --continue
#
# # you will be presented with a commit message. Enter :wq in the terminal to save if using Vim.





# # commands to configure git -----------------------------------------------
# #
# # You should only need to run these commands once.
# #
# # make sure you have a github account
# # https://github.com/join
#
# # install git
# ## Windows ->  https://git-scm.com/download/win
# ## Mac     ->  https://git-scm.com/download/mac
# ## Linux   ->  https://git-scm.com/download/linux
#
# # configure git in Rstudio
# usethis::use_git_config(user.name = "YourName", user.email = "your@mail.com")
#
# # create a personal access token at the github website
# # set the expiration date as desired
# # permissions should be set automatically
# usethis::create_github_token()
#
# # run this and enter your token at the prompt
# blaseRtemplates::gitcreds_set()
#
# # if you have trouble accessing github, you may need to edit the .Renviron file
# # this is the third usage of the term environment (sorry)
# # to edit this file, run
# usethis::edit_r_environ()
# # if there is a line there starting GITHUB_PAT=xxx,
# # it may be interfering with your credentials.  Delete it.
# # press enter to generate a new line and then save
# # restart R
#

