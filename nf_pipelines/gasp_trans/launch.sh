#$ -pe openmp 2
#$ -l m_mem_free=4G
export NXF_OPTS="-Xms500M -Xmx4G"
source $HOME/.research_config
nextflow pull timothy-barry/sceptre-pipeline

##########################
# REQUIRED INPUT ARGUMENTS
##########################
data_directory=$LOCAL_GASPERINI_2019_V3_DATA_DIR"at-scale/processed/"
project_directory=$LOCAL_SCEPTRE3_DATA_DIR"/nf_pipelines/gasp_trans/"
# sceptre object
sceptre_object_fp=$project_directory"sceptre_object.rds"
# response ODM
response_odm_fp=$data_directory"response.odm"
# grna ODM
grna_odm_fp=$data_directory"grna.odm"

##################
# OUTPUT DIRECTORY
##################
output_directory=$project_directory"sceptre_outputs"

#################
# Invoke pipeline
#################
nextflow run timothy-barry/sceptre-pipeline -r main -with-trace -profile profile_16xl \
 --sceptre_object_fp $sceptre_object_fp \
 --response_odm_fp $response_odm_fp \
 --grna_odm_fp $grna_odm_fp \
 --output_directory $output_directory \
 --grna_assignment_method mixture \
 --pair_pod_size 200000 \
 --grna_pod_size 250 \
 --discovery_pairs trans
 