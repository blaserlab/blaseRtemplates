#' @title Install Scripts to Support Git Collaboration
#' @description This function installs two scripts that bundle git commands to help avoid conflicts.  gitupdate switches from working branch to main, updates from remote, then rebases working branch.  Git safemerge swtiches to main and pulls before merging.  Both scripts are written to ~/.local/bin and the global git config is edited to provide these aliases:  git update, git safemerge.
#' @return nothing
#' @rdname setup_git_collab
#' @export
#' @import fs
setup_git_collab <- function() {
  fs::dir_create("~/.local/bin")
  fs::file_copy(path = system.file("bash/gitsafemerge", package = "blaseRtemplates"),
            new_path = "~/.local/bin/gitsafemerge",
            overwrite = TRUE)
  fs::file_copy(path = system.file("bash/gitupdate", package = "blaseRtemplates"),
            new_path = "~/.local/bin/gitupdate",
            overwrite = TRUE)
  # edit the global git config
  system('git config --global alias.update !"~/.local/bin/gitupdate"')
  system('git config --global alias.safemerge !"~/.local/bin/gitsafemerge"')

}
