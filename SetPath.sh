#!/bin/bash

<<HEADER
Eric Fournier 2019-07-09

HEADER
CURRENT_YEAR=$(echo $(date +'%Y'))
PARAM_FILE="/data/Applications/GitScript/JenkinsDev/JenkinsParameter.yaml"
GET_PARAM_SCRIPT="/data/Applications/GitScript/Jenkins/GetJenkinsParamVal.py"
RUN_QUAL_SCRIPT="/data/Applications/GitScript/MiSeqRunQuality/MiSeqStat7.py"
GET_SPECIMENS_SCRIPT="/data/Applications/GitScript/Jenkins/GetSpecimensForTask.py"
COMPUTE_SAMPLE_COVERAGE_SCRIPT="/data/Applications/GitScript/MiSeqRunQuality/ComputeExpectedGenomesCoverage.py"
CORESNV_REFERENCE_SCRIPT="/data/Applications/GitScript/Jenkins/CheckCoreSnvReference.py"
QUAST_REFERENCE_SCRIPT="/data/Applications/GitScript/Jenkins/CheckQuastReference.py"
CORESNV_EXEC="/data/Applications/SnvPhyl_Client/snvphyl-galaxy-cli/bin/snvphyl.py"
POSITION2PHYLOVIZ_SCRIPT="/data/Applications/GitScript/Jenkins/positions2phyloviz.pl"
FUNANNOTATE_SCRIPT="/home/foueri01@inspq.qc.ca/InternetProgram/Funannotate/funannotate/funannotate.py"
GRAPETREE_SCRIPT="/data/Applications/GrapeTree/grapetree.py"
PARSE_SPEC_TAXON_SCRIPT="/data/Applications/GitScript/Jenkins/ParseQiime.awk"
SILVA_CLASSIFIER="/data/Applications/Miniconda/miniconda3/envs/qiime2-2019.10/Classifier/silva-132-99-nb-classifier.qza"
GREENGENE_CLASSIFIER="/data/Applications/Miniconda/miniconda3/envs/qiime2-2019.10/Classifier/gg-13-8-99-nb-classifier.qza"
QIIME_TEMPLATE_SAMPLE_SHEET="/data/Applications/GitScript/Metagenomic/BasicWorkSheetTemplate2.tsv"
AUGUSTUS_SPECIES_DIR="/data/Databases/FunannotateDB_v171/trained_species/"
KRAKENDB="/data/Databases/KRAKEN_DB"
CENTRIFUGEDB="/data/Databases/CENTRIFUGE_DB/abv"
CLARKDB="/data/Databases/CLARK_DB"
CORE_SNV_GALAXY_URL="http://localhost:48890/"
CORE_SNV_GALAXY_KEY="0abbae19c25ebcf2d75f059af756ea05"
core_snv_warning_message=$(echo $(grep 'coresnv_warning_message' ${PARAM_FILE}) | cut -d ':' -f 2)
core_snv_warning_message=$(echo ${core_snv_warning_message//\"/})

slbio_user=$(whoami)
ldap_user=$(echo ${slbio_user} | cut -d '@' -f 1)
PASS_FILE="/home/${slbio_user}/pass.txt"

green_message="\e[32m"
white_message="\e[39m"
red_message="\e[31m"
yellow_message="\e[33m"

nb_mounted_rep=$(ls /mnt/Partage/ | wc -l)

if [ $nb_mounted_rep -gt 0 ]
        then
	echo -e "${green_message}INFO: " "/mnt/Partage/ already mounted"
	echo -e "${white_message}"
        
else
        echo -e "${yellow_message}INFO: " "/mnt/Partage/ not mounted. Try to mount now ..."
	echo -e "${white_message}"
        read pw < $PASS_FILE
        sudo mount -t cifs -o username=${ldap_user},password=$pw,vers=3.0 "//swsfi52p/partage" /mnt/Partage
fi

errno=$?

if [ $errno -eq 0 ]
        then
        :
else
        echo -e "${red_message}ERROR: " "unable to mount /mnt/Partage/. Program exit now !"
        exit 1
fi


SetStaticPath(){

        green_message="\e[32m"
        white_message="\e[39m"
	red_message="\e[31m"
	yellow_message="\e[33m"


        path_arr=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  path  2>&1))
        LSPQ_MISEQ_BASE_PATH=${path_arr[0]}"/"
        SLBIO_BASE_PATH=${path_arr[1]}"/"
        GITSCRIPT_BASE_PATH=${path_arr[2]}"/"
	LSPQ_MISEQ_BASE_PATH_FROM_SPARTAGE=${path_arr[3]}"\\\\"

        lspq_miseq_subdir_arr=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  lspq_miseq_subdir  2>&1))
        LSPQ_MISEQ_EXPERIMENTAL=${lspq_miseq_subdir_arr[0]}"/"
	LSPQ_MISEQ_MISEQ_RUN_TRACE=${lspq_miseq_subdir_arr[1]}"/"
        LSPQ_MISEQ_SEQ_BRUT=${lspq_miseq_subdir_arr[2]}"/"
        LSPQ_ANALYSES=${lspq_miseq_subdir_arr[3]}"/"


        slbio_subdir_arr=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  slbio_subdir  2>&1))
        SLBIO_FASTQ_BRUT=${slbio_subdir_arr[0]}"/"
        SLBIO_FASTQC_1=${slbio_subdir_arr[1]}"/"
        SLBIO_FASTQ_TRIMMO=${slbio_subdir_arr[2]}"/"
        SLBIO_FASTQC_2=${slbio_subdir_arr[3]}"/"
	SLBIO_SPADES=${slbio_subdir_arr[4]}"/"
	SLBIO_SPADES_BRUT=${SLBIO_SPADES}${slbio_subdir_arr[5]}"/"
	SLBIO_SPADES_FILTER=${SLBIO_SPADES}${slbio_subdir_arr[6]}"/"
	SLBIO_SPADES_QC=${slbio_subdir_arr[7]}"/"
	SLBIO_SPADES_QC_QUALIMAP=${SLBIO_SPADES_QC}${slbio_subdir_arr[8]}"/"
	SLBIO_SPADES_QC_QUAST=${SLBIO_SPADES_QC}${slbio_subdir_arr[9]}"/"
	SLBIO_PROKKA=${slbio_subdir_arr[10]}"/"
	SLBIO_FUNANNOTATE=${slbio_subdir_arr[11]}"/"
	SLBIO_CORESNV=${slbio_subdir_arr[12]}"/"
	SLBIO_QIIME=${slbio_subdir_arr[13]}"/"
	SLBIO_LOG=${slbio_subdir_arr[14]}"/"
	SLBIO_WEBREPORT=${slbio_subdir_arr[15]}"/"
	SLBIO_METAGENOMIC_SHOTGUN=${slbio_subdir_arr[16]}"/"
	SLBIO_KRAKEN=${SLBIO_METAGENOMIC_SHOTGUN}${slbio_subdir_arr[17]}"/"
	SLBIO_CENTRIFUGE=${SLBIO_METAGENOMIC_SHOTGUN}${slbio_subdir_arr[18]}"/"
	SLBIO_CLARK=${SLBIO_METAGENOMIC_SHOTGUN}${slbio_subdir_arr[19]}"/"
	SLBIO_CORESNV_MAP_DIR=${slbio_subdir_arr[20]}"/"
	GENOME_LENGTH_FILE=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  genome_length_file  2>&1))
	RUN_YEAR=${RUN_NAME:0:4}
        SLBIO_RUN_PATH=${SLBIO_BASE_PATH}"$RUN_NAME/"
	LSPQ_MISEQ_RUN_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}/
        SLBIO_TEMP_CHECK_DIR="/data/temp/TEMP_JENKINS_CHECK/" 
}


