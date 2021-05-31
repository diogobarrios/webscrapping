library("rvest")
library("xml2")
library("dplyr")
library("stringr")

# pull url 
cyberTelefonia <- "http://www.cybermadeira.com/telefonia.html?page=1.html"
cyber_telefonia <- read_html(cyberTelefonia)
str(cyber_telefonia)


cyberBody_nodes <- cyber_telefonia %>%
  html_nodes("body") %>%
  html_children()
cyberBody_nodes


cyberTitle <- cyber_telefonia %>%
  html_nodes('body') %>% 
  xml_find_all("//h3[contains(@class, 'text-secondary')]") %>%
  html_text() %>%
  # cutting the blank spaces
  str_trim() %>%
  # only the first string
  str_extract(pattern = ".*")


cyberPrice <- cyber_telefonia %>%
  html_nodes('body') %>% 
  xml_find_all("//span[contains(@class, 'text-danger font-weight-bolder')]") %>% 
  html_text() %>%
  # Only the numerals
  str_extract(pattern = "^[0-9]+")

cyberCity <- cyber_telefonia %>%
  html_nodes('body') %>% 
  xml_find_all("//span[contains(@class, 'text-grey')]") %>% 
  html_text() 

cyberDescriptive <- cyber_telefonia %>%
  html_nodes('body') %>% 
  xml_find_all("//span[contains(@class, 'text-dark')]") %>% 
  html_text()

cyberDate <- cyber_telefonia %>%
  html_nodes('body') %>% 
  xml_find_all("//div[contains(@class, 'col-6 col-sm-3 text-center text-dark')]") %>% 
  html_text() %>%
  # extracting only the date
  str_extract("[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]") %>%
  na.exclude() %>%
  # formatting in date with lubridate pkg
  as.Date("%d/%m/%Y") 

# Getting all in data.frame
cyber_df <- data.frame(cyberDate, cyberTitle, cyberPrice, cyberCity, cyberDescriptive)


# Putting all together,
# Creating a function to iterate the url from page to page.

getData <- function(url){
# Get the url in a var
  urlData <- read_html(url)
  
  # pull the information that I need from the url
  
  cyberTitle <- urlData %>%
    html_nodes('body') %>% 
    xml_find_all("//h3[contains(@class, 'text-secondary')]") %>%
    html_text() %>%
    # cutting the blank spaces
    str_trim() %>%
    # only the first string
    str_extract(pattern = ".*")
  
  
  cyberPrice <- urlData %>%
    html_nodes('body') %>% 
    xml_find_all("//span[contains(@class, 'text-danger font-weight-bolder')]") %>% 
    html_text() %>%
    # Only the numerals
    str_extract(pattern = "^[0-9]+")
  
  cyberCity <- urlData %>%
    html_nodes('body') %>% 
    xml_find_all("//span[contains(@class, 'text-grey')]") %>% 
    html_text() 
  
  cyberDescriptive <- urlData %>%
    html_nodes('body') %>% 
    xml_find_all("//span[contains(@class, 'text-dark')]") %>% 
    html_text()
  
  cyberDate <- urlData %>%
    html_nodes('body') %>% 
    xml_find_all("//div[contains(@class, 'col-6 col-sm-3 text-center text-dark')]") %>% 
    html_text() %>%
    # extracting only the date
    str_extract("[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]") %>%
    na.exclude() %>%
    # formatting in date with lubridate pkg
    as.Date("%d/%m/%Y") 
  # Adding in a data.frame the gathered info
  dat_df <- data.frame(cyberDate, cyberTitle, cyberPrice, cyberCity, cyberDescriptive)
 return(dat_df)
   }

# Creating empty variables
links <- NULL
df_telefonia <- NULL
# The length of the variable is only known, seeing "in loco" how much pages has in the url
for(page in 1:111){
url <- paste("http://www.cybermadeira.com/telefonia.html?page=",page,sep ="")
links <- c(links, url)
}
# looping over the links to get the data.frame
for(i in links){
  dat <- getData(i)
  df_telefonia <- rbind(df_telefonia, dat)
}
# Saving the df_telefonia that I just scrapped.
write.csv(df_telefonia, file = "telefonia.csv")





