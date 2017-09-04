observe( {
  validate(
    need(between(input$num_test_percent, 0, 1), "msg"), errorClass = "errors"
  )
  updateNumericInput(session, "num_train_percent", value = (1 - input$num_test_percent) %>% round(2))
})

observe( {
  validate(
    need(between(input$num_train_percent, 0, 1), "msg")
  )
  updateNumericInput(session, "num_test_percent", value = (1 - input$num_train_percent) %>% round(2))
})