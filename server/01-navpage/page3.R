observeEvent(input$btn_go, {
  withBusyIndicatorServer("btn_go", {
    
    if (input$rb_model == "xgboost") {
            xgb_train <- xgb.DMatrix(rv$train %>% select(-class) %>% as.matrix(), label = rv$train$class)
            xgb_test <- xgb.DMatrix(rv$test %>% select(-class) %>% as.matrix(), label = rv$test$class)
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
            
            test_model = predict(model,
                                 newdata = as.matrix(rv$test %>% select(-class)),
                                 ntreelimit = model$bestInd)
            test_roc = roc(rv$test$class, test_model)
            
            model_keydata <- cbind(model$niter, model$best_iteration, model$best_ntreelimit, model$best_score)
            colnames(model_keydata) <- c("niter", "best iteration", "best ntree limit", "best score")
            
            output$ui_main <- renderUI( {
              tagList(
                fluidRow(
                  column(4,
                         verticalLayout(
                           h3("Log"),
                           DT::renderDataTable(model_log, rownames = F, options = list(searching = F, lengthChange = F))
                         )
                  ),
                  column(8,
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
                ),
                fluidRow(
                  column(4,
                         h3("Importance of variables"),
                         DT::renderDataTable(model_importance)    
                  )
                ) 
              )
            })
    } else if (input$rb_model == "Decision tree") {
      rf_model <- rpart(class ~ ., data = rv$train, method = "class", minbucket = input$minbucket)
      
      prediction <- predict(rf_model, rv$test, type = "class")
      conf_mat <- confusionMatrix(rv$test$class, prediction)
      
      output$ui_main <- renderUI( {
        tagList(
          fluidRow(
            column(6,
                   h3("Confusion Matrix"),
                   renderPrint(conf_mat)),
            column(6,
                   h3("Tree plot"),
                   renderPlot(prp(rf_model)))
          )
        )
      })
    }
  })
})