#!/bin/bash
<<HEADER
Eric Fournier 20200330
HEADER

source "/data/Applications/GitScript/JenkinsDev/SetPath.sh"
SetStaticPath

#TODO GERER FICHIER FASTQ TROP PETIT

sudo rm "${SLBIO_TEMP_CHECK_DIR}"* 2>/dev/null

if [ ${PARAM_SAMPLESHEET_NAME} = "no_sample_sheet" ]
  then
  slbio_temp_sample_sheet="${SLBIO_TEMP_CHECK_DIR}${RUN_NAME}.csv"
  sudo cp "${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_EXPERIMENTAL}${RUN_NAME}.csv"  ${slbio_temp_sample_sheet}
else
  slbio_temp_sample_sheet="${SLBIO_TEMP_CHECK_DIR}${PARAM_SAMPLESHEET_NAME}"
  sudo cp "${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_EXPERIMENTAL}${PARAM_SAMPLESHEET_NAME}"  ${slbio_temp_sample_sheet}
fi

warning_file=${SLBIO_TEMP_CHECK_DIR}"warnings_$(basename ${slbio_temp_sample_sheet}).log"

sudo cp ${PARAM_FILE} ${SLBIO_TEMP_CHECK_DIR} 


CheckQuast(){

	slbio_temp_quastref_file="${SLBIO_TEMP_CHECK_DIR}quastref.txt"
	quast_organism_list_file="${SLBIO_TEMP_CHECK_DIR}quast_organism.txt"

	sed -n '/annot_bact\|annot_myc\|assemb_bact\|assemb_myc/p' ${slbio_temp_sample_sheet} | awk 'BEGIN{FS=","}{print $1"\t"$9"\t"$11}'   > ${quast_organism_list_file}

	sed -n '/^quast_ref/,/^quast_ref_path/p' ${SLBIO_TEMP_CHECK_DIR}$(basename ${PARAM_FILE})  | sed '1d;$d'   >  $slbio_temp_quastref_file

	while read spec proj organism
	 do
	 if   [ ${#organism} -gt 0 ] && grep -w -qs "${organism}" ${slbio_temp_quastref_file} 
	   then
           :
	 else
           if [ ${#organism} = 0 ]
             then
             echo -e "${yellow_message}""WARNING: Missing Quast reference for $spec in project $proj"
	     echo -e "${white_message}"
             echo -e "Missing Quast reference for $spec in project $proj" >> ${warning_file}
           else
             echo -e "${yellow_message}""WARNING: Quast reference ${organism} for $spec in project $proj is missing from JenkinsParameter.yaml"
	     echo -e "${white_message}"
             echo -e "Quast reference ${organism} for $spec in project $proj is missing from JenkinsParameter.yaml" >> ${warning_file}
           fi
	 fi
	done < ${quast_organism_list_file}

}  

CheckCoreSnv(){

        cancelled_coresnvproj=()

	slbio_temp_coresnvref_file="${SLBIO_TEMP_CHECK_DIR}coresnvref.txt"
	coresnv_organism_list_file="${SLBIO_TEMP_CHECK_DIR}coresnv_organism.txt"

	sed -n '/epidemio/p' ${slbio_temp_sample_sheet} | awk 'BEGIN{FS=","}{print $1"\t"$9"\t"$11}'   > ${coresnv_organism_list_file}
	sed -n '/^coresnv_ref/,/^coresnv_ref_path/p' ${SLBIO_TEMP_CHECK_DIR}$(basename ${PARAM_FILE})  | sed '1d;$d'   >  $slbio_temp_coresnvref_file

	while read spec proj organism
	 do
	 if   [ ${#organism} -gt 0 ] && grep -w -qs "${organism}" ${slbio_temp_coresnvref_file} 
	   then
           :
	 else

	   if [[ " ${cancelled_coresnvproj[@]} " =~ " $proj " ]]
	     then
             :
           else
                cancelled_coresnvproj+=($proj)
	   fi

           if [ ${#organism} = 0 ]
             then
             echo -e "${yellow_message}""WARNING: Missing CoreSNV reference for $spec in project $proj"
	     echo -e "${white_message}"
             echo -e "Missing CoreSNV reference for $spec in project $proj / $(basename ${slbio_temp_sample_sheet})" >> ${warning_file}
           else
             echo -e "${yellow_message}""WARNING: CoreSNV reference ${organism} for $spec in project $proj is missing from JenkinsParameter.yaml"
	     echo -e "${white_message}"
             echo -e "CoreSNV reference ${organism} for $spec in project $proj / $(basename ${slbio_temp_sample_sheet})  is missing from JenkinsParameter.yaml" >> ${warning_file}
           fi
	 fi
	done < ${coresnv_organism_list_file}
	
        for pr in ${cancelled_coresnvproj[@]}
          do
          echo -e "${core_snv_warning_message} ${pr} / $(basename ${slbio_temp_sample_sheet})" >> ${warning_file}
	done
}

CheckQuast
CheckCoreSnv

if [ -s "${SLBIO_RUN_PATH}$(basename ${warning_file})" ]
  then
  sudo rm "${SLBIO_RUN_PATH}$(basename ${warning_file})" 
fi

if [ -s ${warning_file} ]
  then
  cp ${warning_file} $SLBIO_RUN_PATH
fi

sudo rm "${SLBIO_TEMP_CHECK_DIR}"*
