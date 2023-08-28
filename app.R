library(shiny)
library(rjson)
library(stringr)

ui <- fluidPage(

    sidebarLayout(
        sidebarPanel(
            uiOutput('dateUI'),
            fluidRow(
              column(4, actionButton('edit', 'Edit')),
              column(4, fileInput('load', 'Load')),
              column(4, downloadButton('save', 'Save'))
            )
        ),

        mainPanel(
          textOutput('test', inline = TRUE)
        )
    )
)

server <- function(input, output, session) {

  rv <- reactiveValues(
    journal = fromJSON(file = 'journal.json') 
  )
  
  lastEntryOnLoad <- names(tail(fromJSON(file = 'journal.json'), 1))
  
  output$dateUI <- renderUI(
    dateInput(
      "date",
      "Choose date",
      weekstart = 1,
      value = lastEntryOnLoad
    )
  )
  
  observeEvent(input$date, {
    
    rv$test <- str_detect(names(rv$journal), as.character(input$date))
    rv$isEmpty <- identical(paste(rv$journal[rv$test]), character(0))
    
    rv$currentEntry <- ifelse(rv$isEmpty, '', paste(rv$journal[rv$test]))
  })
  
  editModal <- function() {
    modalDialog(
      textAreaInput(
        'editArea',
        'Edit your entry',
        value = paste(rv$journal[rv$test])
      ),
      footer = tagList(
        actionButton('submit','Submit'),
        modalButton("Dismiss")
      )
    )
  }
  
  observeEvent(input$edit, {
    showModal(editModal())
  })
  
  observeEvent(input$submit, {
    data <- paste0('list(`', input$date, '` = input$editArea)')
    print(eval(parse(text = data)))
    
    if(rv$isEmpty) {
      rv$journal <- append(rv$journal, eval(parse(text = data)))
      rv$isEmpty <- FALSE
    } else {
      rv$journal[rv$test] <- input$editArea
    }
    
    rv$test <- str_detect(names(rv$journal), as.character(input$date))
    rv$currentEntry <- rv$journal[rv$test]
    
    rv$journal <- rv$journal[order(names(rv$journal))]  
    jsondata <- toJSON(rv$journal)
    write(jsondata, 'journal.json')
    
    removeModal()
    
  })
  
  output$test <- renderText(
    paste(rv$currentEntry)
  )
  
  observeEvent(input$load, {
    print(input$load)
    rv$journal <- fromJSON(file = input$load$datapath)
    updateDateInput(
      session,
      "date",
      "Choose date",
      value = names(tail(fromJSON(file = input$load$datapath), 1))
    )
  })
}

shinyApp(ui = ui, server = server)
