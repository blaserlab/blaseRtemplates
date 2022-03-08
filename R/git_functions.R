#' @title Install Scripts to Support Git Collaboration
#' @description This function installs two scripts that bundle git commands to help avoid conflicts.  gitupdatebranch switches from working branch to main, updates from remote, then rebases working branch.  Git safemerge swtiches to main and pulls before merging.  Both scripts are written to ~/.local/bin and the global git config is edited to provide these aliases:  git updatebranch, git safemerge.
#' @return nothing
#' @rdname setup_git_collab
#' @export
#' @import fs
setup_git_collab <- function() {
  cat("This function will write two executable files to your ~/.local/bin directory\n")
  cat("This will not overwrite any pre-existing file on your system.\n")
  cat("It will also edit your global .gitconfig file to include alieases for\n")
  cat("these exectuables.\n")
  answer <- menu(c("Yes", "No"), title="Do you wish to proceed?")
  if (answer == 1) {
  fs::dir_create("$HOME/.local/bin")
  fs::file_copy(path = system.file("bash/gitsafemerge",
                                   package = "blaseRtemplates"),
            new_path = "$HOME/.local/bin/gitsafemerge",
            overwrite = TRUE)
  fs::file_copy(path = system.file("bash/gitupdatebranch",
                                   package = "blaseRtemplates"),
            new_path = "$HOME/.local/bin/gitupdatebranch",
            overwrite = TRUE)

  # edit the global git config
  system('git config --global alias.updatebranch !"$HOME/.local/bin/gitupdatebranch"')
  system('git config --global alias.safemerge !"$HOME/.local/bin/gitsafemerge"')
  }


}

#' @title Easily Create or Switch Git Branches
#' @description Supply this function with a branch name.  If the branch exists it will switch to the branch.  If not, it will create the branch.  Any uncommitted work will be carried over to the new branch in the same state.  Avoid repeatedly switching branches with work in different states of completion since this may cause conflicts
#' @param branch A character string wtih the branch name to create or switch to.
#' @return nothing
#'  \code{\link[gert]{git_branch}}
#' @rdname git_easy_branch
#' @export
#' @importFrom gert git_branch_exists git_branch_checkout git_branch_create
git_easy_branch <- function(branch) {
  if (gert::git_branch_exists(branch)) {
    gert::git_branch_checkout(branch)
  } else {
    gert::git_branch_create(branch)
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
#' @importFrom gert git_branch git_stash_save git_stash_pop
git_update_branch <- function(branch = NULL, upstream = NULL) {
  # identify the default branch if not provided
  if (is.null(upstream)) {
    upstream <- usethis::git_default_branch()
  }
  # identify the current branch if not provided
  if (is.null(branch)) {
    branch <- gert::git_branch()
  }


  if (nrow(gert::git_status()) != 0) {
    dirty <- TRUE
    gert::git_stash_save(include_untracked = TRUE)
  }

  # send the command
  cmd <- paste0("$HOME/.local/bin/gitupdatebranch ", branch, " ", upstream)
  message("Sending this command to the terminal:\n\n", cmd, "\n")
  message("This will tell git to update ", branch, " from ", upstream, " via rebase.\n")
  suppressWarnings(system(cmd, show.output.on.console = TRUE))

  if (dirty) invisible(gert::git_stash_pop())
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
git_safe_merge <- function(branch = NULL, upstream = NULL){
  # identify the default branch if not provided
  if (is.null(upstream)) {
    upstream <- usethis::git_default_branch()
  }
  # identify the current branch if not provided
  if (is.null(branch)) {
    branch <- gert::git_branch()
  }
  if (nrow(gert::git_status()) != 0) {
    message("You must commit all of your work before merging.")

  } else {
    cmd <- paste0("$HOME/.local/bin/gitsafemerge ", branch, " ", upstream)
    message("Sending this command to the terminal:\n\n", cmd, "\n")
    message("This will tell git to merge ", branch, " into ", upstream, ". \n")
    suppressWarnings(system(cmd, show.output.on.console = TRUE))

  }



}

#' @title Continue Updating Branch after Resolving Conflict
#' @description This function adds files after conflict resolution and continues the rebase.

#' @return nothing
#' @seealso
#'  \code{\link[gert]{git_commit}}
#' @rdname git_update_continue
#' @export
#' @importFrom gert git_add
git_update_continue <- function() {
  gert::git_add("*")
  message("Adding files after conflict resolution\n")
  message("Continuing update")
  cmd <- "git rebase --continue"
  suppressWarnings(system(cmd, show.output.on.console = TRUE))
}
