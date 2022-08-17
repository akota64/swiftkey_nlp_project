suppressMessages(here::i_am("scripts/split_data.R"))
suppressPackageStartupMessages(require(here))

#' split_data: Splits all available data into train, held-out, CV, and test sets
#' These sets are saved in the data directory under the project home directory
#' It is important to use this script because the seed is internally set to maintain set consistency
#' Inputs:
#'  - data: A data frame
split_data <- function(data) {
    set.seed(as.numeric(readLines(here("scripts/seed.txt"))))
    
    ind <- 1:nrow(data)
    train_ind <- sample(ind, nrow(data)*0.8)
    ind <- ind[!(ind %in% train_ind)]
    cv_ind <- sample(ind, length(ind)*0.5)
    test_ind <- ind[!(ind %in% cv_ind)]
    
    held_out_ind <- sample(train_ind, length(train_ind)*0.1)
    train_ind <- train_ind[!(train_ind %in% held_out_ind)]
    
    train <- data[train_ind,]
    held_out <- data[held_out_ind,]
    cv <- data[cv_ind,]
    test <- data[test_ind,]
    
    saveRDS(train, here("data/en_US/train_en_US_lines.Rds"))
    saveRDS(held_out, here("data/en_US/held_out_en_US_lines.Rds"))
    saveRDS(cv, here("data/en_US/cv_en_US_lines.Rds"))
    saveRDS(test, here("data/en_US/test_en_US_lines.Rds"))
}