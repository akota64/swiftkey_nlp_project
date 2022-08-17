suppressMessages(here::i_am("scripts/get_all_en_US_lines.R"))
suppressPackageStartupMessages(require(here))

#' get_all_en_US_data: Returns all en_US data in a single data frame, with type_id indicating the initial file of the data
#' This data frame is cached after the first use for easy access.
get_all_en_US_lines <- function(){
    
    if(!file.exists(here("data/en_US/all_en_US_lines.Rds"))){
        suppressPackageStartupMessages(require(dplyr))
        
        news <- readLines(here("final/en_US/en_US.news.txt"))
        twitter <- suppressWarnings(readLines(here("final/en_US/en_US.twitter.txt")))
        blogs <- readLines(here("final/en_US/en_US.blogs.txt"))
        
        news_df <- data.frame(type_id="news", line = news) %>% mutate(line_id = row_number())
        twitter_df <- data.frame(type_id="twitter", line = twitter) %>% mutate(line_id = row_number())
        blogs_df <- data.frame(type_id="blogs", line = blogs) %>% mutate(line_id = row_number())
        df <- rbind(news_df, twitter_df, blogs_df)
        saveRDS(df, here("data/en_US/all_en_US_lines.Rds"))
    } else{
        df <- readRDS(here("data/en_US/all_en_US_lines.Rds"))
    }
    
    df
}