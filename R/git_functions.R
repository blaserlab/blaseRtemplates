#' @title Install Scripts to Support Git Collaboration
#' @description This function installs two scripts that bundle git commands to help avoid conflicts.  gitupdatebranch switches from working branch to main, updates from remote, then rebases working branch.  Git safemerge swtiches to main and pulls before merging.  Both scripts are written to ~/.local/bin and the global git config is edited to provide these aliases:  git updatebranch, git safemerge.
#' @return nothing
#' @rdname setup_git_collab
#' @export
#' @import fs
setup_git_collab <- function() {
  cat("This function will write two executable files to your ~/.local/bin directory\n")
  cat("This will not overwrite any pre-existing file on your system.\n")
  cat("It will also edit your global .gitconfig file to include aliases for\n")
  cat("these exectuables.\n")
  answer <- menu(c("Yes", "No"), title="Do you wish to proceed?")
  if (answer == 1) {
  fs::dir_create(Sys.getenv()[["HOME"]], ".local/bin")
  fs::file_copy(path = system.file("bash/gitsafemerge",
                                   package = "blaseRtemplates"),
            new_path = file.path(Sys.getenv()[["HOME"]], ".local/bin/gitsafemerge"),
            overwrite = TRUE)
  fs::file_copy(path = system.file("bash/gitupdatebranch",
                                   package = "blaseRtemplates"),
            new_path = file.path(Sys.getenv()[["HOME"]], ".local/bin/gitupdatebranch"),
            overwrite = TRUE)

  # edit the global git config
  system(paste0("git config --global alias.safemerge !",file.path(Sys.getenv()[["HOME"]], ".local/bin/gitsafemerge")))
  system(paste0("git config --global alias.updatebranch !",file.path(Sys.getenv()[["HOME"]], ".local/bin/gitupdatebranch")))
  }


}

#' @title Easily Create or Switch Git Branches
#' @description Supply this function with a branch name.  If the branch exists it will switch to the branch.  If not, it will pull any changes from remote and then create the branch.  Any uncommitted work will be carried over to the new branch in the same state.  Avoid repeatedly switching branches with work in different states of completion since this may cause conflicts
#' @param branch A character string with the branch name to create or switch to.
#' @return nothing
#'  \code{\link[gert]{git_branch}}
#' @rdname git_easy_branch
#' @export
#' @importFrom gert git_branch_exists git_branch_checkout git_branch_create git_pull git_diff git_log git_config
#' @importFrom prompt set_prompt
#' @importFrom stringr str_remove
#' @importFrom dplyr pull filter
git_easy_branch <- function(branch) {
  if (gert::git_branch_exists(branch)) {
    gert::git_branch_checkout(branch)
    prompt::set_prompt(paste0("[ ", gert::git_branch(), " ] > "))
  } else {
    gert::git_pull()
    gert::git_branch_create(branch)
    prompt::set_prompt(paste0("[ ", gert::git_branch(), " ] > "))
  }
}

#' @title Update a Working Git Branch
#' @description This function updates a git branch via rebase from a default upstream branch (usually "main").  You can explicitly provide the names of your working branch and the default upstream branch.  If not provided, the function will use the current branch as your working branch and will automatically identify the default upstream branch.  Internally this calls a system file that must be installed using blaseRtemplates::setup_git_collab().  The upstream branch also needs to be connected to a remote (e.g. github).
#' @param branch The working branch you wish to update, Default: NULL
#' @param upstream The default upstream branch you wish to update from, Default: NULL
#' @return nothing
#' @seealso
#'  \code{\link[usethis]{git-default-branch}}
#'  \code{\link[gert]{git_branch}},\code{\link[gert]{git_stash}}
#' @rdname git_update_branch
#' @export
#' @importFrom usethis git_default_branch
#' @importFrom gert git_branch git_stash_save git_stash_pop git_diff git_log git_config
#' @importFrom stringr str_remove
#' @importFrom dplyr pull filter
git_update_branch <- function(branch = NULL, upstream = "main") {

  # identify the current branch if not provided
  if (is.null(branch)) {
    branch <- gert::git_branch()
  }


  if (nrow(gert::git_status()) != 0) {
    dirty <- TRUE
  } else {
    dirty <- FALSE
  }


  if (dirty) {
    cli::cli_alert_info("Stashing changes.")
    gert::git_stash_save(include_untracked = TRUE, )
  }

  # send the command
  invisible(gert::git_branch_checkout(branch = upstream))
  gert::git_pull()
  invisible(gert::git_branch_checkout(branch = branch))
  cli::cli_alert_info("Rebasing {branch} from {upstream}.")
  suppressMessages(gert::git_rebase_commit(upstream = upstream))

  if (dirty)
    cli::cli_alert_info("Reapplying changes to {branch}.")
    invisible(gert::git_stash_pop())



}

