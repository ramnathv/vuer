library(shiny)
library(treemap)
library(vuer)
library(magrittr)
library(htmltools)
library(htmlwidgets)
library(d3r)

d2b_dep <- htmltools::htmlDependency(
  name = "d2b",
  version = "0.0.24",
  src = c(href = "https://unpkg.com/d2b@0.0.24/build/"),
  script = "d2b.min.js"
)

sunburstChart <- function(...){
  tag('sunburst-chart',
      list(...)
  )  %>%
    shinydashboard:::appendDependencies(
      d3r::d3_dep_v4(offline = FALSE)
    ) %>%
    shinydashboard:::appendDependencies(d2b_dep)
}

ui <- tags$div(style = 'height:400px', id = 'app',
  sunburstChart(":data" = "chart_data", ":config" = "chart_config")
) %>%
  Vue(
    data = list(
      chart_data = d3r::d3_nest(
        treemap::random.hierarchical.data(),
        value_cols = "x"
      ),
      chart_config = JS("function(chart) {
        chart.label(function(d){return d.name});
        chart.sunburst().size(function(d){return d.x});
      }")
    ),
    components = list(
      "sunburst-chart" = JS("d2b.vueChartSunburst")
    ),
    watch = vue_watch("data"),
    elementId = 'mychart',
    width = '100%'
  )


server <- function(input, output, session){
  observe({
    invalidateLater(1000, session)
    vueProxy('mychart') %>%
      vueUpdate(
        chart_data = d3r::d3_nest(
          treemap::random.hierarchical.data(),
          value_cols = "x"
        )
      )
  })
}

shinyApp(ui = ui, server = server)
