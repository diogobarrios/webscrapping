# Starting over again to understand these technique.
# Based from Automated Data Collection with R

# Example HTML readlines()
url <- "http://www.r-datacollection.com/materials/html/fortunes.html"
fortunes <- readLines(con = url)
fortunes

library("XML") # Parse HTML file to DOM
parsed_fortunes <- htmlParse(file = url)
print(parsed_fortunes)

# creating handlers
h1 <- list("body" = function(x) {NULL})
parsed_fortunes <- htmlTreeParse(url, handlers = h1, asTree = T)
parsed_fortunes$children

# creating handlers to delete all nodes with name div or title as well as comments
h2 <- list(
        startElement = function(node, ...){
          name <- xmlName(node)
          if(name %in% c("div", "title")) {NULL}
          else 
          {node}},
          comment = function(node){NULL}
)


parsed_fortunes <- htmlTreeParse(url, handlers = h2, asTree = T)
parsed_fortunes$children