#' @title Safely Merge your Working Branch
#' @description This function updates default branch (usually "main") from remote.  This pulls in any changes from other contributors.  Then it merges the working branch into the upstream branch.
#' @param branch The working branch you wish to merge, Default: NULL
#' @param upstream The default upstream branch you wish to merge into, Default: NULL
#' @return nothing
#' @seealso
#'  \code{\link[usethis]{git-default-branch}}
#'  \code{\link[gert]{git_branch}},\code{\link[gert]{git_commit}}
#' @rdname git_safe_merge
#' @export
#' @importFrom usethis git_default_branch
#' @importFrom gert git_branch git_status
#' @importFrom prompt set_prompt
git_safe_merge <- function(branch = NULL, upstream = "main"){
  # identify the current branch if not provided
  if (is.null(branch)) {
    branch <- gert::git_branch()
  }
  if (nrow(gert::git_status()) != 0) {
    cli::cli_abort("You must commit all of your work before merging.")

  } else {
    gert::git_branch_checkout(upstream)
    gert::git_pull()
    gert::git_merge(branch)
  }

  prompt::set_prompt(paste0("[ ", gert::git_branch(), " ] > "))

}

#' @title Push to All Remotes
#' @description This uses gert to look up all active remotes and then runs gert::git_push() to each.

#' @return nothing
#' @rdname git_push_all
#' @export
#' @importFrom gert git_remote_list git_push
git_push_all <- function() {
 invisible(sapply(X = gert::git_remote_list()[["name"]],
        FUN = function(x) gert::git_push(remote = x)))
}

#' @title Regenerate a Git Commands File
#' @description Since this file is ignored by git, you will have to regenerate it when forking a repository.  This function writes the template file to your R directory as "regenerated_git_commands.R".

#' @return nothing
#'
#' @rdname regenerate_git_commands
#' @export
#' @importFrom usethis use_template
regenerate_git_commands <- function() {
 usethis::use_template(template = "git_commands.R",
                       save_as = "R/regenerated_git_commands.R",
                       package = "blaseRtemplates")
}

#' @title Rewind Git History
#' @description This function uses git revert to rewind history to a prior commit.  First make sure all of your changes have been committed.  Then run gert::git_log() to identify the "good" commit you want to rewind to.  Supply this as the argument to this function.  A new commit will be made with a helpful message.  Commit history is not changed so you can always rewind the rewind etc....
#' @param commit Hash of the commit you want to rewind the state of your repository to.  Requires a minimum of 7 characters.
#' @return a tibble with the new git commit log after rewinding
#' @seealso
#'  \code{\link[gert]{git_commit}}
#' @rdname git_rewind_to
#' @export
#' @importFrom gert git_status git_commit git_log
#' @importFrom dplyr filter
git_rewind_to <- function(commit) {
  # make sure working tree is clean
  status <- gert::git_status()
  stopifnot("You must commit your changes before rewinding." = nrow(status) == 0)

  # make sure there are no merge commits in there
  log <- gert::git_log()
  commits_to_check <- log$commit[1:which(stringr::str_detect(string = log$commit, pattern = commit))]
  log_to_check <- dplyr::filter(.data = log, commit %in% commits_to_check)
  stopifnot("You have merge commits and must rewind manually using git revert -m." = all(log_to_check$merge == FALSE))

  # run git revert
  cmd <- paste0("git revert ", commit, ".. --no-commit")
  system(cmd)

  # check to be sure the revert worked correctly
  status <- gert::git_status()
  stopifnot("No changes to revert.  Aborting." = nrow(status) > 0)
  stopifnot("The revert failed.  Correct manually." = all(status$staged == TRUE))

  # commit the revert
  gert::git_commit(message = paste0("this commit rewinds history to ", commit, " using git revert"))

  # quit git revert
  cmd <- paste0("git revert --quit")
  system(cmd)

  # return the new git log
  gert::git_log()
}




#' @title Interactively Set Github PAT
#' @description This wraps gitcreds::gitcreds_set() and adds a system call to edit the user global git config to set the cache timeout to 1 billion seconds if running a Linux system.
#' @return nothing
#' @seealso
#'  \code{\link[gitcreds]{gitcreds_get}}
#' @rdname gitcreds_set
#' @export
#' @importFrom gitcreds gitcreds_set
gitcreds_set <- function() {
  os <- Sys.info()[["sysname"]]
  if (os == "Linux") {
    cmd <- "git config --global credential.helper 'cache --timeout=1000000000'"
    system(cmd)
  }
  gitcreds::gitcreds_set()
}



#' @title Reset Your Console Prompt
#' @description The prompt package adds a nice feature but has some limitations, namely, that it does not respect changing git branches and has to be manually re-called.  This defeats the purpose.  Blasertemplates git functions automoatically call prompt to change the prompt label when switching branches, but this will not happen if you change branches using the terminal, the git panel or other git branching functions.  Therefore this function is provided to manually reset your prompt to the current branch.

#' @return nothing
#' @seealso
#'  \code{\link[prompt]{set_prompt}},\code{\link[prompt]{prompt_git}}
#' @rdname reset_prompt
#' @export
#' @importFrom prompt set_prompt
reset_prompt <- function() {
  prompt::set_prompt(paste0("[ ", gert::git_branch(), " ] > "))
}


