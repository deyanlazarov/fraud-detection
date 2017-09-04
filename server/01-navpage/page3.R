observeEvent(input$btn_go, {
  withBusyIndicatorServer("btn_go", {
    xgb_train <- xgb.DMatrix(rv$train %>% select(-class) %>% as.matrix(), label = rv$train$class)
    xgb_test <- xgb.DMatrix(rv$test %>% select(-class) %>% as.matrix(), label = rv$test$class)
    
    if (input$rb_model == "xgboost") {
            model <- xgb.train(data = xgb_train,
                               params = list(
                                 objective = "binary:logistic",
                                 eta = input$sld_eta,
                                 max.depth = input$sld_max_depth,
                                 min_child_weight = input$sld_min_child_weight,
                                 subsample = input$sld_subsample,
                                 colsample_bytree = input$sld_colsample,
                                 #nthread = 3,
                                 eval_metric = "auc"
                               ),
                               watchlist = list(test = xgb_test),
                               nrounds = input$sld_nrounds,
                               early_stopping_rounds = 40,
                               print_every_n = 20
            )
            
            model_log <- model$evaluation_log
            colnames(model_log) <- c("Iteration", "Accuracy")
            
            model_importance <- datatable(
              xgb.importance(feature_names = colnames(xgb_train), model = model), options = list(dom = "t"), rownames = F) %>% 
              DT::formatRound('Gain', 2) %>% 
              DT::formatRound('Cover', 2) %>% 
              DT::formatRound('Frequency', 2)
            
            
            output$ui_log <- renderUI( {
              tagList(
                verticalLayout(
                  h3("Log"),
                  DT::renderDataTable(model_log, rownames = F, options = list(searching = F, lengthChange = F))
                )
              )
            })    
            
            output$ui_importance <- renderUI( {
              tagList(
                h3("Importance of variables"),
                DT::renderDataTable(model_importance)
              )
            })
            
            test_model = predict(model,
                                 newdata = as.matrix(rv$test %>% select(-class)),
                                 ntreelimit = model$bestInd)
            test_roc = roc(rv$test$class, test_model)
            
            model_keydata <- cbind(model$niter, model$best_iteration, model$best_ntreelimit, model$best_score)
            colnames(model_keydata) <- c("niter", "best iteration", "best ntree limit", "best score")
            
            output$ui_roc <- renderUI( {
              tagList(
                h3("Roc curve"),
                verticalLayout(
                  renderPlot(plot(test_roc)),
                  h3("Key values"),
                  DT::renderDataTable(
                    DT::datatable(
                      model_keydata,
                      rownames = F, options = list(dom = "t"))
                  )
                ) 
              )
            })
    } else if (input$rb_model == "Random forest") {
      
    }
  })
})