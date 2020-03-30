#!/bin/bash

<<HEADER
Eric Fournier 2019-07-10

Fastqc
HEADER

source "/data/Applications/GitScript/JenkinsDev/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

if [  "${PARAM_SAMPLESHEET_NAME}" = "no_sample_sheet" ]
  then

	for proj in "${projects_list[@]}"
		do
		PROJECT_NAME=$proj
		SetFinalPath $PROJECT_NAME
		
		sample_list=()
	       
		id_list_file_name=$(cat ${SLBIO_PROJECT_PATH}"CurrentIDlistFileName.txt")
	 
		while read myspec
		  do
		  sample_list+=($myspec)          
		done <  ${id_list_file_name}

		all_fastq_prior_trimmo=($(echo ${sample_list[@]/#/${SLBIO_FASTQ_BRUT_PATH}}))
		all_fastq_prior_trimmo="${all_fastq_prior_trimmo[@]/%/_*.fastq.gz}"
		echo -e "Fastqc avant trimmomatic \t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
		fastqc -q   -o $SLBIO_FASTQC_BRUT_PATH $all_fastq_prior_trimmo

		all_fastq_after_trimmo=($(echo ${sample_list[@]/#/${SLBIO_FASTQ_TRIMMO_PATH}}))
		all_fastq_after_trimmo="${all_fastq_after_trimmo[@]/%/_*.fastq.gz}"

		echo -e "Fastqc après trimmomatic \t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
		fastqc -q   -o $SLBIO_FASTQC_TRIMMO_PATH  $all_fastq_after_trimmo


		rm "$SLBIO_FASTQC_BRUT_PATH"*".zip" 
		rm "$SLBIO_FASTQC_TRIMMO_PATH"*".zip"
	done
else
  :
fi

exit 0

