observe( {
  if (input$rb_dataset == "Upload a file" & is.null(input$file_upload)) {
    shinyjs::disable(id = "nextBtn")
  } else {
    shinyjs::enable(id = "nextBtn")
  }
})