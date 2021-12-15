package require inifile

const c_DefaultGeometry [list 640 480 50 50]

proc openRepo {dir} {
    if {[catch "exec git status" result]} {
        puts stderr "'git status' failed: $result"
        return
    }

    set temp enRepoDir
    set w_repo [WidgetMapper::find -start .nb.frRepo $temp]
    assert {$w_repo ne ""} "Could not find widget '$temp'"

    TXSTATUS state normal

    TXSTATUS delete 1.0 end
    TXSTATUS insert end $result

    TXSTATUS state disabled

    global RepoDir Repository
    exw state $RepoDir {!disabled !readonly}
    exw subcmd $RepoDir delete 0 end
    exw subcmd $RepoDir insert 0 $Repository(directory)
    exw state $RepoDir readonly
}

proc newConfig {file} {
    global c_DefaultGeometry

    set ini [ini::open $file w]
    jdebug::print debug "Create new config file: '$file'"
    jdebug::print trace "File handle is '$ini'"

    ini::set $ini repository directory [pwd]
    jdebug::print debug "Set repository directory to '[pwd]'"

    foreach v $c_DefaultGeometry k {width height x y} {
        ini::set $ini window $k $v
        jdebug::print debug "Set window $k to $v"
    }

    ini::commit $ini
    jdebug::print trace "Changes committed to $file"

    lassign $c_DefaultGeometry w h x y
    wm geometry . "${w}x${h}+${x}+$y"
    jdebug::print debug "Set window geometry to ${w}x${h}+${x}+$y"

    ini::close $ini
    jdebug::print trace "Closed $file"
}

proc loadConfig {file} {
    if {! [file exists $file]} {tailcall newConfig $file}

    set ini [ini::open $file r+]
    jdebug::print debug "Opened config file: '$file'"

    foreach a {w h x y} b {width height x y} default {0 0 -1 -1} {
        set geometry($a) [ini::value $ini window $b $default]
        jdebug::print debug "Get key '$b' from section 'window'"
    }
    unset -nocomplain a b default

    global c_DefaultGeometry

    # If width and height are undefined, set them to their defaults
    if {$geometry(w) <= 0} {
        set temp [lindex $c_DefaultGeometry 0]
        jdebug::print debug "Undefined window width, set to its default of $temp"
        ini::set $ini window width $temp
    }
    if {$geometry(h) <= 0} {
        set temp [lindex $c_DefaultGeometry 1]
        jdebug::print debug "Undefined window height, set to its default of $temp"
        ini::set $ini window height $temp
    }
    ini::commit $ini

    ini::close $ini

    set temp "$geometry(w)x$geometry(h)+$geometry(x)+$geometry(y)"
    wm geometry . $temp
    jdebug::print debug "Set window geometry to $temp"
}

proc saveConfig {file} {
    set ini [ini::open $file w]
    jdebug::print debug "Save config file: '$file'"

    foreach a {width height x y} b [split [wm geometry .] x+] {
        ini::set $ini window $a $b
        jdebug::print debug "Set window $a to $b"
    }

    global Repository
    ini::set $ini repository directory $Repository(directory)
    jdebug::print debug "Save current repository path to config: '$Repository(directory)'"

    ini::commit $ini
    ini::close $ini
}
