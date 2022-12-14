#!/bin/sh
#
# %CopyrightBegin%
#
# Copyright Ericsson AB 2019. All Rights Reserved.
#
# The contents of this file are subject to the Erlang Public License,
# Version 1.1, (the "License"); you may not use this file except in
# compliance with the License. You should have received a copy of the
# Erlang Public License along with this software. If not, it can be
# retrieved online at http://www.erlang.org/.
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations
# under the License.
#
# %CopyrightEnd%
#

#
# install_dir_data.sh <SourceDir> <DestDir>
#
# Install all content in <SourceDir> including subdirectories
# into <DestDir>.
#

INSTALL="/usr/bin/install -c"
INSTALL_DIR="/usr/bin/install -c -d"
INSTALL_DATA="${INSTALL} -m 644"

debug=yes

error () {
    echo "ERROR: $1" 1>&2
    exit 1
}

usage () {
    error "$1\n  Usage $progname <SourceDir> <DestDir>"
}

cmd () {
    [ $debug = no ] || echo "$@"
    "$@" || exit 1
}

progname="$0"

[ $# -eq 2 ] || usage "Invalid amount of arguments"

src="$1"
dest="$2"

cmd cd "$src"

for dir in `find . -type d`; do
    destdir="$dest"
    [ "$dir" = "." ] || destdir="$dest/$dir"
    cmd $INSTALL_DIR "$destdir"
done

for file in `find . -type f`; do
    subdir=`dirname "$file"`
    destdir="$dest"
    [ "$subdir" = "." ] || destdir="$dest/$subdir"
    cmd $INSTALL_DATA "$file" "$destdir"
done

exit 0
