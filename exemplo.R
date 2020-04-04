# Para web scrapping preciso:
# tidyverse package
# rvest package
# selectr package
# xml12 package

# Carregar os pacotes 
library(tidyverse)
library(rvest)
library(selectr)
library(xml2)

# Especificando o url para o website a ser scrapped
url <- "https://www.amazon.in/OnePlus-Mirror-Black-64GB-Memory/dp/B0756Z43QS?tag=googinhydr18418-21&tag=googinkenshoo-21&ascsubtag=aee9a916-6acd-4409-92ca-3bdbeb549f80"

# lendo o conteudo do url da amazon
webpage <- read_html(url)

# scrapper o titulo dos artigos
title_html <- html_nodes(webpage, "h1#title")
title <- html_text(title_html)
head(title)

# remover os espaços e linhas novas
str_replace_all(title, "[\r\n]", "")

# scraper o preço do artigo
price_html <- html_nodes(webpage, "span#priceblock_ourprice")
price <- html_text(price_html)
head(price)
str_replace_all(price, "[\r\n]", "")

# Combinando a informação
product_data <- data.frame(Title = title, Price = price)
str(product_data)




