library(shiny)
source("final_model.R")

shinyServer(function(input, output) {
    output$word <- renderText({
        if(input$string==""){
            paste("<center><b>", "Please enter a phrase to complete. Then click 'Submit'.", "</b></center>")
        } else{
            paste("<center><b>", predict_word(input$string), "</b></center>")
        }

    })
})
