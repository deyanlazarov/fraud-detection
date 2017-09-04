lapply(seq(NUM_PAGES), function(i) {
  source(file.path("server", "01-navpage", sprintf("page%i.R", i)),  local = TRUE)$value
})

observe( {
  toggleState(id = "prevBtn", condition = rv$page > 1)
  hide(selector = ".page")
  show(sprintf("step%s", rv$page))
})

navPage <- function(direction) {
  rv$page <- rv$page + direction
}

observeEvent(input$prevBtn, {
  if (rv$page == 2) {
    shinyjs::show(id = "prevBtn")
    shinyjs::show(id = "nextBtn")
    navPage(-1)
  } else if (rv$page == 3) {
    shinyjs::html(id = "nextBtn", html = "Next >")
    shinyjs::runjs("nav_page.appendChild(prevBtn);")
    shinyjs::runjs("nav_page.appendChild(nextBtn);")
    
    navPage(-1)
  }
})

observeEvent(input$nextBtn, {
  if (rv$page == 1) {
    # Upload file
    if (input$rb_dataset == "Upload a file") {
      # validate(
      #   need(!is.null(input$file_upload), "No file has been specified!")
      # )
      rv$data <- readr::read_csv(file = input$file_upload$datapath)
      navPage(1)
    } else if (input$rb_dataset == "Kaggle dataset") {
     rv$data <- kaggle_data
     
     navPage(1)
    }
  } else if (rv$page == 2) {
    # Validation
    method <- input$slt_method
    
    if (method == "Sample N" & input$sld_sample %in% c(0, rows)) {
      shinyjs::alert(sprintf("Train set should not be 0 or %i", rows))
      updateSliderInput(session, "sld_sample", value = round(rows / 2, 0))
    } else {
      ui_element <- ifelse(method == "Sample N", "sld_sample", "num_train_percent")
      ui_value <- input[[ui_element]]
      #times <- ifelse(!input$cb_cross, 1, input$num_kfolds)
      
      sets <- create_samples(rv$data, method, ui_value, times = 1)
      if (length(sets) == 1) sets <- sets %>% unlist(recursive = F)
      
      rv$train <- sets[[1]]
      rv$test <- sets[[2]]
      
      shinyjs::runjs("page3_sidebar.appendChild(prevBtn);")
      shinyjs::runjs("page3_sidebar.appendChild(nextBtn);")
      shinyjs::html(id = "nextBtn", html = "Finish")
      
      navPage(1)
    }
  }
  else if (rv$page == 3) {
    # Finish
    shinyjs::hide(id = "welcome-text")
    shinyjs::html(id = "nextBtn", html = "Next >")
    shinyjs::runjs("nav_page.appendChild(prevBtn);")
    shinyjs::runjs("nav_page.appendChild(nextBtn);")
    navPage(-2)
  }
})