observe( {
  if (input$rb_dataset == "Upload a file" & is.null(input$file_upload)) {
    shinyjs::disable(id = "nextBtn")
  } else {
    shinyjs::enable(id = "nextBtn")
  }
})

observeEvent(input$file_upload, {
  if ((stri_split(input$file_upload$name, regex = "\\.") %>% unlist() %>% tail(1)) != "csv")
    output$file_error <- renderText("File type is not csv")
  else {
    output$file_error <- renderText("")
  }
})