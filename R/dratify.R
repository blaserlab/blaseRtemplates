#' @title Build a Package and Send to Local CRAN-like Repository
#' @description Use this to build a package that can be installed like a CRAN package.  This wraps around function from the drat package.  A source package file is built from the current package, or explicitly chosen, inserted into the local drat repository, and the user session is checked to be sure the designated repository is available.  If not, it modifies the main .Rprofile file to make it accessible.  In order for this to work, the file path must be accessible on the local network.
#' @param pkg The package to install into the local repository.  If "." (default), the current working directory will be built, assuming you are running from inside a package.  Otherwise select a .tar.gz source file to add to the local repository.
#' @param repo_name Name for the local repository.  Checks to see if it has been added using options("repos"); if not it will add it to your ~/.Rprofile
#' @param repo_dir Directory to send the package source file to.  Must be of the form "~/<path>/<to>/<repo>/R/drat" for local sources or if using github:  "~/<path>/<to>/<drat repo>/docs".  If it does not exist it will be created.
#' @param cleanup Whether or not to delete the original .tar.gz file.  Defaults to TRUE.
#' @param drat_action How to handle old versions. For github, prune is recommended.  For local, "archive" is recommended, Default: c("archive", "prune")
#' @param github Do you want to automatically commit and push to your github repo?  Will fail if TRUE and it is a local directory and not a git repo, Default: FALSE
#' @seealso
#'  \code{\link[devtools]{build}}
#'  \code{\link[stringr]{str_detect}}
#'  \code{\link[fs]{create}}
#' @rdname dratify
#' @export
#' @importFrom devtools build
#' @importFrom stringr str_detect
#' @importFrom fs dir_create
dratify <-
  function(pkg = ".",
           repo_name,
           repo_dir,
           cleanup = TRUE,
           drat_action = c("archive", "prune"),
           github = FALSE) {
    drat_action <- match.arg(drat_action)
    # build the temporary tar.gz
    if (pkg == ".") {
      pkg_build <- devtools::build()
    } else {
      stopifnot("You must choose a package source file, i.e. .tar.gz." = stringr::str_detect(pkg, ".tar.gz"))
      pkg_build <- pkg
    }

    if (!file.exists(file.path(repo_dir, "index.html"))) {
      file.copy(
        from = system.file("templates/index.html",
                           package = "blaseRtemplates"),
        to = repo_dir
      )
    }

    fs::dir_create(file.path(repo_dir, "src/contrib"))

    # copy to drat repo
    insertDratPackage(
      file = pkg_build,
      repodir = repo_dir,
      action = drat_action,
      commit = github
    )

    # delete the tar.gz
    if (cleanup)
      unlink(pkg_build)

    # edit the user R profile
    if (!(repo_name %in% names(options("repos")$repos))) {
      message("Editing your ~/.Rprofile to include this local repository\n")
      message("It should be available after restarting your R session.")
      line1 <- paste0("# Activate the ", repo_name, " repo\n")
      line2 <-
        "suppressMessages(if (!require('drat')) install.packages('drat'))\n"
      if(github) {
      line3 <-
        paste0("drat::addRepo('", repo_name, "')\n")

      } else {
      line3 <-
        paste0("drat::addRepo('", repo_name, "', 'file:", repo_dir, "')\n")

      }

      cat(
        c(line1, line2, line3),
        file = "~/.Rprofile",
        append = TRUE,
        sep = ""
      )

    }
  }

#' @importFrom tools write_PACKAGES
#' @importFrom gert git_add git_commit git_push
#' @importFrom drat pruneRepo archivePackages
insertDratPackage <-
  function(file,
           repodir,
           commit,
           pullfirst = FALSE,
           action = c("none", "archive",
                      "prune"),
           ...) {
    if (!file.exists(file))
      stop("File ", file, " not found\n", call. = FALSE)
    if (!dir.exists(repodir))
      stop("Directory ", repodir, " not found\n", call. = FALSE)
    pkg <- basename(file)
    pkginfo <- getPackageInfo(file)
    pkgtype <- identifyPackageType(file, pkginfo)
    pkgdir <-
      normalizePath(contrib.url2(repodir, pkgtype, pkginfo["Rmajor"]),
                    mustWork = FALSE)
    if (!file.exists(pkgdir)) {
      if (!dir.create(pkgdir, recursive = TRUE)) {
        stop("Directory ", pkgdir, " couldn't be created\n",
             call. = FALSE)
      }
    }
    if (!file.copy(file, pkgdir, overwrite = TRUE)) {
      stop("File ", file, " can not be copied to ", pkgdir,
           call. = FALSE)
    }
    args <- .norm_tools_package_args(...)
    do.call(tools::write_PACKAGES, c(list(
      dir = pkgdir, type = .get_write_PACKAGES_type(pkgtype)
    ),
    args))
    action <- match.arg(action)
    pkgname <- gsub("\\.tar\\..*$", "", pkg)
    pkgname <- strsplit(pkgname, "_", fixed = TRUE)[[1L]][1L]

    if (commit) {
      gert::git_add(files = ".", repo = repodir)
      msg <- paste0(pkg, " committed via dratify")
      gert::git_commit(message = msg, repo = repodir)
      gert::git_push(repo = repodir)
      message("\n\n*** dratify has committed and pushed to the drat repo with this message ***\n\n")
      message(msg, "\n\n")
    }

    if (action == "prune") {
      drat::pruneRepo(
        repopath = repodir,
        type = pkgtype,
        pkg = pkgname,
        version = pkginfo["Rmajor"],
        remove = TRUE
      )
    }
    else if (action == "archive") {
      drat::archivePackages(
        repopath = repodir,
        type = pkgtype,
        pkg = pkgname,
        version = pkginfo["Rmajor"]
      )
    }


    invisible(NULL)
  }

