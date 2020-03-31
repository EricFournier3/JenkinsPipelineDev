#!/bin/bash
<<HEADER
Eric Fournier 20200330
HEADER

source "/data/Applications/GitScript/JenkinsDev/SetPath.sh"
SetStaticPath


echo "************* TESTING ERIC"

# TODO IL FAUT INDIQUER LA REFENCE MANQUANTE ET LE PIPELINE
# supprimer les fichier a la fin

#CHECK QUAST

slbio_temp_sample_sheet="${SLBIO_TEMP_CHECK_DIR}${RUN_NAME}.csv"
slbio_temp_quastref_file="${SLBIO_TEMP_CHECK_DIR}quastref.txt"
organism_list_file="${SLBIO_TEMP_CHECK_DIR}organism.txt"

sudo cp "${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_EXPERIMENTAL}${RUN_NAME}.csv"  ${slbio_temp_sample_sheet}
sudo cp ${PARAM_FILE} ${SLBIO_TEMP_CHECK_DIR} 

#sed -n '/annot_bact\|annot_myc/p' 99990101_test1_C1.csv | awk 'BEGIN{FS=","}{print $11}'
#sed -n '/annot_bact\|annot_myc\|assemb_bact\|assemb_myc/p' ${slbio_temp_sample_sheet} | awk 'BEGIN{FS=","}{print $11}' | sort | uniq  > ${organism_list_file}

sed -n '/annot_bact\|annot_myc\|assemb_bact\|assemb_myc/p' ${slbio_temp_sample_sheet} | awk 'BEGIN{FS=","}{print $11}'   > ${organism_list_file}

#sed -n '/^quast_ref/,/^quast_ref_path/p' JenkinsParameter.yaml | sed '1d;$d'
sed -n '/^quast_ref/,/^quast_ref_path/p' ${SLBIO_TEMP_CHECK_DIR}$(basename ${PARAM_FILE})  | sed '1d;$d'   >  $slbio_temp_quastref_file

#while read line;do echo $line;grep "${line}" JenkinsParameter.yaml;done < organism.txt

while read organism
 do
 echo "Organism is ${organism}"
done < ${organism_list_file}



#if grep -w  -qs 'Campylobacters jejuni' JenkinsParameter.yaml;then echo "FIND";else echo "NOT FIND";fi
#if grep -w -qs "${myv}" JenkinsParameter.yaml;then echo "FIND";else echo "NOT FIND";fi
  
