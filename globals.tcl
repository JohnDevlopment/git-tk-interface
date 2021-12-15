assert {[info exists basedir]} "\$basedir needs to be set before sourcing this script"

# path to the config file
const c_ConfigFile [file join $basedir config.ini]

# repository directory path
set Repository(directory) [pwd]