getPackageInfo <- function(file) {
  if (!file.exists(file))
    stop("File ", file, " not found!", call. = FALSE)
  td <- tempdir()
  if (grepl(".zip$", file)) {
    unzip(file, exdir = td)
  }
  else if (grepl(".tgz$", file)) {
    untar(file, exdir = td)
  }
  else {
    fields <- c(Source = TRUE,
                Rmajor = NA,
                osxFolder = "")
    return(fields)
  }
  pkgname <- gsub("^([a-zA-Z0-9.]*)_.*", "\\1", basename(file))
  path <- file.path(td, pkgname, "DESCRIPTION")
  if (!file.exists(path)) {
    stop(
      "DESCRIPTION file cannot be opened in '",
      file,
      "'. It is expected ",
      "to be located in the base directory of compressed file.",
      call. = FALSE
    )
  }
  builtstring <- read.dcf(path, "Built")
  unlink(file.path(td, pkgname), recursive = TRUE)
  fields <- strsplit(builtstring, "; ")[[1]]
  names(fields) <- c("Rversion", "OSflavour", "Date", "OS")
  rmajor <-
    gsub("^R (\\d\\.\\d)\\.\\d.*", "\\1", fields["Rversion"])
  osxFolder <-
    switch(
      fields["OSflavour"],
      `x86_64-apple-darwin13.4.0` = "mavericks",
      `x86_64-apple-darwin15.6.0` = "el-capitan",
      ""
    )
  fields <-
    c(fields, Rmajor = unname(rmajor), osxFolder = osxFolder)
  return(fields)
}


identifyPackageType <-
  function(file, pkginfo = getPackageInfo(file)) {
    ret <- if (grepl("_.*\\.tar\\..*$", file)) {
      "source"
    }
    else if (grepl("_.*\\.tgz$", file)) {
      "mac.binary"
    }
    else if (grepl("_.*\\.zip$", file)) {
      "win.binary"
    }
    else {
      stop("Unknown package type", call. = FALSE)
    }
    if (ret == "mac.binary") {
      if (pkginfo["osxFolder"] == "") {
        ret <- switch(
          pkginfo["Rmajor"],
          `3.2` = paste0(ret,
                         ".mavericks"),
          `3.3` = paste0(ret, ".mavericks"),
          `3.4` = paste0(ret, ".el-capitan"),
          `3.5` = paste0(ret,
                         ".el-capitan"),
          `3.6` = paste0(ret, ".el-capitan"),
          ret
        )
      }
      else if (pkginfo["osxFolder"] %in% c("mavericks", "el-capitan")) {
        ret <- paste0(ret, ".", pkginfo["osxFolder"])
      }
      else {
        stop(
          "mac.binary subtype couldn't be determined. This shouldn't ",
          "happen. Please report it with a reproducable example and ",
          "provide the binary, if you can. Thanks."
        )
      }
    }
    return(ret)
  }

.get_write_PACKAGES_type <- function(pkgtype) {
  split_pkgtype <- strsplit(pkgtype, "\\.")[[1L]]
  write_pkgtype <- paste(split_pkgtype[seq.int(1L,
                                               min(2L,
                                                   length(split_pkgtype)))],
                         collapse = ".")
  write_pkgtype
}

contrib.url2 <-
  function(repos,
           type = getOption("pkgType"),
           version = NULL) {
    DRAT_CONTRIB_VERSION_REGEX <- "contrib/[0-9]\\.[0-9]$"
    FUN <- function(t) {
      contrib_url <- contrib.url(repos = repos, type = t)
      if (is.null(version)) {
        return(contrib_url)
      }
      else if (is.na(version)) {
        if (t != "source") {
          contrib_url <-
            c(contrib_url, list.dirs(
              gsub(DRAT_CONTRIB_VERSION_REGEX,
                   "contrib", contrib_url),
              recursive = FALSE
            ))
          contrib_url <- unique(contrib_url)
        }
      }
      else {
        version <- package_version(version)
        contrib_url <-
          gsub(DRAT_CONTRIB_VERSION_REGEX,
               file.path("contrib",
                         paste0(version$major, ".", version$minor)),
               contrib_url)
        contrib_url
      }
      contrib_url
    }
    urls <- lapply(type, FUN)
    names <-
      unlist(mapply(rep, type, lengths(urls), SIMPLIFY = FALSE))
    urls <- unlist(urls)
    names(urls) <- names
    urls
  }


.norm_tools_package_args <- function(...){
  args <- list(...)
  if (is.null(args[["latestOnly"]])) {
    args[["latestOnly"]] <- FALSE
  }
  args
}