SetFinalPath(){
	PROJECT_NAME=$1
        LSPQ_MISEQ_RUN_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}/
	LSPQ_MISEQ_RUN_PATH_FROM_SPARTAGE=${LSPQ_MISEQ_BASE_PATH_FROM_SPARTAGE}${RUN_YEAR}"\\\\"${RUN_NAME}"\\\\"
	LSPQ_MISEQ_ANALYSES_PATH=${LSPQ_MISEQ_RUN_PATH}${LSPQ_ANALYSES}
	LSPQ_MISEQ_ANALYSIS_PROJECT_PATH=${LSPQ_MISEQ_ANALYSES_PATH}${PROJECT_NAME}/
	LSPQ_MISEQ_ANALYSE_PATH_FROM_SPARTAGE=${LSPQ_MISEQ_RUN_PATH_FROM_SPARTAGE}${LSPQ_ANALYSES}
        LSPQ_MISEQ_SAMPLESHEET_PATH=${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_EXPERIMENTAL}"${RUN_NAME}.csv"
        LSPQ_MISEQ_FASTQ_PATH=${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_SEQ_BRUT}

        LSPQ_MISEQ_RUNQUALFILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}"/"${LSPQ_MISEQ_MISEQ_RUN_TRACE}"MiSeqStat_"*
	LSPQ_MISEQ_PROJ_DESC_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}"/"${LSPQ_MISEQ_EXPERIMENTAL}${PROJECT_NAME}"_desc.txt"

        SLBIO_RUN_PATH=${SLBIO_BASE_PATH}"$RUN_NAME/"
        SLBIO_PROJECT_PATH=${SLBIO_RUN_PATH}"$PROJECT_NAME/"
        SLBIO_FASTQ_BRUT_PATH=${SLBIO_PROJECT_PATH}${SLBIO_FASTQ_BRUT}
	SLBIO_FASTQC_BRUT_PATH=${SLBIO_PROJECT_PATH}${SLBIO_FASTQC_1}	
        SLBIO_FASTQ_TRIMMO_PATH=${SLBIO_PROJECT_PATH}${SLBIO_FASTQ_TRIMMO}
        SLBIO_FASTQC_TRIMMO_PATH=${SLBIO_PROJECT_PATH}${SLBIO_FASTQC_2}
	SLBIO_SPADES_PATH=${SLBIO_PROJECT_PATH}${SLBIO_SPADES}
        SLBIO_SPADES_BRUT_PATH=${SLBIO_PROJECT_PATH}${SLBIO_SPADES_BRUT}
	SLBIO_SPADES_FILTER_PATH=${SLBIO_PROJECT_PATH}${SLBIO_SPADES_FILTER}
	SLBIO_SPADES_QC_PATH=${SLBIO_PROJECT_PATH}${SLBIO_SPADES_QC}
	SLBIO_SPADES_QC_QUALIMAP_PATH=${SLBIO_PROJECT_PATH}${SLBIO_SPADES_QC_QUALIMAP}
        SLBIO_SPADES_QC_QUAST_PATH=${SLBIO_PROJECT_PATH}${SLBIO_SPADES_QC_QUAST}
	SLBIO_SPADES_QC_QUAST_ALL=${SLBIO_SPADES_QC_QUAST_PATH}"ALL/"
	SLBIO_PROKKA_PATH=${SLBIO_PROJECT_PATH}${SLBIO_PROKKA}
	SLBIO_FUNANNOTATE_PATH=${SLBIO_PROJECT_PATH}${SLBIO_FUNANNOTATE}
	SLBIO_CORESNV_PATH=${SLBIO_PROJECT_PATH}${SLBIO_CORESNV}
	SLBIO_QIIME_PATH=${SLBIO_PROJECT_PATH}${SLBIO_QIIME}
        SLBIO_LOG_PATH=${SLBIO_PROJECT_PATH}${SLBIO_LOG}
        SLBIO_LOG_FILE=${SLBIO_LOG_PATH}"JenkinsLog.log"
	LSPQ_MISEQ_SAMPLE_LIST_TO_ADD_FILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}"/1_Experimental/CoreSnvSamplesToAdd_"${RUN_NAME}"_${PROJECT_NAME}.txt"
	LSPQ_MISEQ_CORESNV_METADATA_FILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}"/1_Experimental/CoreSnvMetadata_"${RUN_NAME}"_${PROJECT_NAME}.txt"
	SLBIO_WEBREPORT_PATH=${SLBIO_PROJECT_PATH}${SLBIO_WEBREPORT}
	SLBIO_METAGENOMIC_SHOTGUN_PATH=${SLBIO_PROJECT_PATH}${SLBIO_METAGENOMIC_SHOTGUN}
	SLBIO_KRAKEN_PATH=${SLBIO_PROJECT_PATH}${SLBIO_KRAKEN}
	SLBIO_CENTRIFUGE_PATH=${SLBIO_PROJECT_PATH}${SLBIO_CENTRIFUGE}
	SLBIO_CLARK_PATH=${SLBIO_PROJECT_PATH}${SLBIO_CLARK}

	LSPQ_MISEQ_TRACE_PATH=${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_MISEQ_RUN_TRACE}

}

