#!/bin/bash

: '
Usage: bash get_linter_reports.sh make
Or: bash get_linter_reports.sh delete
'

PYTHON_FILES=`find . -type f -name "*.py"`
LINTERS=("pylint" "prospector")
current_time=$(date "+%Y.%m.%d-%H.%M")


function make_reports {
    for PYTHON_FILE in $PYTHON_FILES
    do
        for LINTER in "${LINTERS[@]}"
        do
            echo $LINTER$"_results_"$(basename ${PYTHON_FILE%???})$"_$current_time.txt"
            $LINTER $PYTHON_FILE >> $LINTER$"_results_"$(basename ${PYTHON_FILE%???})$"_$current_time.txt"
        done
    done
}


function delete_reports {
    LINTER_FILES=`find . -type f -name "*.txt"`
    for LINTER_FILE in $LINTER_FILES
    do
        for LINTER in ${LINTERS[@]}
        do
            if [[ $LINTER_FILE == $"./"$LINTER$"_results_"* ]]
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
