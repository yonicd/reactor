library(whereami)

# Define the UI
ui <- shiny::bootstrapPage(
  shiny::uiOutput('ui_colour'),
  shiny::uiOutput('ui_mytext'),
  shiny::uiOutput('ui_n'),
  shiny::plotOutput('plot')
)

# Define the server code
server <- function(input, output) {

  output$ui_colour <- shiny::renderUI({
    shiny::radioButtons('colour', 'Total Obs', 
                        choices = c('red','blue','yellow'),
                        selected = 'red',
                        inline = TRUE)
  })

  output$ui_mytext <- shiny::renderUI({
    shiny::HTML(sprintf('<font color="%s">This is some text!</font>',input$colour))
  })
    
  output$ui_n <- shiny::renderUI({
    shiny::numericInput('n', 'Number of obs', 200)
  })
  
  shiny::observe({ # <----- run every time any element in input is invalidated
    output$plot <- shiny::renderPlot({
      cat_where(whereami::whereami(tag = 'hist'))
      graphics::hist(stats::runif(input$n)) 
    })
  })
}

# Return a Shiny app object
shinyApp(ui = ui, server = server)
