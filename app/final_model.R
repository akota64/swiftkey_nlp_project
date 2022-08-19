suppressPackageStartupMessages(require(tidyverse))
suppressPackageStartupMessages(require(tidytext))
suppressPackageStartupMessages(require(data.table))

ngrams4_stats <- readRDS("data/quadrigram_stats.Rds")
ngrams3_stats <- readRDS("data/trigram_stats.Rds")
ngrams2_stats <- readRDS("data/bigram_stats.Rds")
ngrams1_stats <- readRDS("data/unigram_stats.Rds")
tuned_lambda <- as.numeric(readLines("data/lambda.txt"))

predict_word <- function(string, lambda = tuned_lambda) {
    df <- data.frame(line = string)
    trigram_rows <- unnest_ngrams(df, word, line, n=1) %>% 
        tail(3) %>% 
        arrange(desc(row_number()))
    trigram <- trigram_rows$word
    log_lambda <- log10(lambda)
    
    pred_rows4 <- ngrams4_stats[word1==trigram[3] & word2==trigram[2] & word3==trigram[1]]
    pred_rows4 <- pred_rows4[order(-log_cond_prob)][1]
    preds <- data.frame(word=pred_rows4$word4, prob=pred_rows4$log_cond_prob)
    
    pred_rows3 <- ngrams3_stats[word1==trigram[2] & word2==trigram[1]]
    pred_rows3 <- pred_rows3[order(-log_cond_prob)][1]
    preds <- rbind(preds, c(pred_rows3$word3, pred_rows3$log_cond_prob + log_lambda))
    
    pred_rows2 <- ngrams2_stats[word1==trigram[1]]
    pred_rows2 <- pred_rows2[order(-log_cond_prob)][1]
    preds <- rbind(preds, c(pred_rows2$word2, pred_rows2$log_cond_prob + (2*log_lambda)))
    
    pred_rows1 <- ngrams1_stats[order(-log_cond_prob)][1]
    preds <- rbind(preds, c(pred_rows1$word1, pred_rows1$log_cond_prob + (3*log_lambda)))
    
    pred_word <- preds[which(as.numeric(preds$prob) == max(as.numeric(preds$prob), na.rm = TRUE)),]$word[1]
    pred_word
}