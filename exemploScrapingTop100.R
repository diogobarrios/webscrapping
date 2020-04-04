library("rvest")
library("dplyr")
# outro exemplo, scraping/harvesting 
# The Hot 100 Chart | Billboard
hot100page <- "https://www.billboard.com/charts/hot-100"
hot100 <- read_html(hot100page)
str(hot100)

body_nodes <- hot100 %>%
  html_nodes("body") %>%
  html_children()
body_nodes

rank <- hot100 %>% 
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class, 'chart-element__rank__number')]") %>% 
  rvest::html_text()

artist <- hot100 %>% 
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class, 'chart-element__information__artist')]") %>% 
  rvest::html_text()

title <- hot100 %>% 
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class, 'chart-element__information__song')]") %>% 
  rvest::html_text()

chart_df <- data.frame(rank, artist, title)

knitr::kable(
  chart_df  %>% head(10)
)

