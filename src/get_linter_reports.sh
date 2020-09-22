#!/bin/bash

programname=$0

function usage {
    echo "usage: $programname [-m mode] [-s source] [-t target]"
    echo "  -m mode   specify make/delete mode"
    echo "  -s source   specify input folder source"
    echo "  -t target  specify output folder target"
    : '
    Usage: bash get_linter_reports.sh -m make -s source_folder -t target_folder
    Or: bash get_linter_reports.sh -m delete -s source_folder -t target_folder
    '
    exit 1
}

# usage

# Create CLI flags
while getopts m:s:t: flag
do
    case "${flag}" in
        m) mode=${OPTARG};;
        s) source=${OPTARG};;
        t) target=${OPTARG};;
    esac
done
echo "Mode: $mode";
echo "Source: $source";
echo "Target: $target";

SOURCE=$source
TARGET=$target

: '
SOURCE_default='Python'
TARGET_default='Linter_Reports'

if [ -z "${2}" ]
then
    echo "No source was specified - using $SOURCE_default folder"
    SOURCE=$SOURCE_default
    TARGET=$TARGET_default
elif [ -z "${3}" ]
then
    echo "No target was specified - using $TARGET_default folder"
    SOURCE=$2
    TARGET=$TARGET_default
else
    echo "source is now: $2"
    echo "target is now: $3"
    SOURCE=$2
    TARGET=$3
fi
'

PYTHON_FILES=`find $SOURCE -type f -name "*.py"`
LINTERS=("pylint" "prospector")
current_time=$(date "+%Y.%m.%d-%H.%M")


function make_reports {
    # If target does not exist, create it
    mkdir -p $TARGET
    for PYTHON_FILE in $PYTHON_FILES
    do
        for LINTER in "${LINTERS[@]}"
        do
            echo $LINTER$"_results_"$(basename ${PYTHON_FILE%???})$"_$current_time.txt"
            
            $LINTER $PYTHON_FILE \
            >> $TARGET/$LINTER$"_results_"$(basename ${PYTHON_FILE%???})$"_$current_time.txt"
        
        done
    done
}


function delete_reports {
    LINTER_FILES=`find $TARGET -type f -name "*.txt"`
    for LINTER_FILE in $LINTER_FILES
    do
        for LINTER in ${LINTERS[@]}
        do
            if [[ $LINTER_FILE == $TARGET/$LINTER$"_results_"* ]]
            then
                echo "Deleting $LINTER_FILE"
                rm $LINTER_FILE
            fi
        done
    done
}


if [ $mode = "make" ]
then
    make_reports
elif [ $mode = "delete" ]
then
    delete_reports
else
    echo "please choose either 'make' or 'delete'"
fi
