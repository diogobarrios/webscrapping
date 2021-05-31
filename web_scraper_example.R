# Starting over again to understand these technique.
# Based from Automated Data Collection with R

# HTML ---------------
# Example HTML readlines()
url <- "http://www.r-datacollection.com/materials/html/fortunes.html"
fortunes <- readLines(con = url)
fortunes

library("XML") # Parse HTML file to DOM
parsed_fortunes <- htmlParse(file = url)
parsed_fortunes

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

# XML & JSON ----------

library(XML)

# the file XML
url1 <- "http://www.r-datacollection.com/materials/ch-3-xml/stocks/technology.xml"

# Parse XML
parsed_stocks <- xmlParse(file = url1)
class(parsed_stocks)
# "XMLInternalDocument" "XMLAbstractDocument"
# It's not possible te get lists

# Return root elemen's name and the number of children
root <- xmlRoot(parsed_stocks)
xmlName(root)
xmlSize(root)

class(root)
# "XMLInternalElementNode" "XMLInternalNode" "XMLAbstractNode"         
# within these class its possible to get lists

# This give me the first node
root[[1]]
#or
root[["Apple"]] 
#  <Apple>
#  <date>2013/11/13</date>
#  <close>520.634</close>
#  <volume>7022001.0000</volume>
#  <open>518</open>
#  <high>522.25</high>
#  <low>516.96</low>
#  <company>Apple</company>
#  <year>2013</year>
#  </Apple> 

# From the first node, the first attr
root[[1]][[1]]
#or
root[["Apple"]][["date"]]
# <date>2013/11/13</date> 

# From the first node and first attr, the first atomic value
root[[1]][[1]][[1]]
#or
root[["Apple"]][["date"]][[1]]

# Open a RSS file
url2 <- "http://www.r-datacollection.com/materials/ch-3-xml/rsscode.rss"
xmlParse(file = url2)

# XML files to data.frame or list
xmlSApply(root[[1]], xmlValue)

# conversion XML file to data.frame
stock.df <- xmlToDataFrame(root)
head(stock.df,5)

# If some of the variables get +1 attr, we could use the list conversion
#xmlToList()


# to handle with memory management in R, we can work the Apple Stock XML file with
# another approach

# SAX - Simple API XML
 branchFun <- function(){
   container_close <- numeric()
   container_date <- numeric()
 
 "Apple" = function(node, ...){
   date <- xmlValue(xmlChildren(node)[[c("date")]])
   container_date <<- c(container_date, date)
   close <- xmlValue(xmlChildren(node)[[c("close")]])
   container_close <<- c(container_close, close)
 }
 getContainer <- function() data.frame(date = container_date, close = container_close)
list(Apple = Apple, getStore = getContainer)
 }
 
(h5 <- branchFun())
 
 invisible(xmlEventParse(file = url1, branches = h5, handlers = list()))

apple.stock <- h5$getStore()
head(apple.stock,5)






