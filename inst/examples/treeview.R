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
      appendDependencies(html_deps_vue_tree_view()),
    tags$script('Vue.use(TreeView)')
  )
}

## Example 1:
div(vueJsonTreeOutput(":data" = "data")) %>%
  Vue(data = list(data = list(x = 1, y = 2)))


## Example 2:
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
  output$plot1 <- renderPlot({
    require(ggplot2)
    ggplot(mtcars, aes(x = mpg, y = wt)) +
      geom_point()
  })
  observeEvent(input$plot_brush, {
    vueProxy("app") %>%
      vueUpdateData(data = input$plot_brush)
  })
}

shinyApp(ui = ui, server = server)

