suppressMessages(here::i_am("scripts/get_sample_en_US_lines.R"))
suppressPackageStartupMessages(require(here))

#' get_sample_en_US_data: Returns sampled en_US data in a single data frame, with type_id indicating the initial file of the data
#' If not available, samples the data and then returns it. We use a sample of 10% of the total lines for this project.
get_sample_en_US_lines <- function() {
    set.seed(as.numeric(readLines(here("scripts/seed.txt"))))
    
    if(!file.exists(here("data/en_US/all_en_US_lines.Rds"))) {
        stop("Please run get_all_en_US_lines first to extract those data.")
    } else if(!file.exists(here("data/en_US/sample_en_US_lines.Rds"))) {
        
        df <- readRDS(here("data/en_US/all_en_US_lines.Rds"))
        
        samp_ind <- sample(1:nrow(df), nrow(df)*0.1)
        samp <- df[samp_ind,]
        
        saveRDS(samp, here("data/en_US/sample_en_US_lines.Rds"))
        
    } else {
        samp <- readRDS(here("data/en_US/sample_en_US_lines.Rds"))
    }
    
    samp
}