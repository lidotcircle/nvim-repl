
source $(dirname ${BASH_SOURCE[0]})/utils.sh

info "****** RUN TEST SUIT *****"

for file in $(find test -name 'test_*.lua'); do
    debug "run $file"
    lua $file -v
done

info "*** FINISH ***"

