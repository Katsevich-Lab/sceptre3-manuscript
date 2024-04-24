gasp_offsite <- paste0(.get_config_path("LOCAL_GASPERINI_2019_V3_DATA_DIR"), "at-scale/processed/")
sceptre3_offsite <- paste0(.get_config_path("LOCAL_SCEPTRE3_DATA_DIR"), "nf_pipelines/gasp_trans/")

library(sceptre)
sceptre_object <- read_ondisc_backed_sceptre_object(
  sceptre_object_fp = paste0(gasp_offsite, "sceptre_object.rds"),
  response_odm_file_fp = paste0(gasp_offsite, "response.odm"),
  grna_odm_file_fp = paste0(gasp_offsite, "grna.odm")
)
# set analysis params
sceptre_object <- set_analysis_parameters(
  sceptre_object = sceptre_object,
  resampling_mechanism = "permutations",
  side = "both"
)

# write sceptre_object
write_ondisc_backed_sceptre_object(sceptre_object = sceptre_object,
                                   directory_to_write = sceptre3_offsite)
