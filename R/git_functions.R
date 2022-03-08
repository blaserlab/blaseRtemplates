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
  fs::dir_create("~/.local/bin")
  fs::file_copy(path = system.file("bash/gitsafemerge",
                                   package = "blaseRtemplates"),
            new_path = "~/.local/bin/gitsafemerge",
            overwrite = TRUE)
  fs::file_copy(path = system.file("bash/gitupdatebranch",
                                   package = "blaseRtemplates"),
            new_path = "~/.local/bin/gitupdatebranch",
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
git_easy_branch("new")

git_update_branch <- function(branch = NULL, upstream = NULL) {
  # identify the default branch if not provided
  if (is.null(upstream)) {
    upstream <- usethis::git_default_branch()
  }
  # identify the current branch if not provided
  if (is.null(branch)) {
    branch <- gert::git_branch()
  }
  cmd <- paste0("git updatebranch ", branch, " ", upstream)
  message(cmd, "\n")
  system(cmd)
}
gert::git_branch()

git_update_branch()

