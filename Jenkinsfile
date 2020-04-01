pipeline {
    agent any

    parameters{
                string(name: 'runName', defaultValue: 'TestRun', description: 'nom de la run MiSeq')
                string(name: 'SampleSheetName', defaultValue: 'no_sample_sheet', description: 'Sample sheet en parametre')
    }


    stages   {
        stage('InputRunName') {

                            steps {

                                echo "Stage InputRunName"
                                sh "/data/Applications/GitScript/JenkinsDev/CheckRunName.sh ${params.runName} ${params.SampleSheetName}"
                            }
        }
        stage('Init'){
            environment{
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "Stage Init"
                    sh 'echo "In Jenkins file $RUN_NAME"'
                    //sh "/data/Applications/GitScript/JenkinsDev/InitGenomicPipeline.sh"
                    //plus necessaire le ComputeMiSeqStat
                    //sh "/data/Applications/GitScript/JenkinsDev/Tools.sh ComputeMiSeqStat"
		    //plus necessaire le check CoreSnvReference
                    //sh '/data/Applications/GitScript/JenkinsDev/Tools.sh CoreSnvReference'
            }
        }
        stage('PreCheck'){
            environment{
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "Stage PreCheck"
                sh "/data/Applications/GitScript/JenkinsDev/PreCheck.sh"
            }
            
        }
        stage('Trimmomatic'){
            environment{
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "Stage Trimmomatic"
                sh "/data/Applications/GitScript/JenkinsDev/DoTrimmomatic.sh"
            }
        }
        stage('Fastqc'){
            environment{
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "Stage Fastqc"
                //sh "/data/Applications/GitScript/JenkinsDev/DoFastqc.sh"
            }
        }
        stage('Metagenomic'){
            environment{
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "Stage Metagenomic"
                //sh "/data/Applications/GitScript/JenkinsDev/DoMetagenomic.sh"
            }
        }
        stage('Spades'){
            environment{
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "Stage Spades"
                //sh "/data/Applications/GitScript/JenkinsDev/DoSpades.sh"
            }
        }
        stage('Qualimap'){
            environment{
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "Stage Qualimap"
                //sh "/data/Applications/GitScript/JenkinsDev/DoQualimap.sh"
            }
        }
        stage('Quast'){
            environment{
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "Stage Quast"
                /*
                sh '''#!/bin/bash
                    . /data/Applications/Miniconda/miniconda3/bin/activate /data/Applications/Miniconda/miniconda3/envs/Quast
                    /data/Applications/GitScript/JenkinsDev/DoQuast.sh
                    conda deactivate
                '''
                */
                
                
            }
        }
        stage('Prokka'){
            environment{
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "Stage Prokka"
                /*
                sh '''#!/bin/bash
                    . /data/Applications/Miniconda/miniconda3/bin/activate /data/Applications/Miniconda/miniconda3/envs/Prokka
                    /data/Applications/GitScript/JenkinsDev/DoProkka.sh
                    conda deactivate
                '''
                */
                
            }
        }
        stage('CoreSNV'){
            environment{
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "Stage CoreSNV"
                //sh "/data/Applications/GitScript/JenkinsDev/DoCoreSNV.sh"
            }
        }
        stage('Funannotate'){
            environment{
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "Stage Funannotate"
                /*
                sh '''#!/bin/bash
                    . /data/Applications/Miniconda/miniconda3/bin/activate /data/Applications/Miniconda/miniconda3/envs/funannotate_shared_v171
                    /data/Applications/GitScript/JenkinsDev/DoFunannotate.sh
                    conda deactivate
                '''
                */
            }
        }
	stage('Qiime'){
            environment{   
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "Stage Qiime"
                /*
                sh '''#!/bin/bash
                    . /data/Applications/Miniconda/miniconda3/bin/activate /data/Applications/Miniconda/miniconda3/envs/qiime2-2019.10
                    /data/Applications/GitScript/JenkinsDev/DoQiime2.sh
                    conda deactivate
                '''
                */
                
            }
        }
        stage('RunStat'){
            environment{
                RUN_NAME = "${params.runName}"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "In Stage RunStat"
                //voir https://stackoverflow.com/questions/40213654/how-to-invoke-bash-functions-defined-in-a-resource-file-from-a-jenkins-pipeline?rq=1
                /*
                sh '''#!/bin/bash
                      /data/Applications/GitScript/JenkinsDev/Tools.sh CountReads
                      /data/Applications/GitScript/JenkinsDev/Tools.sh ComputeExpectedGenomesCoverage
                '''
                */
            }
        }
        stage('WebReport'){
            environment{
                RUN_NAME = "${params.runName}"
                STAGE = "WEB_REPORT"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "In Stage WebReport"
                /*
                sh '''#!/bin/bash
                /data/Applications/GitScript/JenkinsDev/BuildWebReportV2.sh
                /data/Applications/GitScript/JenkinsDev/Tools.sh AddNumericPrefixToSubdir
                '''
                */
                
                
            }
        }
         stage('Clean'){
            environment{
                RUN_NAME = "${params.runName}"
                STAGE = "CLEAN"
                PARAM_SAMPLESHEET_NAME = "${params.SampleSheetName}"
            }
            steps{
                echo "In Stage Clean"
                /*
                sh '''#!/bin/bash
                      /data/Applications/GitScript/JenkinsDev/Tools.sh Clean
                      /data/Applications/GitScript/JenkinsDev/Tools.sh AddNumericPrefixToSubdir
                    '''
                */
                    
            }
        }
    }
}


