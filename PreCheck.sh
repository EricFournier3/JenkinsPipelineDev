#!/bin/bash
<<HEADER
Eric Fournier 20200330
HEADER

source "/data/Applications/GitScript/JenkinsDev/SetPath.sh"
SetStaticPath

#TODO supprimer les fichier a la fin

#TODO NE PAS EXECUTER CORESNV SI REFERENCE MANQUANTE    coresnv_warning_message

#TODO GERER FICHIER FASTQ TROP PETIT

warning_file=${SLBIO_TEMP_CHECK_DIR}"warnings.log"
slbio_temp_sample_sheet="${SLBIO_TEMP_CHECK_DIR}${RUN_NAME}.csv"

sudo cp "${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_EXPERIMENTAL}${RUN_NAME}.csv"  ${slbio_temp_sample_sheet}
sudo cp ${PARAM_FILE} ${SLBIO_TEMP_CHECK_DIR} 

core_snv_warning_message=$(echo $(grep 'coresnv_warning_message' ${PARAM_FILE}) | cut -d ':' -f 2)
core_snv_warning_message=$(echo ${core_snv_warning_message//\"/})


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
             echo -e "Missing CoreSNV reference for $spec in project $proj" >> ${warning_file}
           else
             echo -e "${yellow_message}""WARNING: CoreSNV reference ${organism} for $spec in project $proj is missing from JenkinsParameter.yaml"
	     echo -e "${white_message}"
             echo -e "CoreSNV reference ${organism} for $spec in project $proj is missing from JenkinsParameter.yaml" >> ${warning_file}
           fi
	 fi
	done < ${coresnv_organism_list_file}
	
	#echo "CANCELLED PROG ${cancelled_coresnvproj[@]}"
        for pr in ${cancelled_coresnvproj[@]}
          do
          echo -e "${core_snv_warning_message} ${pr}" >> ${warning_file}
	done
}

CheckQuast
CheckCoreSnv

if [ -s ${warning_file} ]
  then
  cp ${warning_file} $SLBIO_RUN_PATH
fi

sudo rm "${SLBIO_TEMP_CHECK_DIR}"*
