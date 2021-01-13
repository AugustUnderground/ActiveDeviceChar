#!/usr/bin/awk -f

BEGIN {
    OFS = ",";
}

{
    if ($1 ~ /^\s*[0-9]+/ || NR == 1)
    { 
        for (i = 1; i <= NF; i++) 
            {printf "%s%s", $i, (i == NF ? ORS : OFS);}
    }
}
