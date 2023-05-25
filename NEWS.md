## blaseRtemplates 0.0.0.9197-8
* made all git functions run through gert
* still seems to be a problem with curl

## blaseRtemplates 0.0.0.9197-8

* improved project_data to handle multiple data packages
* loads data into a deconflicted environment using unique user-defined suffix strings.

## blaseRtemplates 0.0.0.9196

* removed upgrade function and webpage

## blaseRtemplates 0.0.0.9195

* edited load_process.R to use bb_load_tenx_h5

## blaseRtemplates 0.0.0.9193-4

* fixed bug in r profile where base install packages made new user_project directory
* the problem was solved by only making these directories in interactive sessions

## blaseRtemplates 0.0.0.9193

* moved pkgcache down r profile

## blaseRtemplates 0.0.0.9192

* added in pkgcache update to rprofile

## blaseRtemplates 0.0.0.9191

* fixed an issue on windows where establish did not recognize links when copying packages
* fixed an issue on windows where fs::path_home() identified the wrong home directory when writing .Renviron

## blaseRtemplates 0.0.0.9189

* edited R profile template to fix an issue where rlang was loaded early from the home R library and causing issues.
* added multiuser vignette

## blaseRtemplates 0.0.0.9188

* edited R profile template to auto-update pkgcache

## blaseRtemplates 0.0.0.9187

* rewrote initialize package
* created fix a library function

## blaseRtemplates 0.0.0.9186

* fixed an issue where home was being incorrectly assigned on windows

## blaseRtemplates 0.0.0.9185

* minor edits to templates

## blaseRtemplates 0.0.0.9184

* fixed establish by making absolute paths

## blaseRtemplates 0.0.0.9182-3

* fixed initialize project

## blaseRtemplates 0.0.0.9180-1

* validate packages before copying

## blaseRtemplates 0.0.0.9179

* removed rprofile from upgrade function

## blaseRtemplates 0.0.0.9178

* edited project_data to check if specific version is already available, and if so, then link from cache

## blaseRtemplates 0.0.0.9175-6

* updated docs

