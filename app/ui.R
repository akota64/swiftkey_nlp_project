library(shiny)
library(tidyverse)
library(shinycssloaders)

shinyUI(fluidPage(

    titlePanel("Autocomplete Application"),
    
    em("Enter text in the sidebar and click 'Submit' to predict the next word. Click the documentation tab for more information."),
    hr(),
    tabsetPanel(
        tabPanel(
            "Prediction",
            hr(style = "border-top: 1px solid #ffffff;"),
            sidebarLayout(
                sidebarPanel(
                    textAreaInput("string", "Enter Text To Complete Here"),
                    submitButton("Submit")
                ),
                mainPanel(
                    uiOutput("word",) %>% withSpinner()
                )
            )
        ),
        tabPanel(
            "Documentation",
            hr(style = "border-top: 1px solid #ffffff;"),
            p("This autocomplete application predicts the next word in phrases/sentences provided as input in the sidebar. The methods used for prediction are explained in the sections below."),
            h3("Methods"),
            p("This predictor is based on a 4-gram language model, trained on a sample of news, blog, and Twitter data. This means that the model primarily uses the last 3 words of a given sentence/phrase to predict the next one. The model additionally deals with OOV words and short phrases using a modified version of 'stupid backoff' in which the backoff occurs not only in cases when 4-grams are OOV, but in all cases. This means that optimal words are calculated using 1-grams, 2-grams, 3-grams, and 4-grams, and the best word out of the 4. Of course, there is some discounting of probability at each backoff to reduce the contributions of lower-order n-grams."),
            p("A term co-ocurrence matrix method was also initially incorporated into the model. However, due to the shinyapps.io memory limit, it is not possible to incorporate this method into the application at this time. Please visit the link below for the full model."),
            p("For more information about the model and how it was implemented, please visit ", a(href="https://github.com/akota64/swiftkey_nlp_project/blob/main/model/en_US.modeling.Rmd","this project's Github repository"), "."),
            h3("Resources Used"),
            p("[1] Daniel Jurafsky and James H. Martin. 2000. Speech and Language Processing: An Introduction to Natural Language Processing, Computational Linguistics, and Speech Recognition (1st. ed.). Prentice Hall PTR, USA."),
            p("[2] Brants, T., A. C. Popat, P. Xu, F. J. Och, and J. Dean. 2007. Large language models in machine translation. EMNLP/CoNLL")
        )
    )
))
