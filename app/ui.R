here::i_am("app/ui.R")
suppressPackageStartupMessages(require(here))
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
            h2("Methods"),
            h2("References")
        )
    )
))
