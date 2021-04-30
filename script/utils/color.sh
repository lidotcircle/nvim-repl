#!/bin/bash

# ANSI ESCAPE CODE:
# Just choose color
# ESC = \033
# basic format : ESC[<arg>;<argn>m"string"
# ESC[0m is default output type
# 3/4 bit color foregroud : <arg> = n, and n in {30 ... 37 + 90 .. 97}
# 3/4 bit color backgroud : <arg> = n, and n in {40 ... 47 + 100 .. 107}
# 8 bit color foregroud : <arg> = 38;5;n, and n in {0 ... 255}
# 8 bit color backgroup : <arg> = 48;5;n, and n in {0 ... 255}
# 24 bit color foregroup : <arg> = 38;2;r;g;b, and r,g,b in {0 ... 255}
# 24 bit color backgroup : <arg> = 48;2;r;g;b, and r,g,b in {0 ... 255}

case $(tput colors) in
    "256")
        declare -A colorlist=([black]='0;0;0' [red]='255;0;0' [green]='0;128;0' \
            [yellow]='255;255;0' [blue]='0;0;255' [purple]='255;0;255' [magenta]='255;0;255' \
            [cyan]='0;255;255' [lightblue]='0;255;255' [white]='255;255;255')
        fore_prefix='38;2;'
        back_prefix='48;2;';;

    "8")
        declare -A colorlist=([black]=0 [red]=1 [green]=2 \
            [yellow]=3 [blue]=4 [purple]=5 [magenta]=5 \
            [cyan]=6 [lightblue]=6 [white]=7 [preety]=167)
        fore_prefix='38;5;'
        back_prefix='48;5;';;
    *)
        declare -A colorlist=([black]=30 [red]=31 [green]=32 [yellow]=33 \
            [blue]=34 [purple]=35 [magenta]=35 [cyan]=36 [lightblue]=36 [white]=37)
        declare -A bg_colorlist=([black]=40 [red]=41 [green]=42 [yellow]=43 \
            [blue]=44 [purple]=45 [magenta]=45 [cyan]=46 [lightblue]=46 [white]=47)
        fore_prefix=''
        back_prefix='';;
esac

# IMPORTANT! USING THIS MAP
declare -A COLORS=([reset]='\033[0m')

# Other settings
declare -A fonttype=([b]='1;' [i]='3;' [u]='4;')


# Define color functions
for color in ${!colorlist[@]}; do
    # Foreground
    COLORS[${color}]="\033[${fore_prefix}${colorlist[$color]}m"

    # Fonts
    for ftype in ${!fonttype[@]}; do
        COLORS[${color}${ftype}]="\033[${fonttype[$ftype]}${fore_prefix}${colorlist[$color]}m"
    done

    # Background
    if [ -z "${!bg_colorlist[@]}" ]; then
        COLORS[B${color}]="\033[${back_prefix}${colorlist[$color]}m"

        for ftype in ${!fonttype[@]}; do
            COLORS[B${color}${ftype}]="\033[${fonttype[$ftype]}${back_prefix}${colorlist[$color]}m"
        done
    else
        COLORS[B${color}]="\033[${back_prefix}${bg_colorlist[$color]}m"

        for ftype in ${!fonttype[@]}; do
            COLORS[B${color}${ftype}]="\033[${fonttype[$ftype]}${back_prefix}${bg_colorlist[$color]}m"
        done
    fi
done

