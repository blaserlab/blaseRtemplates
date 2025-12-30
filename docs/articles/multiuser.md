# Establish a Multi-User blaseRtemplates Installation

## Notes for the System Administrator of a Multi-User blaseRtemplates Environemnt

The blaseRtemplates environment works well for a multiuser system
running Rstudio server. In fact it was designed for this purpose. Here
are the steps you need to perform to set this up:

1.  Run blaseRtemplates::establish_new_bt() but make sure the cache_path
    parameter points to a directory that is/will be available to all of
    your users. The project_path parameter can point to your own
    workspace.
2.  Save this file as Rprofile.site in \$R_HOME/etc:

``` r
fs::path_package("blaseRtemplates", "templates", "Rprofile.site")
```

2.  Save this file as Renviron.site in \$R_HOME/etc:

``` r
fs::path_package("blaseRtemplates", "templates", "Renviron.site")
```

3.  Edit the file paths in Renviron.site to point to the location of the
    blaseRtemplates cache on your system. Since the other users will not
    be running establish_new_bt(), they won’t have a baseproject. You
    need this to provide functionality for the users if/when they get
    out of a project. Bad things happen when they are not working in a
    valid project. So you need to move your baseproject to the cache
    directory and edit the new Rprofile.site file to point all of the
    users to that. The file paths you need to change are in the .First
    function at the bottom.

4.  Edit your sudo crontab file by running `sudo crontab -e` and include
    something like this:

&nbsp;

    * * * * * chmod -R 777 /path/to/cache_R_4_2/library

This will set 777 permissions on the package library. This way all of
your users can read and write to the library. If you want more security
you can tweak the permissions and group settings, but this can be tricky
to maintain because of the limitations in the file writing and linking
programs used within R. Usually I find the 777 permissions to work well.
In normal operations, everything is versioned so your users won’t
overwrite anything useful. The only problem is if someone goes in and
clobbers the cache from the command line or through the Rstudio file
manager either maliciously or by accident. To protect against this you
should back up your cache to another drive.

5.  If everything works, when your users log in, they should start out
    in the baseproject. From there they can make or clone their own
    projects using the usual functions.

## Disclaimer

These operations are not routinely tested with multiple users, so may
require some tweaking. However this is basically what we use in
production. Please post any issues to the [blaseRtemplates issues
page.](https://github.com/blaserlab/blaseRtemplates/issues)
