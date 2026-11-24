# Etymology Shiny test — deploy-ready single-file Shiny app
# Converted from "Etymology Shiny test.Rmd"

library(shiny)
library(DT)
library(dplyr)
library(readr)

# --- Data ------------------------------------------------------------------
# The CSV must sit in this same folder (next to app.R) so it ships with the app.
# Locally you can download it with:
#   ET_db <- read.csv("<your local path>/Etymology_Database_Phylum_small.csv",
#                     stringsAsFactors = FALSE)
# then save it here as part of the project.
ET_db <- read.csv("Etymology_Database_Phylum_small.csv", stringsAsFactors = FALSE)

# --- UI --------------------------------------------------------------------
ui <- fluidPage(
  theme = shinythemes::shinytheme("flatly"),
  titlePanel("Etymology Database"),

  sidebarLayout(
    sidebarPanel(
      textInput("search", "Search", placeholder = "e.g. phylum, root, meaning"),
      selectInput("column", "Restrict search to",
                  choices = c("All columns", names(ET_db)),
                  selected = "All columns"),
      helpText("The table is also sortable and pageable.")
    ),

    mainPanel(
      DTOutput("table")
    )
  )
)

# --- Server ----------------------------------------------------------------
server <- function(input, output, session) {

  filtered <- reactive({
    req(input$search)

    if (trimws(input$search) == "" || input$column == "All columns") {
      # DT's own global search handles the "all columns" case
      return(ET_db)
    }

    ET_db %>%
      filter(grepl(input$search, .data[[input$column]],
                   ignore.case = TRUE, fixed = FALSE))
  })

  output$table <- renderDT({
    datatable(
      filtered(),
      filter = "top",
      options = list(
        pageLength = 25,
        search = list(regex = TRUE, caseInsensitive = TRUE)
      ),
      rownames = FALSE
    )
  })
}

shinyApp(ui = ui, server = server)
