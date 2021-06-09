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

# JSON, pronounced "JASON"

library(RJSONIO)
url3 <- "http://www.r-datacollection.com/materials/ch-3-xml/indy.json"
isValidJSON(url3)
# TRUE

# In order to read the JSON file, I had to change from this
# LC_CTYPE=pt_PT to LC_CTYPE=C

Sys.getlocale() #LC_CTYPE=pt_PT
Sys.setlocale(category = "LC_CTYPE", locale = "C")
Sys.getlocale() #LC_CTYPE=C

indy <- fromJSON(content = "indy.json")

library(stringr)
indy.vec <-  unlist(indy, recursive = T, use.names = T)
indy.vec
indy[[1]][[1]]["year"]
sapply(indy[[1]], "[[", "year")
indy.unlist <- sapply(indy[[1]], unlist)

library(plyr) # for rbind.fill
indy.df <- do.call("rbind.fill", lapply(lapply(indy.unlist, t), data.frame, stringsAsFactors = F))

# do.call constructs and executes a function call from a name or a function and a 
# list of arguments to be passed to it.

# do.call(what, args, quote = FALSE, envir = parent.frame())

# rbind.fill, Combine data.frames by row, filling in missing columns.

peanuts.json <- fromJSON("peanuts.json", nullValue = NA, simplify = F)

peanuts.df <- do.call("rbind", lapply(peanuts.json, data.frame, stringsAsFactors = F))
peanuts.df

library(jsonlite)
# with jsonlite, goes to data.frame
(peanuts.json <- fromJSON("peanuts.json"))

# XPATH learning resource

library(XML)
url
# parsing to DOM
parsed_doc <- htmlParse(file = url)
#  print to preview
parsed_doc

# this is absolute path
xpathSApply(parsed_doc, "/html/body/div/p/i")

# this is a relative path
xpathSApply(parsed_doc, "//body//p/i")

# or
xpathSApply(parsed_doc, "//p/i")

# Wilcard operator *
xpathSApply(parsed_doc, "//body/div/*/i")

# wildcard operator ..
xpathSApply(parsed_doc, "//title/..")

# Wildcard operator \
xpathSApply(parsed_doc, "//title | //address")

# Or we can querying
twoqueries <- c(address = "//address", title = "//title")
xpathSApply(parsed_doc, twoqueries)

# Predicates with numerical operators
xpathSApply(parsed_doc, "//div/p[position()=1]")
# or
xpathSApply(parsed_doc, "//div/p[last()-1]")


xpathSApply(parsed_doc, "//div/p[last()]")

xpathSApply(parsed_doc, "//div[count(.//a)>0]")

# @ for attributes
xpathSApply(parsed_doc, "//div[count(./@*)]")
xpathSApply(parsed_doc, "//div[count(./@*)>2]")

xpathSApply(parsed_doc, "//*[string-length(text())>50]")

# All the nodes set
xpathSApply(parsed_doc, "//*")

# textual predicates
xpathSApply(parsed_doc, "//div[@date ='October/2011']")

xpathSApply(parsed_doc, "//*[contains(text(), 'magic')]")

xpathSApply(parsed_doc, "//div[starts-with(./@id, 'R')]")

xpathSApply(parsed_doc, "//div[substring-after(./@date, '/')='2003']//i")

# Extracting the node element
xpathSApply(parsed_doc, "//title", fun = xmlValue)

xpathSApply(parsed_doc, "//div//i", fun = xmlValue)

# Extracting Attributes
xpathApply(parsed_doc, "//div", fun = xmlAttrs)

# Extracting Specific Attributes
xpathSApply(parsed_doc, "//div", fun = xmlGetAttr, "lang")

xpathSApply(parsed_doc, "//div", fun = xmlGetAttr, "date")

# Exteding with custom functions

upperCaseFun <- function(x){
   x <- toupper(xmlValue(x))
   x}
xpathSApply(parsed_doc, "//div//i", fun = upperCaseFun)

lowerCaseFun <- function(x) {
   x <- tolower(xmlValue(x))
   x }
xpathSApply(parsed_doc, "//div//i", fun = lowerCaseFun)

DateFun <- function(x){
   require(stringr)
   date <- xmlGetAttr(x, "date")
   year <- str_extract(date, "[0-9]{4}")
   year
}
xpathSApply(parsed_doc, "//div", fun = DateFun)


idFun <- function(x){
   id <- xmlGetAttr(x, "id")
   id <- ifelse(is.null(id), "not specified", id)
   id
}
xpathSApply(parsed_doc, "//div", idFun)









