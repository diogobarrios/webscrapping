library("rvest")
library("dplyr")
library("stringr")
library("purrr")
library("plyr")

cyberTelefonia <- "http://www.cybermadeira.com/telefonia.html?page=1.html"
cyber_telefonia <- read_html(cyberTelefonia)
str(cyber_telefonia)


cyberBody_nodes <- cyber_telefonia %>%
  html_nodes("body") %>%
  html_children()
cyberBody_nodes


cyberTitle <- cyber_telefonia %>%
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//h3[contains(@class, 'text-secondary')]") %>%
  rvest::html_text() %>%
  str_trim() %>%
  str_extract(pattern = ".*")


cyberPrice <- cyber_telefonia %>%
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class, 'text-danger font-weight-bolder')]") %>% 
  rvest::html_text() %>%
  str_extract(pattern = "^[0-9]+")

cyberCity <- cyber_telefonia %>%
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class, 'text-grey')]") %>% 
  rvest::html_text() 
  #str_split(pattern = ",")
cyberCity
cyberDescriptive <- cyber_telefonia %>%
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class, 'text-dark')]") %>% 
  rvest::html_text()

cyberDate <- cyber_telefonia %>%
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//div[contains(@class, 'col-6 col-sm-3 text-center text-dark')]") %>% 
  rvest::html_text() %>%
  str_extract("[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]") %>%
  na.exclude() %>%
  as.Date("%d/%m/%Y") 
cyberDate

cyber_df <- data.frame(cyberDate, cyberTitle, cyberPrice, cyberCity, cyberDescriptive)
View(cyber_df)

knitr::kable(
  cyber_df  %>% head(10)
)
# Doing with the links ---------------
 for (pagina in 1:56){
  url <- paste("http://www.cybermadeira.com/classificados-madeira_1_telefonia_23_",pagina,".html", sep ="")
  print(url)
  }

# Criei a função para extrair pagina a pagina os dados que pretendo.
# Pretendo agora automatizar para fazer sozinho
getData <- function(url){

  rawData <- read_html(url)
  
  cyberTitle <- rawData %>%
    rvest::html_nodes('body') %>% 
    xml2::xml_find_all("//a[contains(@class, 'title')]") %>% 
    rvest::html_text()
  
  cyberPrice <- rawData %>%
    rvest::html_nodes('body') %>% 
    xml2::xml_find_all[i]("//a[contains(@class, 'listPrice price text-right')]") %>% 
    rvest::html_text()
  
  cyberCity<- rawData %>%
    rvest::html_nodes('body') %>% 
    xml2::xml_find_all("//a[contains(@class, 'city')]") %>% 
    rvest::html_text()
  
  cyberDate <- rawData %>%
    rvest::html_nodes('body') %>% 
    xml2::xml_find_all("//span[contains(@class, 'col-sm-3 col-xs-6 c3')]") %>% 
    rvest::html_text() %>%
    str_extract("[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]") %>%
    as.Date() %>%
    na.omit()
  cyber_df <- data.frame(cyberTitle, cyberPrice, cyberCity, cyberDate)
  
  }

links <- c()
pagina <- 0
 while (pagina < 56){
  pagina <- pagina + 1
  url <- paste("http://www.cybermadeira.com/classificados-madeira_1_telefonia_23_",pagina,".html", sep ="")
  links <- c(links, url)
 }


