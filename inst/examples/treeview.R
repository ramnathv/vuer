library(shiny)
library(vuer)

html_deps_vue_tree_view <- function(){
  htmltools::htmlDependency(
    name = 'vue-json-tree-view',
    version = '2.0.6',
    src = c(href = "https://unpkg.com/vue-json-tree-view@2.0.6/dist"),
    script = 'vue-json-tree-view.min.js'
  )
}

vueJsonTreeOutput <- function(...){
  tagList(
    tag('tree-view', list(...)) %>%
      shinydashboard:::appendDependencies(
        html_deps_vue_tree_view()
      ),
    tags$script('Vue.use(TreeView)')
  )
}

div(vueJsonTreeOutput(":data" = "data")) %>%
  Vue(data = list(data = list(x = 1, y = 2)))


ui <- fluidPage(
  titlePanel("Shiny with Vue"),
  mainPanel(
    fluidRow(
      plotOutput('plot1', brush = brushOpts(id = 'plot_brush')),
      vueJsonTreeOutput(":data" = "data")
    ) %>%
    vuepkg::Vue(
      data = list(data = list()),
      elementId = "app"
    )
  )
)

server <- function(input,output,session){
  output$plot1 <- renderPlot({plot(1:10)})
  observeEvent(input$plot_brush, {
    vueProxy("app") %>%
      vueUpdate(data = input$plot_brush)
  })
}

shinyApp(ui = ui, server = server)

