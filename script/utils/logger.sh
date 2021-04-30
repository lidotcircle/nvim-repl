#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/color.sh

__logger__() {
    if [ $# -lt 3 ]; then
        error "logger error"
        exit 1
    fi

    local level=$1
    local color=$2
    shift 2
    local _date=$(date "+%Y-%m-%d %T %Z")

    echo -e "${COLORS[${color}]}$_date $level${COLORS[reset]}  $@"
}

debug() {
    __logger__ debug green $@
}

info() {
    __logger__ info lightblue $@
}

warn() {
    __logger__ warn yellow $@
}

error() {
    __logger__ error red $@
}

