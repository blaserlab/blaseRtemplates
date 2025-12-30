# Initialize a blaseRtemplates Project

## Initializing a de-novo project

1.  Choose the directory you want the project to live in.

2.  Run

``` r
blaseRtemplates::initialize_project(path = "/path/to/projects/project_name")
```

## Initializing a project from Github

Prerequisites:

1.  You must set up your system to work with git and github. See “Using
    Git”.
2.  The project must be a public repository or you must be a
    collaborator on it.

Note:

The workflow I recommend for users who wish to collaborate via Git and
Github is different than the standard usage. See “Using Git” for more
details. The goal is to minimize workload and conflicts. I recommend
setting up the collaboration in such a way that commits from everyone
are pushed to everyone’s github simultaneously. We rely on the ability
of Git to rewind to a prior commit to protect against unwanted changes.
There are no pull requests involved.

Also note:

You don’t necessarily need to use the blaseRtemplates format for
projects you are cloning from github, although it would be recommended.

1.  Run this to fork a repository to your github site and then clone it
    to your destination of choice:

``` r
blaseRtemplates::initialize_github(repo = "<owner>/<repo>", dest = "/path/to/projects")
```

    * Note:  do not include the repo (project) name in the dest argument.  The project directory will be created and the contents cloned inside.

2.  Assuming you and the project originator are using the
    blaseRtemplates format for the project, when you start work on the
    project, you will have access to the newest versions of all packages
    in your cache library. However, you may wish to adopt the same
    package library as the person from whom you cloned the project. If
    this is the case, then run:

``` r
blaseRtemplates::get_new_library(newest_or_file = "library_catalogs/<filename.tsv>")
```

3.  As configured, the repo originator will still only be pushing to
    their own github. Collaborator will have to pull changes to update
    their github. Therefore, the originator can (and should) run this to
    add the collaborator as an additional remote and keep all remote
    repos in sync:

``` r
gert::git_remote_add("https://github.com/<collaborator>/<repo>.git", name = "<collaborator>")
```

## For more information

See [Using
Git](https://blaserlab.github.io/blaseRtemplates/articles/using_git.html).
