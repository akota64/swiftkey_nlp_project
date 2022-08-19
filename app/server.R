here::i_am("app/server.R")
suppressPackageStartupMessages(require(here))
library(shiny)
source(here("model/final_model.R"))

shinyServer(function(input, output) {
    output$word <- renderText({
        if(input$string==""){
            paste("<center><b>", "Please enter a phrase to predict. Then click 'Submit'.", "</b></center>")
        } else{
            paste("<center><b>", predict_word(input$string), "</b></center>")
        }

    })
})
