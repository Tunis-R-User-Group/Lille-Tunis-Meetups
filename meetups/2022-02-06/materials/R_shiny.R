library(shiny)
library(ggplot2)
library(shinyWidgets)


ui <- fluidPage(
  
  h1("Mon titre principal"),
  
  selectInput(
    inputId = "colors", 
    label = "Please, select a color", 
    choices = colours(), 
    selected = "blue"
  ), 
  
  plotOutput(outputId = "plt1"), 
  
  h1(textOutput(outputId = "titre_interactif")), 
  
  numericInput(
    inputId = "row_number", 
    label = "Please, select the number of row to display", 
    value = 10, 
    min = 1, 
    max = nrow(mpg)
  ), 
  
  tableOutput(outputId = "tbl1"), 
  
  br(),
  br(), 
  br(), 
  br(), 
  br(),
  br(), 
  br(), 
  br(), 
  br()
  
  
)


server <- function(input, output, session) {
  
  
  output$plt1 <- renderPlot({
    
    ggplot(data = mpg, aes(hwy, cty)) +
      geom_point(col = input$colors)
    
  })
  
  
  output$titre_interactif <- renderText({
    
    if (is.na(input$row_number)) {
      "Please select a correct number of rows"
      
    } else {
      
      paste0("First ", input$row_number, " rows of mpg")
      
    }
    
    
    
  })
  
  
  output$tbl1 <- renderTable({
    
    if (is.na(input$row_number)) {
      
      return(NULL)
    }
    
    if (input$row_number < 1) {
      
      sendSweetAlert(
        session = session, 
        title = "Format Incorrect", 
        text = "Selectionnez au moins une ligne", 
        type = "warning"
      )
    }
    
    
    
    head(mpg, n = input$row_number)
    
  })
  
  
  
}


shinyApp(ui = ui, server = server)