GetProjectsNamefromRunName(){
        projects_list_temp=$(echo $RUN_NAME | cut -d '_' -f 2)
        IFS_BKP=$IFS
        IFS='-'
        read -r -a projects_list <<< "$projects_list_temp"

        IFS=$IFS_BKP
}


GetCurrentCartridge(){
   current_cartridge_list=()

  if [ "$1" = "newpipeline" ]
    then
    echo ${SLBIO_PROJECT_PATH}"CartridgeDone.txt"
    while read cartridge
      do
      done_cartridge_list+=(${cartridge})
    done < ${SLBIO_PROJECT_PATH}"CartridgeDone.txt"

    current_cartridge_list=(${done_cartridge_list[@]})
    return 
  fi

  if [ -f ${SLBIO_PROJECT_PATH}"CartridgeDone.txt" ]
    then
    new_run="false"
    done_cartridge_list=()

    while read cartridge
      do
      done_cartridge_list+=(${cartridge})
    done < ${SLBIO_PROJECT_PATH}"CartridgeDone.txt"

    for catrdg in ${all_cartridge_list[@]}
      do
        if [[ " ${done_cartridge_list[@]} " =~ " $catrdg " ]]
          then
          :
        else
         current_cartridge_list+=${catrdg}

        fi
    done

  else
    new_run="true"
    current_cartridge_list=(${all_cartridge_list[@]})
  fi

 
  for cartridge in ${current_cartridge_list[@]}
    do
    echo $cartridge >>  ${SLBIO_PROJECT_PATH}"CartridgeDone.txt"

  done
}

