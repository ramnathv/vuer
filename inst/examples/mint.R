library(shiny)
#### Mint examples #######################################
mint <- htmlDependency(
  name = "mint-ui",
  version = "2.0.5",
  src = c(href="https://unpkg.com/mint-ui/lib"),
  script = "index.js",
  stylesheet = "style.css"
)

ui <- tags$div(
  #tags$script("Vue.use(MINT)"),
    vtag("mt-switch",list(vmodel ="value","{{value ? 'on' : 'off'}}")),
    vtag(
      "mt-checklist",
      list(
        title="checkbox list",
        vmodel = "checkbox_value",
        vbind.options = "['Item A', 'Item B', 'Item C']"
      )
    ),
    tags$p("Vue: {{ value }}"),
    textOutput('value'),
    textOutput('checkbox_value')
  ) %>%
  Vue(
    data = list(
      value_ = TRUE,
      checkbox_value_ = list()
    )
  ) %>%
  shinydashboard:::appendDependencies(mint)



server <- function(input, output, session){
  output$value <- renderText({
    paste("Shiny:", input$value)
  })
  output$checkbox_value <- renderText({
    paste("Shiny:", input$checkbox_value)
  })
}

shinyApp(ui = ui, server = server)
