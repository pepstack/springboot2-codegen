#!/bin/bash
# @file: update-build.sh
#
#   update all source file.
#
# @author: master@pepstack.com
#
# @create: 2018-05-18
# @update:
#
#######################################################################
# will cause error on macosx
_file=$(readlink -f $0)

_cdir=$(dirname $_file)
_name=$(basename $_file)

#######################################################################

$_cdir/updt.py \
    --path=$_cdir/scripts \
    --filter="python" \
    --author="master@pepstack.com" \
    --recursive
