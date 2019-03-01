library(shiny)
library(treemap)
library(vuer)
library(magrittr)
library(htmltools)
library(htmlwidgets)
library(d3r)

html_deps_d2b <- function(){
  list(
    d3r::d3_dep_v4(offline = FALSE),
    htmltools::htmlDependency(
      name = "d2b",
      version = "0.0.24",
      src = c(href = "https://unpkg.com/d2b@0.0.24/build/"),
      script = "d2b.min.js"
    )
  )
}

sunburstChart <- function(...){
  tag('sunburst-chart', list(...))  %>%
    appendDependencies(html_deps_d2b())
}

vueComponent <- function(v, ...){
  v$x$components <- modifyList(v$x$components, list(...))
  return(v)
}

ui <- tags$div(style = 'height:400px',
  sunburstChart(":data" = "chart_data", ":config" = "chart_config"),
  actionButton('update_data', 'Update Data')
) %>%
  Vue(
    data = list(
      chart_data_ = d3r::d3_nest(
        treemap::random.hierarchical.data(),
        value_cols = "x"
      ),
      chart_config = JS("function(chart) {
        chart.label((d) => d.name);
        chart.sunburst().size((d) => d.x);
      }")
    ),
    components = list(
      "sunburst-chart" = JS("d2b.vueChartSunburst")
    ),
    elementId = 'mychart',
    width = '100%'
  )


server <- function(input, output, session){
  observeEvent(input$update_data, {
    vueProxy('mychart') %>%
      vueUpdateData(
        chart_data = d3r::d3_nest(
          treemap::random.hierarchical.data(),
          value_cols = "x"
        )
      )
  })
}

shinyApp(ui = ui, server = server)
