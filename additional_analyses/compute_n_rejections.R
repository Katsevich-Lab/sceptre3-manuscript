library(arrow)
library(dplyr)
conflicts_prefer(dplyr::filter)

gasp_offsite <- paste0(.get_config_path("LOCAL_GASPERINI_2019_V3_DATA_DIR"), "at-scale/processed/")
sceptre3_offsite <- .get_config_path("LOCAL_SCEPTRE3_DATA_DIR")

gasp_trans_dir <- paste0(sceptre3_offsite, "nf_pipelines/gasp_trans/sceptre_outputs/trans_results")
fs <- list.files(gasp_trans_dir, full.names = TRUE)
ds <- open_dataset(fs)
unique_grna_targets <- ds$grna_target |> unique()
grna_targets <- read_parquet(fs[1])$grna_target |> unique() |> as.character()

n_rejections_per_grna_target <- ds |>
  collect() |>
  group_by(grna_target) |>
  summarize(n_reject = sum(p.adjust(p_value, method = "BH") < 0.05, na.rm = TRUE)) |>
  ungroup() |>
  mutate(nt_grna = grepl("^nt_", grna_target))
n_rejections_per_grna_target |>
  filter(nt_grna) |>
  summarize(m = mean(n_reject)) # an average, only 0.5 false discoveries per nt grna
saveRDS(n_rejections_per_grna_target,
        file = paste0(sceptre3_offsite, "nf_pipelines/gasp_trans/sceptre_outputs/n_rejections_per_grna_target.rds"))
