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
