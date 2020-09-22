#!/bin/bash

: '
Usage: bash get_linter_reports.sh make
Or: bash get_linter_reports.sh delete
'

SOURCE='Python'
TARGET='Linter_Reports'

PYTHON_FILES=`find $SOURCE -type f -name "*.py"`

LINTERS=("pylint" "prospector")
current_time=$(date "+%Y.%m.%d-%H.%M")

# If target does not exist, create it
mkdir -p $TARGET


function make_reports {
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


if [ $1 = "make" ]
then
    make_reports
elif [ $1 = "delete" ]
then
    delete_reports
else
    echo "please choose either 'make' or 'delete'"
fi
