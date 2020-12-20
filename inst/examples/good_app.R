library(whereami)

# Define the UI
ui <- shiny::bootstrapPage(
  shiny::uiOutput('ui_n'),
  shiny::plotOutput('plot')
)

# Define the server code
server <- function(input, output) {
  
  output$ui_n <- shiny::renderUI({
      shiny::numericInput('n', 'Number of obs', 200)
  })

  # Run only when input$n exists and is changed
  output$plot <- shiny::renderPlot({
    shiny::req(input$n) 
      whereami::whereami(tag = 'hist')
      graphics::hist(stats::runif(input$n))
  })
}

# Return a Shiny app object
shinyApp(ui = ui, server = server,options = list(port=6012))
