div(
  sidebarPanel(id = "page3_sidebar",
    h3("Choose a predictor algorithm"),
    radioButtons("rb_model", label = "", choices = c("xgboost", "Random forest")),
    conditionalPanel(condition = "input.rb_model == 'xgboost'",
                     withBusyIndicatorUI(
                       actionButton("btn_go", "Build model", class = "btn-primary")
                     ),
                     h4("xgboost parameters"),
                     wellPanel(
                       fluidRow(
                         h4("Tree booster parameters"),
                         column(6, 
                                sliderInput("sld_eta", "eta", min = 0, max = 1, value = 0.3, step = 0.01),
                                sliderInput("sld_gamma", "gamma", min = 0, max = 100, value = 5, step = 1),
                                sliderInput("sld_max_depth", "max depth", min = 0, max = 50, value = 6, step = 1),
                                sliderInput("sld_nrounds", "n rounds", min = 20, max = 500, value = 100, step = 1)
                         ),
                         column(6, 
                                sliderInput("sld_min_child_weight", "min child weight", min = 0, max = 400, value = 100),
                                sliderInput("sld_subsample", "subsample", min = 0, max = 1, value = 0.8, step = 0.01),
                                sliderInput("sld_colsample", "colsample by tree", min = 0, max = 1, value = 0.8, step = 0.01)
                         )                
                       )
                     )
    ),
    conditionalPanel(condition = "input.rb_model == 'Random forest'",
                     h4("Random forest parameters"),
                     wellPanel(
                       fluidRow(
                         column(5,
                                #Parameters
                                ""
                         )
                       )
                     )
    )
  ),
  mainPanel(
    fluidRow(
      column(4,
             uiOutput("ui_log")
      ),
      column(8,
             uiOutput("ui_roc")
      )
    ),
    fluidRow(
      column(4,
             uiOutput("ui_importance")       
      ),
      column(8,
             uiOutput("ui_plot")       
      )
    )
  )
)