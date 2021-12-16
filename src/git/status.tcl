
namespace eval git {
    variable error {}
    variable untracked {}
    variable tracked; array set tracked {staged "" unstaged ""}
}

proc git::status {resultVar errVar {short 1}} {
    upvar $errVar Err

    set cmd {exec git status}
    if {$short} {
        lappend cmd -s -uall --porcelain=v2
    }

    set code [catch $cmd result]
    if {$code} {
        set Err $result
    }

    # optional result variable
    if {$resultVar ne ""} {
        upvar $resultVar Result
    }

    set Result $result

    return [expr "!$code"]
}

oo::class create StatusEntry {
    # $sub would be either "N..." or "Scmu", where c-m-u can be C-M-U or "."
    constructor {status sub mH mI mW hH hI} {
        my variable m_status
        set m_status $status

        set printvar [lambda var {
            upvar $var Var
            puts "\$$var = $Var"
        }]

        # <sub>

        my variable m_sub
        set m_sub 0

        assert {[string length $sub] == 4} "\$sub must be four characters long"

        set subtype [string index $sub 0]
        if {$subtype eq {S}} {
            # is a submodule
            set bit 1; # bit
            set index 1; # list index
            foreach wantChar {U M C} {
                set currentChar [string index $sub $index]; incr index
                set m_sub [my _set_flag $m_sub $bit $wantChar $currentChar]
                set bit [expr "$bit << 1"]
            }
        }

        # <mH> <mI> <mW>

        my variable m_fileModes
        set m_fileModes(head) $mH
        set m_fileModes(index) $mI
        set m_fileModes(worktree) $mW

        my variable m_objectName
        set m_objectName(head) $hH
        set m_objectName(index) $hI
    }

    method is_submodule {} {
        my variable m_sub
        return [expr "$m_sub != 0"]
    }

    method status {} {
        my variable m_status
        return $m_status
    }

    method type {} {return entry}

    #method _hex2dec n {return [expr "0x$n"]}

    method _set_flag {int bitfield wantchar char} {
        if {$char eq $wantchar} {
            set int [expr "$int | $bitfield"]
        } elseif {$char ne "."} {
            return -code error "invalid character '$char', must be '.' or '$wantchar'"
        }

        return $int
    }
}

oo::class create ChangedEntry {
    superclass StatusEntry

    constructor {status sub mH mI mW hH hI path} {
        next $status $sub $mH $mI $mW $hH $hI

        my variable m_path
        set m_path $path
    }

    method type {} {return changed}
}

settemp obj [ChangedEntry new .M S.M. 100644 100644 100644 8c9ac2515dee8a0a9d794d2bb92c7f1a0d664e00 8c9ac2515dee8a0a9d794d2bb92c7f1a0d664e00 interface.tk]

#1 .M N... 100644 100644 100644 8c9ac2515dee8a0a9d794d2bb92c7f1a0d664e00 8c9ac2515dee8a0a9d794d2bb92c7f1a0d664e00 interface.tk
#1 .M N... 100644 100644 100644 ad98454024caf737c8f04a5d36cc553da50268dd ad98454024caf737c8f04a5d36cc553da50268dd proc.tcl
#? src/git/status.tcl

$obj destroy

exit
