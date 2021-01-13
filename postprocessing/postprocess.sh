#!/bin/sh

convert2csv()
{
    printf "Converting: $1 -> $2 ...\n"
    time cat $1 | parallel -j$(nproc) -k --block 30M --pipe ./postprocess.sed > $2
}

if [ $# -lt 1 ]; then
    INFILES="$(ls *.out)"
    printf "No Input Specified, converting $INFILES.\n"
    for INFILE in $INFILES; do
        convert2csv "$INFILE" "${INFILE%.*}.csv"
    done
else
    INFILE="$1"
    [ $# -gt 1 ] && OUTFILE="$2" || OUTFILE="${INFILE%.*}.csv"
    convert2csv "$INFILE" "$OUTFILE"
fi

exit 0
