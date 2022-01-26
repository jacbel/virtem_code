# MASTER SCRIPT FOR VIRTEM
# This master script will create a custom library folder in which it will attempt to install the necessary packages from CRAN and GitHub.
# It will then start the analyses via the bookdown::render_book command, which will execute the different RMarkdown scripts contained in the code folder.
# Once the code has finished, you can view extensive HTML documentation, start at /virtem_code/docs/overview.html
# Final figures will be saved in /figures. These correspond to the main and supplemental data figures of the manuscript.
#
# Copyright (c) 2021 Jacob L. S. Bellmund

# take the start time
start_time <- Sys.time()

#-------- INSTALL AND/OR LOAD PACKAGES ---------
# set directory for library
lib_dir <- file.path(getwd(), "virtem_code", paste0("R", version$major,".",version$minor), "library", Sys.info()['sysname'])
if(!dir.exists(lib_dir)){dir.create(lib_dir, recursive = TRUE)}
.libPaths(c(lib_dir,.libPaths()))

# install and load required packages from CRAN
list.of.packages <- c("R.matlab", "tidyverse", "devtools", "combinat", "tinytex", "mgsub", "assertr",
                      "bookdown", "wesanderson", "here", "broom", "pdftools", "statip", "ggforce",
                      "cowplot", "readr", "ggplot2", "dplyr", "lavaan", "smooth", "Hmisc",
                      "oro.nifti", "fslr", "freesurfer", "tictoc", "corrplot", "DescTools", "lme4", "officer",
                      "texreg", "car", "lmerTest", "broom.mixed", "ggeffects", "emmeans", "matrixStats", "flextable",
                      "tidystats", "huxtable", "gghalves", "sjmisc", "afex", "permuco", "smacof", "umap", "ggcorrplot", "scico", "patchwork", "effsize") 
if (Sys.info()['sysname']=="Linux"){list.of.packages <- list.of.packages[-which(list.of.packages=="pdftools")]}
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages(lib.loc = lib_dir)[,"Package"])]
if(length(new.packages)) install.packages(new.packages, lib = lib_dir)
lapply(list.of.packages, library, character.only = TRUE)

# install and load required packages from GitHub
list.of.packages <- c("grateful", "ggBrain", "extrafont")
list.of.usrnames <- c("Pakillo", "aaronjfisher", "wch")
new.packages <- list.of.packages[!(list.of.packages %in%
                                     installed.packages()[,"Package"])]
if(length(new.packages)){
  remotes::install_github(repo = sprintf("%s/%s", 
                                         list.of.usrnames,
                                         list.of.packages), 
                          lib = lib_dir)}
lapply(list.of.packages, library, character.only = TRUE)

# set FSL directory (CBS specific)
options(fsl.path='/usr/share/fsl/5.0')

#-------- DEFINE WHICH ANALYSES TO RUN ---------

# flag to change in case we don't want to run the MRI parts
run_parallel = TRUE
run_prep_beh = FALSE
run_prep_rois = FALSE
run_clean_func_data = FALSE
extract_func_data = FALSE
calc_corr_mat = FALSE
run_prep_snr = FALSE
run_prep_srchlght = FALSE
run_srchlght_lvl1 = FALSE
run_srchlght_lvl2 = FALSE
run_prep_srchlgh_peak_RSA = FALSE
run_rel_time_univariate = FALSE
run_srchlgh_peak_RSA2 = FALSE

#-------- SET UP FONTS ---------

# see what fonts are available
avail_fonts <- extrafont::fonts() 

# if no fonts are available, (re-)install extrafont database and try to import Roboto
if (!is.character(avail_fonts)){
  remotes::install_github(repo = "wch/extrafontdb", lib = lib_dir)
  extrafont::font_import(pattern = "Roboto-Regular", prompt=FALSE) # run this if Roboto not imported yet
  avail_fonts <- extrafont::fonts() # check again for fonts
}

# use Roboto if possible, else just "sans", which should be available on all OS
if (any(avail_fonts == "Roboto")){ 
  font2use <- "Roboto" 
} else{
  font2use <- "sans"
}

#-------- RUN ANALYSES WHILE RENDERING THE BOOK ---------
if(!dir.exists(here("virtem_code", "docs"))){dir.create(here("virtem_code", "docs"), recursive = TRUE)}
setwd(here("virtem_code")) # can render_book be run from outside the code folder?
bookdown::render_book("virtem_index.Rmd", output_format = "gitbook", 
                      output_dir = here("virtem_code", "docs"), 
                      config_file = "_bookdown_full.yml")

# create no jekyll file for hosting with github pages
fn <- here("virtem_code", "docs", ".nojekyll")
if(!file.exists(fn)){file.create(fn)}

# move back to parent directory
setwd(here())

# print elapsed time
end_time <- Sys.time()
end_time-start_time