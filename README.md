## Harness the Power of Vue.js in R: vuer

`vuer` is an R package that makes it easy to use Vue components and build Vue apps.

> Vue (pronounced /vjuː/, like view) is a progressive framework for building user interfaces. It is designed from the ground up to be incrementally adoptable, and can easily scale between a library and a framework depending on different use cases.


## Installation

You can install `vuer` from github using `remotes` or `devtools`.

```{r}
remotes::install_github('ramnathv/vuer')
```

## Usage

### Example 1: Hello World

```{r}
hello_world <- tags$div(
  tags$label('Enter your name'),
  tags$input(type = "text", "v-model" = "name"),
  tags$p("Hello {{name}}")
) %>% 
  Vue(data = list(name = ""))
hello_world
```


### Example 2: Vue -> Shiny

It is easy to let Vue communicate with Shiny. All it takes is adding an underscore at the end of any data variable in Vue. This automatically sets up watcher functions to update shiny when the underlying value changes, thereby triggering any reactive paths that depend on it. Here is an example.

```{r}
ui <- tags$div(
  tags$label('Enter your name'),
  tags$input(type = "text", "v-model" = "name"),
  uiOutput("greeting")
) %>% 
  Vue(
    data = list(name_ = "")
  )


server <- function(input, output, session){
  output$greeting <- renderUI({
    tags$p(paste("Hello", input$name))
  })
}

shinyApp(ui = ui, server = server)
```


### Example 3: Shiny -> Vue

It is equally easy to let Shiny communicate with Vue. In this example we pass the coordinates of a plot brush to Vue and display it as JSON. 

```{r}
library(shiny)
library(ggplot2)
library(vuer)
ui <- fluidPage(
  titlePanel(title = 'Shiny -> Vue'),
  mainPanel(
    plotOutput('plot', brush = brushOpts('plot_brush')),
    tags$pre("v-if" = "plot_brush !== null", 
      tags$code("{{plot_brush}}")
    ) %>% 
      Vue(data = list(plot_brush = c()), elementId = "app")
  )
)

server <- function(input, output, session){
  output$plot <- renderPlot({
    ggplot(mtcars, aes(x = mpg, y = wt)) +
      geom_point()
  })
  observeEvent(input$plot_brush, {
    vueProxy("app") %>% 
      vueUpdateData(plot_brush = input$plot_brush)
  })
}
shinyApp(ui = ui, server = server)
```

## Acknowledgements

This package was inspired by Kenton Russell's [experiments](https://github.com/timelyportfolio/vueR) using Vue in R. 