GetAllCartridge(){
  all_cartridge_list=()
  for cartridge in $(ls -d "${LSPQ_MISEQ_TRACE_PATH}"*"/")
    do
    all_cartridge=$(basename ${cartridge})
    all_cartridge_list+=(${all_cartridge})
  done
 
}


GetDoneCartridge(){
  done_cartridge_list=()

  if [ -f ${SLBIO_PROJECT_PATH}"CartridgeDone.txt" ]
    then
    while read cartridge
      do
      done_cartridge_list+=(${cartridge})
     done < ${SLBIO_PROJECT_PATH}"CartridgeDone.txt" 
  
  fi
}

BuildSampleSheetName(){

  if [ "$1" = "newpipeline" ]
    then 
    final_sample_sheet_name="$2"
    samplesheet_suffix=$(echo ${final_sample_sheet_name/%.csv/} | cut -d '_' -f 3)
    id_list_file_name="ID_list_"${samplesheet_suffix}".txt"
    echo ${SLBIO_PROJECT_PATH}${id_list_file_name} > ${SLBIO_PROJECT_PATH}"CurrentIDlistFileName.txt"
    echo ${SLBIO_PROJECT_PATH}${final_sample_sheet_name} > ${SLBIO_PROJECT_PATH}"CurrentSampleSheetName.txt"
    return 
  fi


  suffix=$(printf "%s_" "${current_cartridge_list[@]}")
  samplesheet_suffix=${suffix%_}
  prefix=${RUN_NAME}

  final_sample_sheet_name=${prefix}_${samplesheet_suffix}"_final.csv"
  id_list_file_name="ID_list_"${samplesheet_suffix}".txt"

  echo ${SLBIO_PROJECT_PATH}${id_list_file_name} > ${SLBIO_PROJECT_PATH}"CurrentIDlistFileName.txt"  
  echo ${SLBIO_PROJECT_PATH}${final_sample_sheet_name} > ${SLBIO_PROJECT_PATH}"CurrentSampleSheetName.txt" 
}


