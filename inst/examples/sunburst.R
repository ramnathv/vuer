# Load Libraries ----
library(shiny)
library(treemap)
library(vuer)
library(magrittr)
library(htmltools)
library(htmlwidgets)
library(d3r)
jsFun <- function(body, ...){
  args <- paste(c(...), collapse = ",")
  htmlwidgets::JS(sprintf("function(%s){%s}", args, body))
}

# Define Dependencies ----
html_dependencies_d2b <- function(){
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

# Define Chart Generator
vueSunburstChart <- function(...){
  vuer::vueComponents$register(
    "sunburst-chart" = "d2b.vueChartSunburst"
  )
  tag('sunburst-chart', list(...))  %>%
    appendDependencies(html_dependencies_d2b())
}



# UI ----
ui <- tags$div(style = 'height:400px',
  vueSunburstChart(":data" = "chart_data", ":config" = "chart_config"),
  actionButton('update_data', 'Update Data')
) %>%
  Vue(
    data = list(
      chart_data_ = d3r::d3_nest(
        treemap::random.hierarchical.data(),
        value_cols = "x"
      ),
      chart_config = jsFun("
        chart.label((d) => d.name);
        chart.sunburst().size((d) => d.x);
      ", "chart")
    ),
    elementId = 'mychart',
    width = '100%'
  )


# Server ----
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
