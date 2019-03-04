library(vuer)
library(ggplot2)
library(shiny)

html_dependencies_vue_color <- function(){
  htmltools::htmlDependency(
    name = 'vue-color',
    version = '2.7.0',
    src = c(href = 'https://unpkg.com/vue-color/dist'),
    script = 'vue-color.min.js'
  )
}

vueColorPickerInput <- function(type = types, ...){
  types <- c('compact', 'chrome', 'swatches', 'sketch')
  types %>%
    purrr::map(~ {
      .x %>%
        stringi::stri_trans_totitle() %>%
        paste0('VueColor.', .)
    }) %>%
    rlang::set_names(paste0(types, '-picker')) %>%
    vueComponents$register(.list = .)
  type <- match.arg(type)
  htmltools::tag(
    sprintf("%s-picker", type), list("v-model" = "colors", ...)
  ) %>%
    appendDependencies(list(html_dependencies_vue_color()))
}



ui <- div(
  vueColorPickerInput(type = "sketch"),
  shiny::plotOutput('plot')
) %>%
  Vue(
    data = list(colors_ = '#fff')
  )

server <- function(input, output, session){
   output$plot <- renderPlot({
     mycolor <- if (is.null(input$colors)) 'black' else input$colors$hex[1]
     ggplot(mtcars, (aes(x = wt, y = mpg))) +
       geom_point(color = mycolor)
   })
   output$colors <- renderText({
     input$colors$hex[1]
   })
}

shiny::shinyApp(ui = ui, server = server)
