library(htmltools)
library(vuepkg)
library(magrittr)

# Example 1: Hello World

tags$div("{{ message }}") %>%
  Vue(data = list(message = 'Hello World'))

# Example 2:


tags$span(
    "v-bind:title" = "message",
    "Hover your mouse over me for a few seconds to see my dynamically bound title!"
) %>%
  Vue(data = list(
    message = htmlwidgets::JS("'You loaded me on ' + new Date()")
  ))

# Example 3:

tags$div(id = 'app',
  tags$h3("Use the checkbox to toggle visibility of the message"),
  tags$input(type = "checkbox", "v-model" = "seen"),
  tags$span("v-if" = "seen", "Now you see me again")
) %>%
  Vue(data = list(seen = TRUE))

# Example 4: Lists

tags$li("v-for" = "column in columns", "{{ column }}") %>%
  tags$ul(id = 'app') %>%
  Vue(data = list(columns = names(mtcars)))

# Example 5:

tags$div(id = 'app',
  tags$input(type = 'text', "v-model" = "message"),
  tags$p("{{ message }}"),
  tags$button("v-on:click" = "reverseMessage", "Reverse Message")
) %>%
  Vue(
    data = list(message = 'Hello World'),
    methods = list(
      reverseMessage = htmlwidgets::JS("function(){
         this.message = this.message.split('').reverse().join('')
      }")
    )
  )

