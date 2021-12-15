proc openRepo {dir} {
    set code 0

    try {
        exec git status
    } on error err {
        set code 1
        puts stderr "'git status' failed: $result"
    } on ok result {}

    if {$code} return

    TXSTATUS state normal

    TXSTATUS delete 1.0 end
    TXSTATUS insert end $result

    TXSTATUS state disabled
}
