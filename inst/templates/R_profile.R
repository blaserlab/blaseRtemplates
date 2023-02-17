# Enable universe(s) by blaserlab
options(repos = c(
  blaserlab = 'https://blaserlab.r-universe.dev',
  CRAN = 'https://cloud.r-project.org'))

# Set the project libraries.
.libPaths(c(
  fs::path(
    Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
    "user_project",
    Sys.getenv("USER"),
    fs::path_file(getwd())
  ),
  .libPaths()
))

# set default git protocol to https
options(usethis.protocol  = "https")

# the following line sets the default editor to nano which is easiest for most people
options(editor="nano")
# alternatively, select vim
# options(editor = "vim")

# remove the automatic biostrings coloring which is really slow
options(Biostrings.coloring = FALSE)

# Startup messaging
if (interactive()) {
  cat("\014")

  cat(
    intToUtf8(128031),
    "Launching a new R session.",
    intToUtf8(129516),
    "\n",
    "\n"
  )

  cat(R.version$version.string, "\n\n")



  local({if (length(options("repos")$repos) > 1) {
    msg <- "Using package repositories:\n"
  } else {
    msg <- "Using package repository:\n"
  }
  cat(msg)
  invisible(
    lapply(
      options("repos"),
      \(x) {
        cat(
	paste0(
	  "- ",
	  names(x),
	  " @ ",
	  x,
	  collapse = "\n"))
      }
    )
  )
  })
  cat("\n\n")

  utils::rc.settings(ipck = TRUE)

  # fancy quotes are annoying and lead to
  # 'copy + paste' bugs / frustrations
  options(useFancyQuotes = FALSE)

  # make a new quit function
  .env <- new.env()

  .env$q <- function (save="no", ...) {
    quit(save=save, ...)
    }

  attach(.env, warn.conflicts = FALSE)


  .First <- function(){
    # always be working within a project
    tryCatch({
      usethis::proj_activate(usethis::proj_get())
      cat("\n")
    },
    error = function(cond) {
      .libPaths(fs::path(
                         Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
			 "user_project",
			 Sys.getenv("USER"),
			 "baseproject"),
		.libPaths())
      usethis::proj_activate(fs::path(
				      Sys.genenv("BLASERTEMPLATES_PROJECTS"),
				      "baseproject")
      )
      cat("\n")
      }
    )

    local({if (length(.libPaths()) > 1) {
      msg <- "Using libraries at paths:"
    } else {
      msg <- "Using library at path:"
    }
    libs <- paste("-", .libPaths(), collapse = "\n")
    cat(msg, libs, sep = "\n")
    })
    cat("\n")


    if ("BLASERTEMPLATES_CACHE_ROOT" %in% names(Sys.getenv())) {
      cat("Linked to blaseRtemplates cache:\n")
      cat("- ", Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"), "/library\n", sep = "")
      } else {

      cat("\n")
      cli::cli_rule(center = "You are not using a package cache!\n")
      cat("\n- Some functions may be unavailable.\n")
      }

    if (grepl(usethis::proj_get(), pattern = "baseproject")) {
     cat("\n")
     cli::cli_rule(center = "You are now in the baseproject!")
     cat("\n- Create a new project using blaseRtemplates::initialize_project()")
     cat("\n- Or open a project using the Rstudio project chooser")
     cat("\n")
     cat("\n")

    }

    cat("\n")


    # make the R prompt show the active git branch
    suppressMessages(if (!require("prompt")) install.packages("prompt"))
    if (prompt::is_git_dir()) prompt::set_prompt(paste0("[ ", gert::git_branch(), " ] > "))

    # clear the prior history and initialize a new log
    write(paste0("##------R history log [",Sys.getenv("USER"),"] session opened:  ", Sys.time(), "------##"), file = ".Rhistory")
    write(paste0("##-------- Working directory:  ", usethis::proj_sitrep()$working_directory), file = ".Rhistory", append = TRUE)



    }

  .Last <- function(){

    histfile <- fs::path(Sys.getenv("BLASERTEMPLATES_CACHE_ROOT"),
			 "logs",
		       paste0(Sys.getenv("USER"),
		       "_",
		       gsub(x = Sys.time(), pattern = "\\D", "_"),
		       ".Rhistory"))
    savehistory(histfile)
    write(paste0("##------session closed:  ", Sys.time(), "------##"), file = histfile, append = TRUE)
    cat("\n\nGoodbye!\n\n")
    }

}


