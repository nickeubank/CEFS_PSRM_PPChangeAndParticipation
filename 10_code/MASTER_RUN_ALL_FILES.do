****************
* To use, first modify `set_globals.do` so the
* global `nc_electioneering` points to this repository.
* Then run this file!
*
* Note there are a few helper programs used, including:
* - zipuse
*
* All of which can be installed within Stata using `search` and/or `ssc install`
****************
capture log close
log using $nc_electioneering/REPLICATION_LOG.txt, replace

do $nc_electioneering/10_code/40_make_analysis_datasets/00_reshape_long.do
do $nc_electioneering/10_code/40_make_analysis_datasets/05_subset_to_analysis_sample.do
do $nc_electioneering/10_code/40_make_analysis_datasets/06_add_census_data.do
do $nc_electioneering/10_code/40_make_analysis_datasets/07_create_statadata_of_early_voting_number_and_hours.do
do $nc_electioneering/10_code/40_make_analysis_datasets/08_add_analysis_vars.do
do $nc_electioneering/10_code/40_make_analysis_datasets/10_merge_vra_coverage.do
do $nc_electioneering/10_code/40_make_analysis_datasets/15_new_vars_for_analysis.do



do $nc_electioneering/10_code/50_effect_of_pp_change/05_summary_stats_pp_change.do
do $nc_electioneering/10_code/50_effect_of_pp_change/20_pp_change_and_turnout.do
do $nc_electioneering/10_code/50_effect_of_pp_change/40_paper_analysis_prep.do
do $nc_electioneering/10_code/50_effect_of_pp_change/45_paper_tables.do
do $nc_electioneering/10_code/50_effect_of_pp_change/47_paper_figures.do
do $nc_electioneering/10_code/50_effect_of_pp_change/48_plot_distribution_of_county_estimates.do

log close
