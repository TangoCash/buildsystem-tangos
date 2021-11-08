#!/bin/sh
#
# astyle-project.sh - Formatting source code using astyle
#
# Copyright (C) 2021 Sven Hoefer <svenhoefer@svenhoefer.com>
# License: WTFPLv2
#

usage() {
	echo "Usage: astyle-project.sh <project-directory>"
}

test "$1" == "--help"	&& { usage; exit 0; }
test -z "$1"		&& { usage; exit 1; }

SCRIPTPATH=`dirname $0`

type $SCRIPTPATH/astyle.sh >/dev/null 2>&1 || { echo >&2 "astyle.sh in $SCRIPTPATH required. Aborting."; exit 1; }
type dos2unix >/dev/null 2>&1 || { echo >&2 "dos2unix required, but it's not installed. Aborting."; exit 1; }

PROJECT=$1

files=$(find ${PROJECT}/ -type f -name '*.c' -or -name '*.cpp' -or -name '*.h')

if [ -z "$files" ]; then
	exit 0
fi

for file in $files; do
	$SCRIPTPATH/astyle.sh $file
	dos2unix -k $file
done
