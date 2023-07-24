#!/usr/bin/env bash
###
#Written by Luis Abatti

###########################
#### This script will merge two .fq.gz files and reassign their sequence index by descending order
#### Usage: "./merge_fastq.sh input_F.fq.gz input_R.fq.gz output.fq.gz"
###########################

FASTQ_FILE_F=$1

#Checks if 1st FASTQ file exists

if [[ -z "${FASTQ_FILE_F}" ]]; then
    echo "Must provide path to fastq file 1" 1>&2
    exit 1
elif [[ ! -f "${FASTQ_FILE_F}" ]]; then
    echo ".fastq file 1 does not exist" 1>&2
    exit 1
elif [[ -d "${FASTQ_FILE_F}" ]]; then
    echo "Path to .fastq file 1 path is a directory, not a file" 1>&2
    exit 1
elif [[ -f "${FASTQ_FILE_F}" ]]; then
    echo "Reading .fastq file 1 ${FASTQ_FILE_F}"
fi

if [[ "$FASTQ_FILE_F" == *.fq ]] || [[ "$FASTQ_FILE_F" == *.fastq ]]; then
   echo ".fastq file 1 is not compressed";
   echo "Compressing .fastq file 1..."
   gzip -k ${FASTQ_FILE_F};
   FASTQ_FILE_F=${FASTQ_FILE_F}.gz
fi

#Checks if 2nd FASTQ file exists

FASTQ_FILE_R=$2

if [[ -z "${FASTQ_FILE_R}" ]]; then
    echo "Must provide path to fastq file 2" 1>&2
    exit 1
elif [[ ! -f "${FASTQ_FILE_R}" ]]; then
    echo ".fastq file 2 does not exist" 1>&2
    exit 1
elif [[ -d "${FASTQ_FILE_R}" ]]; then
    echo "Path to .fastq file 2 path is a directory, not a file" 1>&2
    exit 1
elif [[ -f "${FASTQ_FILE_R}" ]]; then
    echo "Reading .fastq file 2 ${FASTQ_FILE_R}"
fi

if [[ "$FASTQ_FILE_R" == *.fq ]] || [[ "$FASTQ_FILE_R" == *.fastq ]]; then
   echo ".fastq file 2 is not compressed";
   echo "Compressing .fastq file 2..."
   gzip -k ${FASTQ_FILE_R}
   FASTQ_FILE_R=${FASTQ_FILE_R}.gz
fi

#Checks if path to merged FASTQ file exists

FASTQ_FILE_MERGED=$3

if [[ -z "${FASTQ_FILE_MERGED}" ]]; then
    echo "Must provide path to export merged .fastq file" 1>&2
    exit 1
elif [[ -f "${FASTQ_FILE_MERGED}" ]]; then
    echo "Merged .fastq file already exists" 1>&2
    exit 1
elif [[ -d "${FASTQ_FILE_MERGED}" ]]; then
    echo "Path to merged .fastq file is a directory, not a file" 1>&2
    exit 1
elif [[ "${FASTQ_FILE_MERGED}" == *.fastq ]] || [[ "${FASTQ_FILE_MERGED}" == *.fq ]]; then
   FASTQ_FILE_MERGED=${FASTQ_FILE_MERGED}.gz
elif [[ ! -f "${FASTQ_FILE_MERGED}" ]]; then
    echo "Merged file will be exported as ${FASTQ_FILE_MERGED}"
fi


FASTQ_FILE_F_LINES=$(zgrep '^@' ${FASTQ_FILE_F} | wc -l)
echo ".fastq file 1 has ${FASTQ_FILE_F_LINES} entries"

FASTQ_FILE_R_LINES=$(zgrep '^@' ${FASTQ_FILE_R} | wc -l)
echo ".fastq file 2 has ${FASTQ_FILE_R_LINES} entries"

FASTQ_FILE_LINES=$(($FASTQ_FILE_F_LINES + $FASTQ_FILE_R_LINES))
echo "Merged .fastq file should have ${FASTQ_FILE_LINES} lines in total"

cat ${FASTQ_FILE_F} ${FASTQ_FILE_R} | zcat | awk '{for(i=1;i<=NF;i++){if($i~/(@[0-9]+)/){sub(/(@[0-9]+)/,"@"++count,$i)}}} 1' | gzip > ${FASTQ_FILE_MERGED}
#### Replace lines with "@number" incrementing order
echo "Merged ${FASTQ_FILE_F} and ${FASTQ_FILE_R} into ${FASTQ_FILE_MERGED}"



FASTQ_MERGED_LINES=$(zgrep '^@' ${FASTQ_FILE_MERGED} | wc -l)
echo "Merged .fastq file has ${FASTQ_MERGED_LINES} lines in total"

if [[ ${FASTQ_MERGED_LINES} -eq ${FASTQ_FILE_LINES} ]]; then
    echo "${FASTQ_FILE_MERGED} has the correct amount of entries"
else
    echo "Something went wrong, the number of entries is not the expected number"
    exit 1
fi

echo "DONE!"



