#!/bin/bash

<<HEADER
Eric Fournier 2019-07-10

Prokka

HEADER

#PROKKA_EXEC="prokka --addgenes --compliant --force --cpus 28 --quiet" # l'option --compliant modifie le nom des contigs dans le fichier .gbk
PROKKA_EXEC="prokka --addgenes  --force --cpus 28 --quiet" 

source "/data/Applications/GitScript/JenkinsDev/SetPath.sh"

SetStaticPath
GetProjectsNamefromRunName

STEP="Prokka"

CheckIfProkkaAlreadyDone(){
  if [ -d ${SLBIO_PROKKA_PATH}${1} ]
    then
    prokka_done="true"
  else
    prokka_done="false"
  fi
}


for proj in "${projects_list[@]}"
	do
	PROJECT_NAME=$proj
        SetFinalPath $PROJECT_NAME
	SAMPLE_SHEET=$(cat ${SLBIO_PROJECT_PATH}"CurrentSampleSheetName.txt")

        spec_arr=($(/usr/bin/python2.7 $GET_SPECIMENS_SCRIPT  $PARAM_FILE  $SAMPLE_SHEET $STEP  2>&1))

	if [ ${#spec_arr[@]} -gt 0 ]
		then

		if [ -d ${SLBIO_PROKKA_PATH} ]
		  then
		  :
                else
		  mkdir ${SLBIO_PROKKA_PATH}
		fi

		for spec in "${spec_arr[@]}"
			do

			CheckIfProkkaAlreadyDone ${spec}

			if [ "${prokka_done}" = "true" ]
			  then
			  continue
			fi

			FASTA_FILTERED=${SLBIO_SPADES_FILTER_PATH}${spec}"_filter.fasta"
			OUTDIR=${SLBIO_PROKKA_PATH}${spec}
			echo -e "Annotation Prokka pour ${spec}\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
			PROKKA_CMD="${PROKKA_EXEC} --outdir $OUTDIR --prefix $spec --locustag $spec $FASTA_FILTERED"
			eval $PROKKA_CMD
                        sed -i  '/LOCUS/s/\.000000/ /g' "${OUTDIR}/"*".gbk"
		done
	fi
done

exit 0

