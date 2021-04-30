
source $(dirname ${BASH_SOURCE[0]})/color.sh
source $(dirname ${BASH_SOURCE[0]})/logger.sh

# assert_code <command> <expected code> <message>
assert_code() {
    [ ! $# -ge 2 ] || [ ! $# -le 3 ] && \
        error "assert require 1 or 2 arguments" && exit 1

    eval 2>/dev/null 1>&2 ${1}
    local status=$?
    if [ ! $status -eq ${2} ]; then
        error "'$1' assert failure: " ${3}
        exit 1
    fi
    return $status
}

# assert <command> <message>
assert() {
    assert_code "${1:-false}" 0 "$2"
    return $?
}

