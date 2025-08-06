#!/bin/bash
SCRIPT_PATH=$(dirname "$(realpath ${BASH_SOURCE[0]})")
CSV_FNAME="${SCRIPT_PATH}/split-screen.csv"
CSV_TMP_FNAME="${SCRIPT_PATH}/split-screen.csv.tmp"

if [ "X$1" == "Xshow" ] ; then
awk -v "showWhere=$2" -v "filterPattern=$3" '
BEGIN {
	if (showWhere != "other" && showWhere != "main" && showWhere != "dual") {
		showWhere = "current"
	}
	printf("{\"items\": [\n");
    gsub("\\*", ".*", filterPattern);
}
NF == 5 {
	if (length(filterPattern) == 0 || match($1, filterPattern) > 0) {
		printf("\t{\"arg\": [\"%s\", \"%s\"], \"title\": \"%s\", \"subtitle\": \"%s %s %s %s %s\"},\n", showWhere, $1, $1, $1, $2, $3, $4, $5);
	}
}
END {
		printf("\t{\"arg\": [\"%s %s\"], \"title\": \"custom\", \"subtitle\": \"%s\"},\n", showWhere, filterPattern, filterPattern);
	printf("]}\n");
}
' "${CSV_FNAME}" 
	exit
fi

[ -f "${CSV_FNAME}" ] || touch "${CSV_FNAME}"

awk -v "input_name=$1" -v "input_x=$2" -v "input_y=$3" -v "input_w=$4" -v "input_h=$5" '
NF == 5 && !AlreadyPrinted[$1] {
	if ($1 == input_name) {
        if (length(input_x) > 0) {
            printf("%s %s %s %s %s\n", input_name, input_x, input_y, input_w, input_h);
        }
	} else {
		printf("%s %s %s %s %s\n", $1, $2, $3, $4, $5);
	}
	AlreadyPrinted[$1] = 1
}
END {
    if (!AlreadyPrinted[input_name] && length(input_x) > 0) {
        printf("%s %s %s %s %s\n", input_name, input_x, input_y, input_w, input_h);
    }
}
' "${CSV_FNAME}" > "${CSV_TMP_FNAME}"
mv "${SCRIPT_PATH}/split-screen.csv.tmp" "${SCRIPT_PATH}/split-screen.csv"
