#!/bin/sh -ex
INPUT="${DATADIR}/scop"
INPUTDB="${RESULTS}/input"
SCOPANOTATION="${DATADIR}/scop_lookup_bench.tsv"
"${FOLDSEEK}" createdb "${INPUT}" "${INPUTDB}"

"${FOLDSEEK}" cluster "$INPUTDB"  "$RESULTS/results_clu" "$RESULTS/tmp" -c 0.9 --cov-mode 0 --min-seq-id 0 -s 9 
"${FOLDSEEK}" createtsv "$INPUTDB" "$INPUTDB" "$RESULTS/results_clu" "$RESULTS/results_clu.tsv"

"${EVALUATE}" "$SCOPANOTATION" "$RESULTS/results_clu.tsv" > "${RESULTS}/evaluation.log"
cat "${RESULTS}/evaluation.log"
ACTUAL=$(awk '{ if($3 > 0 && $4 == 0 ){ goodcluster+=1;} if($4 > 0){ badcluster+=1;} tp+=$3; fp+=$4; }END{print goodcluster,badcluster,tp,fp}' "${RESULTS}/evaluation.log")
TARGET="240 7 275 9"
awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual == target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"

