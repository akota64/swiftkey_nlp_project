here::i_am("model/final_model.R")
suppressPackageStartupMessages(require(here))
suppressPackageStartupMessages(require(tidyverse))
suppressPackageStartupMessages(require(tidytext))
suppressPackageStartupMessages(require(data.table))

co <- readRDS(here("model/data/co_matrix.Rds"))
ngrams4_stats <- readRDS(here("model/data/quadrigram_stats.Rds"))
ngrams3_stats <- readRDS(here("model/data/trigram_stats.Rds"))
ngrams2_stats <- readRDS(here("model/data/bigram_stats.Rds"))
ngrams1_stats <- readRDS(here("model/data/unigram_stats.Rds"))
tuned_beta <- as.numeric(readLines(here("model/data/beta.txt")))
tuned_lambda <- as.numeric(readLines(here("model/data/lambda.txt")))

get_co_scores <- function(string){
    words <- unnest_ngrams(data.frame(line=string), word, line, n=1)$word
    words <- words[!(words %in% stop_words$word)]
    
    if(length(words)==0){
        dt <- data.table(data.frame(word2 = "", co_score = NA))
    } else {
        dt <- co[word1==words[1]][,!"word1"]
        dt$freq <- log10(dt$freq/max(dt$freq, na.rm = TRUE))
        setnames(dt, "freq", "log_prob1")
        
        for(i in 2:length(words)){
            x <- co[word1==words[i]]
            x$freq <- log10(x$freq/max(x$freq, na.rm = TRUE))
            
            dt <- merge(dt, x, by="word2")[,!"word1"]
            setnames(dt, "freq", paste0("log_prob",i))
        }
        
        dt <- dt[, co_score:=rowSums(.SD)/(ncol(dt)-1), .SDcols=2:ncol(dt)][,c("word2","co_score")]
    }
    dt
    
}

predict_word <- function(string, lambda = tuned_lambda, beta = tuned_beta) {
    co_scores <- suppressWarnings(get_co_scores(string))
    eta_co_score <- suppressWarnings(min(co_scores$co_score, na.rm = TRUE)) - beta
    if(eta_co_score==Inf){eta_co_score <- -3}
    trigram_rows <- unnest_ngrams(data.frame(line=string), word, line, n=1) %>% 
        tail(3) %>% 
        arrange(desc(row_number()))
    trigram <- trigram_rows$word
    log_lambda <- log10(lambda)
    
    pred_rows4 <- ngrams4_stats[word1==trigram[3] & word2==trigram[2] & word3==trigram[1]]
    pred_rows4 <- merge(pred_rows4, co_scores, by.x = "word4", by.y = "word2", all.x = TRUE, all.y = FALSE)
    pred_rows4$co_score[is.na(pred_rows4$co_score)] <- eta_co_score
    pred_rows4$score <- pred_rows4$log_cond_prob + (beta*pred_rows4$co_score)
    pred_rows4 <- pred_rows4[order(-score)][1]
    preds <- data.frame(word=pred_rows4$word4, log_cond_prob = pred_rows4$log_cond_prob, score=pred_rows4$score)
    
    pred_rows3 <- ngrams3_stats[word1==trigram[2] & word2==trigram[1]]
    pred_rows3 <- merge(pred_rows3, co_scores, by.x = "word3", by.y = "word2", all.x = TRUE, all.y = FALSE)
    pred_rows3$co_score[is.na(pred_rows3$co_score)] <- eta_co_score
    pred_rows3$score <- pred_rows3$log_cond_prob + (beta*pred_rows3$co_score)
    pred_rows3 <- pred_rows3[order(-score)][1]
    preds <- rbind(preds, data.frame(word=pred_rows3$word3, log_cond_prob = pred_rows3$log_cond_prob,
                                     score=pred_rows3$score))
    
    pred_rows2 <- ngrams2_stats[word1==trigram[1]]
    pred_rows2 <- merge(pred_rows2, co_scores, by.x = "word2", by.y = "word2", all.x = TRUE, all.y = FALSE)
    pred_rows2$co_score[is.na(pred_rows2$co_score)] <- eta_co_score
    pred_rows2$score <- pred_rows2$log_cond_prob + (beta*pred_rows2$co_score)
    pred_rows2 <- pred_rows2[order(-score)][1]
    preds <- rbind(preds, data.frame(word=pred_rows2$word2, log_cond_prob = pred_rows2$log_cond_prob,
                                     score=pred_rows2$score))
    
    pred_rows1 <- ngrams1_stats
    pred_rows1 <- merge(pred_rows1, co_scores, by.x = "word1", by.y = "word2", all.x = TRUE, all.y = FALSE)
    pred_rows1$co_score[is.na(pred_rows1$co_score)] <- eta_co_score
    pred_rows1$score <- pred_rows1$log_cond_prob + (beta*pred_rows1$co_score)
    pred_rows1 <- pred_rows1[order(-score)][1]
    preds <- rbind(preds, data.frame(word=pred_rows1$word1, log_cond_prob = pred_rows1$log_cond_prob,
                                     score=pred_rows1$score))
    
    preds$score <- as.numeric(preds$score)
    if(sum(is.na(preds$score))==nrow(preds)) {
        pred_word <- preds[which(preds$log_cond_prob == max(preds$log_cond_prob, na.rm = TRUE)),]$word
    } else {
        pred_word <- preds[which(preds$score == max(preds$score, na.rm = TRUE)),]$word
    }
    pred_word[1]
}