# Usage: bash get_report.sh module_name1 module_name2 etc...

# One module
# pylint "$1" >> results_of_all_modules.txt

# One result file for everything
# pylint "$@" >> results_of_all_modules.txt

# pylint "$1" >> results_1.txt
# pylint "$2" >> results_2.txt

for VARIABLE in "$@"
do
  pylint $VARIABLE >> $"results_"${VARIABLE%???}$".txt"
done
