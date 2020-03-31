#!/bin/bash

<<HEADER
Eric Fournier 2019-07-10

Fastqc
HEADER

source "/data/Applications/GitScript/JenkinsDev/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

for proj in "${projects_list[@]}"
	do
	PROJECT_NAME=$proj
	SetFinalPath $PROJECT_NAME
	
	sample_list=()
       
	id_list_file_name=$(cat ${SLBIO_PROJECT_PATH}"CurrentIDlistFileName.txt")
 
	while read myspec
	  do

	  if [ ! -s ${SLBIO_FASTQC_BRUT_PATH}${spec}"_R1_fastqc.html" ]
                  then
                  echo -e "Fastqc avant trimmomatic pour ${myspec} \t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
		  all_fastq_prior_trimmo=$(echo "${SLBIO_FASTQ_BRUT_PATH}${myspec}"*".fastq.gz")
                  fastqc -q   -o $SLBIO_FASTQC_BRUT_PATH $all_fastq_prior_trimmo

                  echo -e "Fastqc apres trimmomatic pour ${myspec} \t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
	          all_fastq_after_trimmo=$(echo "${SLBIO_FASTQ_TRIMMO_PATH}${myspec}"*".fastq.gz")
                  fastqc -q   -o $SLBIO_FASTQC_TRIMMO_PATH  $all_fastq_after_trimmo
		  rm "${SLBIO_FASTQC_BRUT_PATH}${myspec}"*".zip" 
	          rm "${SLBIO_FASTQC_TRIMMO_PATH}${myspec}"*".zip"
          fi
	

                    
	done <  ${id_list_file_name}

done


exit 0
