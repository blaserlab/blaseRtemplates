# blaseRtemplates 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.

# blaseRtemplates 0.0.0.9001-5

* Initial version with code.

# blaseRtemplates 0.0.0.9006-8

* Added git_commands.R and supporting functions.

# blaseRtemplates 0.0.0.9009-13

* many bug fixes


# blaseRtemplates 0.0.0.9014-18 

* added git_attributes
* edited git_easy_branch() to pull changes before branching
* edited git commands to include git_push in collab section
* added git_push_all function
* added regenerate_git_commands function

# blaseRtemplates 0.0.0.9019

* edited dependencies.R template to change renv snapshot behavior

# blaseRtemplates 0.0.0.9020

* reversed changes to dependencies.R and put them in a new .Rprofile template
* changed initialization function to put in the .Rprofile template

# blaseRtemplates 0.0.0.9021-23

* made git_rewind_to function

# blaseRtemplates 0.0.0.9024

* added gitcreds_set function

# blaseRtemplates 0.0.0.9026

* edited templates

# blaseRtemplates 0.0.0.9027

* added renv hydrate to template

# blaseRtemplates 0.0.0.9028 - 32 

* added easy install function

# blaseRtemplates 0.0.0.9033

* edited r_profile

# blaseRtemplates 0.0.0.9034-8

* added git prompt

# blaseRtemplates 0.0.0.9039

* edited .Rprofile template

# blaseRtemplates 0.0.0.9041

* changed git template
* added fork_github_project function

# blaseRtemplates 0.0.0.9042

* edited easy install 

# blaseRtemplates 0.0.0.9044- 51 

* added prompt after git changes lock file

# blaseRtemplates 0.0.0.9052 - 4 

* fixed bug in fork function

# blaseRtemplates 0.0.0.9055

* removed fork function

# blaseRtemplates 0.0.0.9056

* changed text after changes to renv.lock

# blaseRtemplates 0.0.0.9057

* added dratify for writing to local repository 

# blaseRtemplates 0.0.0.9058

* modified dratify
* modified get_renv_committer to return "nobody" instead of NA if no renv.lock file exists

# blaseRtemplates 0.0.0.9062-3

* edited easy install

# blaseRtemplates 0.0.0.9067 - 72 

* made initialize package

# blaseRtemplates 0.0.0.9073

* edited dratify to handle github repos

# blaseRtemplates 0.0.0.9077-8

* reverts back to 73 and removes dratify

# blaseRtemplates 0.0.0.9079 - 80

* added back dratify
* modified .Rprofile template

# blaseRtemplates 0.0.0.9081

* modified .Rprofile template

# blaseRtemplates 0.0.0.9083 - 4

* defaults to use pak and syncs cache

# blaseRtemplates 0.0.0.9085

* defaults not to use pak

# blaseRtemplates 0.0.0.9086-7

* set default git branch to main

# blaseRtemplates 0.0.0.9088

* removed dratify
* exposed sync_cache

# blaseRtemplates 0.0.0.9089

* made easy install update to latest version when linking to cache 
* added load_process template for scrnaseq

# blaseRtemplates 0.0.0.9090-1

* edited load_process template
* provided option to use pak for easy_install

# blaseRtemplates 0.0.0.9092

* edited sync cache to only work when in an renv project

# blaseRtemplates 0.0.0.9093

* edited r profile template to include blaserlab r universe repo

# blaseRtemplates 0.0.0.9094

* adopted pak for all install functions 

# blaseRtemplates 0.0.0.9095-9

* major changes to easy install, allowing direct linking from cache to project 

# blaseRtemplates 0.0.0.9103-09

* added easy_restore and easy_init

# blaseRtemplates 0.0.0.9115

* edited bb_renv_datapkg

# blaseRtemplates 0.0.0.9116- 9120

* fixed bug where init deletes your project library if there is a trailing comma in dependencies
* catches the case where you try to init with a package not in your cache; will install if this happens
* also fixed same bug in restore

# blaseRtemplates 0.0.0.9145

* added initialize_github function

# blaseRtemplates 0.0.0.9146

* removed old install functions

# blaseRtemplates 0.0.0.9147-68

* added establish functions
