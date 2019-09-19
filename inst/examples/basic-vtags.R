library(htmltools)
library(vuer)

# Example 1: Hello World

vtags$div("{{ message }}") %>%
  Vue(data = list(message = 'Hello World'))

# Example 2:


vtags$span(
    vbind.title = "message",
    "Hover your mouse over me for a few seconds to see my dynamically bound title!"
) %>%
  Vue(data = list(
    message = htmlwidgets::JS("'You loaded me on ' + new Date()")
  ))

# Example 3:

tags$div(id = 'app',
  vtags$h3("Use the checkbox to toggle visibility of the message"),
  vtags$input(type = "checkbox", vmodel = "seen"),
  vtags$span(vif = "seen", "Now you see me again")
) %>%
  Vue(data = list(seen = TRUE))

# Example 4: Lists

vtags$li(vfor = "column in columns", "{{ column }}") %>%
  tags$ul(id = 'app') %>%
  Vue(data = list(columns = names(mtcars)))

# Example 5:

tags$div(id = 'app',
  vtags$input(type = 'text', vmodel = "message"),
  tags$p("{{ message }}"),
  vtags$button(von.click = "reverseMessage", "Reverse Message")
) %>%
  Vue(
    data = list(message = 'Hello World'),
    methods = list(
      reverseMessage = htmlwidgets::JS("function(){
         this.message = this.message.split('').reverse().join('')
      }")
    )
  )

