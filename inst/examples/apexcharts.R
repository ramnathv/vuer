library(vuer)

htmlDependenciesApexCharts <- function(){
  list(
    htmltools::htmlDependency(
      name = 'apexcharts',
      version = '2.7.0',
      src = c(href = 'https://unpkg.com/apexcharts/dist'),
      script = 'apexcharts.js'
    ),
    htmltools::htmlDependency(
      name = 'vue-apexcharts',
      version = '1.3.0',
      src = c(href = "https://unpkg.com/vue-apexcharts/dist"),
      script = 'vue-apexcharts.js'
    )
  )
}

vueApexChart <- function(...){
  vueComponents$register(apexchart = 'VueApexCharts')
  htmltools::tag("apexchart", list(...)) %>%
    appendDependencies(htmlDependenciesApexCharts())
}

data <- list(
  chartOptions = list(
    chart = list(
      xaxis = list(
        categories = as.character(1991:1998)
      )
    )
  ),
  series = list(
    list(name = 'series-1', data = sample(40:100, 8))
  )
)

library(shiny)
ui <- div(
  vueApexChart(height = 350, ":series" = "series", type = "bar",
    ":options" = "chartOptions"
  ),
  actionButton("update_data", "Update Data")
) %>%
  vue(data = data, elementId = "chart")

server <- function(input, output, session){
  observeEvent(input$update_data, {
    vueProxy("chart") %>%
      vueUpdateData(series = list(list(data = sample(40:80, 8))))
  })
}

shinyApp(ui = ui, server = server)
