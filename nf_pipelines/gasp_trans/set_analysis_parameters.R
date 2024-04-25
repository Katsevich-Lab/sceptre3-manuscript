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

# update the grna target table; randomly assign nt grnas to groups of size 2
set.seed(4)
grna_target_data_frame <- sceptre_object@grna_target_data_frame
nt_grp_size <- 2L
nt_grna_df <- grna_target_data_frame |> dplyr::filter(grna_target == "non-targeting")
n_nt_grnas <- nrow(nt_grna_df)
nt_ids <- paste0("nt_", sample(rep(seq_len(ceiling(n_nt_grnas/nt_grp_size)), each = nt_grp_size)[seq_len(n_nt_grnas)]))
nt_grna_df <- nt_grna_df |> dplyr::mutate(grna_target = nt_ids, grna_group = nt_ids)
grna_target_data_frame[grna_target_data_frame$grna_target == "non-targeting",] <- nt_grna_df
sceptre_object@grna_target_data_frame <- grna_target_data_frame

# write sceptre_object
write_ondisc_backed_sceptre_object(sceptre_object = sceptre_object,
                                   directory_to_write = sceptre3_offsite)
