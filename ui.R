navbarPage(title = "Fraud analysis", theme = "style.css",
  tabPanel("Create model", source(file.path("ui", "nav-page.R"),  local = TRUE)$value),
  useShinyjs()
)