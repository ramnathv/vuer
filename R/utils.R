as_props_list <- function (x, name = "name", value = "value"){
  x <- as.list(x)
  nms <- names(x)
  lapply(seq_along(x), function(i) {
    l <- list()
    l[name] <- nms[i]
    l[value] <- x[i]
    l
  })
}

#' @export
vue_use_plugin <- function(fun){
  tags$script(sprintf("Vue.use(%s)", fun))
}
