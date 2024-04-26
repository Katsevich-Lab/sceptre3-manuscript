library(katlabutils)
library(arrow)
library(dplyr)
library(ggplot2)
conflicts_prefer(dplyr::filter)

gasp_offsite <- paste0(.get_config_path("LOCAL_GASPERINI_2019_V3_DATA_DIR"), "at-scale/processed/")
sceptre3_offsite <- .get_config_path("LOCAL_SCEPTRE3_DATA_DIR")
n_rejections_per_grna <- readRDS(paste0(sceptre3_offsite,
                                        "nf_pipelines/gasp_trans/sceptre_outputs/n_rejections_per_grna_target.rds")) |>
  arrange(desc(n_reject))

gasp_trans_dir <- paste0(sceptre3_offsite, "nf_pipelines/gasp_trans/sceptre_outputs/trans_results")
ds <- open_dataset(gasp_trans_dir)

# create the data frame to plot
get_p_values_for_grna_target <- function(ds, curr_grna_target) {
  ds |>
    filter(grna_target == curr_grna_target) |> 
    select(p_value) |>
    arrange(p_value) |>
    collect() |>
    na.omit()
}
set.seed(10)
my_grna_targets <- c("chr11:5291385-5291386", "chr3:141567550-141567694", "chr13:60105673-60106045", "nt_4")
p_vals <- sapply(my_grna_targets, function(my_grna_target) {
  get_p_values_for_grna_target(ds, my_grna_target)
})
n_pairs_per_grna_target <- sapply(p_vals, length)
grna_targets <- rep(x = my_grna_targets, times = n_pairs_per_grna_target)
to_plot <- data.frame(p_val = unlist(p_vals), grna_target = grna_targets)
rownames(to_plot) <- NULL
to_plot$grna_target <- factor(x = to_plot$grna_target,
                              levels = my_grna_targets,
                              labels = c("chr13:60105673", "chr3:141567550", "chr11:5291385", "non-targeting"))

to_plot_sub <- to_plot |>
  group_by(grna_target) |>
  sample_n(min(n_pairs_per_grna_target))

# create a john plot of the data frame
point_size <- 0.8
transparency <- 0.9
load_all("~/research_code/sceptre")
p_out <- ggplot2::ggplot(data = to_plot_sub, mapping = ggplot2::aes(y = p_val, col = grna_target)) +
  stat_qq_points(ymin = 1e-12, size = point_size, alpha = transparency) +
  stat_qq_band() +
  ggplot2::labs(x = "Expected null p-value", y = "Observed p-value") +
  ggplot2::geom_abline(col = "black") +
  get_my_theme() +
  ggplot2::theme(
    legend.title = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    axis.title.x = ggplot2::element_blank()
  ) +
  ggplot2::scale_x_continuous(trans = revlog_trans(10)) +
  ggplot2::scale_y_continuous(trans = revlog_trans(10)) + 
  ggplot2::scale_color_manual(values = c("firebrick1", "blueviolet", "dodgerblue2", "black")) +
  theme(legend.title = element_blank(),
        legend.position = c(0.3, 0.8),
        legend.text = element_text(size = 8.0),
        legend.margin = margin(t = 0, unit='cm'),
        legend.background = element_blank()) +
  guides(color = guide_legend(
    keywidth = 0.0,
    keyheight = 0.1,
    default.unit ="inch",
    override.aes = list(size = 2.5)))
ggsave(filename = "~/research_code/sceptre3-project-v2/figs/trans_results.png",
       plot = p_out, device = "png", scale = 0.6, width = 4, height = 4.2, dpi = 330)
