library(rvest)
if(!require("RSelenium")) {install.packages("RSelenium")}
install.packages("httr")
library(RSelenium)
library(tidyverse)
library(httr)
library(xml2)
library(jsonlite)
library(wdman)
library(stringr)
remove.packages("wdman")
install.packages("remotes")
library(remotes)
install_version("wdman", "0.2.6")


#Setup Selenium Server
selServ <- rsDriver(port = 4567L , browser = c("firefox"), chromever = NULL)



# Connect to the remote driver
remDr <- selServ$client
remDr$navigate("https://www.cnbc.com/search/?query=%22credit%20suisse%22&qsearchterm=%22credit%20suisse%22")

dynamic_url <- remDr$getCurrentUrl()[[1]]
dynamic_url


response_content <- remDr$getPageSource()[[1]]

# Extract the URLs
links <- read_html(response_content) %>% html_nodes("a.resultlink")
page_urls <- links %>% html_attr("href")

page_urls

html <- read_html("https://www.cnbc.com/2024/04/05/ubs-ceo-says-credit-suisse-will-be-a-case-study-for-big-bank-mergers.html?&qsearchterm=")

article_title <- html %>%
  html_nodes(".ArticleHeader-headline") %>% html_text()
article_title

text_date <- html %>%
  html_node(xpath = "//time[@data-testid='lastpublished-timestamp']") %>%  
  html_attr("datetime") %>%                     
  as.Date()

text_date

article_headline <- html %>%
  html_nodes(".RenderKeyPoints-list") %>% as.character() %>%
  read_html() %>%
  html_text() %>% str_replace_all("\n", "")
  
article_headline
  
  
article_content <- html %>%
  html_nodes(".ArticleBody-articleBody p") %>% 
  html_text() %>% paste(collapse = " ")
article_content


# Click on the dropdown to open it
dropdown <- remDr$findElement("css", "#formatfilter")
dropdown$clickElement()

# Wait for a short moment to ensure the dropdown options are visible
Sys.sleep(1)

# Find and click on the "Articles" option
articles_option <- remDr$findElement("css", "option[value='Articles']")
articles_option$clickElement()


# Define a function to scroll down the page
scroll_down <- function(selServ) {
  selServ$executeScript("window.scrollTo(0, document.body.scrollHeight / 2);")
}

scroll_down(remDr)

for (i in 1:2) {  # Example: Scroll 5 times
  scroll_down(remDr)
  Sys.sleep(2)  # Wait for a brief moment for new articles to load (adjust the time as needed)
}

count_articles <- function() {
  articles <- remDr$findElements("css", ".SearchResult-searchResult")
  return(length(articles))
}

desired_articles <- 100
articles_loaded <- 0

# Loop until the desired number of articles is loaded
while (articles_loaded < desired_articles) {
  # Scroll down
  remDr$executeScript("window.scrollBy(0, 1000);")
  # Wait for some time for the articles to load
  Sys.sleep(3)
  # Count the number of articles loaded
  articles_loaded <- count_articles()
}

# article_content_fixed <- gsub('[(\")(\\)]', '', article_content)
# article_content_fixed
#################################################################################################################### 
#################################################################################################################### 
### get URLs for "Credti Suisse"
#################################################################################################################### 
#################################################################################################################### 



# Construct the search URL
search_url <- paste0("https://www.cnbc.com/search/?query=%22credit%20suisse%22&qsearchterm=%22credit%20suisse%22")

# Navigate to the search URL
remDr$navigate(search_url)
Sys.sleep(5)


# Click on the dropdown to open it
dropdown <- remDr$findElement("css", "#formatfilter")
dropdown$clickElement()

# Wait for a short moment to ensure the dropdown options are visible
Sys.sleep(1)

# Find and click on the "Articles" option
articles_option <- remDr$findElement("css", "option[value='Articles']")
articles_option$clickElement()



# Define function that counts the amount of loaded articles
count_articles <- function() {
  articles <- remDr$findElements("css", ".SearchResult-searchResult")
  return(length(articles))
}
#count_articles()
desired_articles <- 1000
articles_loaded <- 0

while (articles_loaded < desired_articles) {
  # Scroll down (by defined amount of pixels)
  remDr$executeScript("window.scrollBy(0, 500);")
  # Wait for some time for the articles to load
  Sys.sleep(2)
  # Count the number of articles loaded
  articles_loaded <- count_articles()
}

articles_loaded
# Initialize variables
urls <- c()


# Retrieve the page source
response_content <- remDr$getPageSource()[[1]]

# Extract the URLs
links <- read_html(response_content) %>% html_nodes("a.resultlink")
page_urls <- links %>% html_attr("href")

# Add unique URLs to the list
urls <- unique(c(urls, page_urls))


# Close the Selenium browser
remDr$close()
selServ$server$stop()
#################################################################################
#################################################################################
#################################################################################


# Print the URLs
cat("Scraped URLs:\n")
cat(urls, sep = "\n")

CNBC_scraped_urls_CS <- urls
output_file_urls <- "~/Masterarbeit/CNBC scraper/CNBC_scraped_urls_CS.csv"
write.csv(CNBC_scraped_urls_CS, file = output_file_urls, row.names = FALSE, col.names = c("URL"))


#################################################################################################################### 
#################################################################################################################### 
### get URLs for "UBS"
#################################################################################################################### 
#################################################################################################################### 



# Construct the search URL
search_url <- paste0("https://www.cnbc.com/search/?query=%22UBS%22&qsearchterm=%22UBS%22")

# Navigate to the search URL
remDr$navigate(search_url)
Sys.sleep(5)


# Click on the dropdown to open it
dropdown <- remDr$findElement("css", "#formatfilter")
dropdown$clickElement()

# Wait for a short moment to ensure the dropdown options are visible
Sys.sleep(1)

# Find and click on the "Articles" option
articles_option <- remDr$findElement("css", "option[value='Articles']")
articles_option$clickElement()



# Define function that counts the amount of loaded articles
count_articles <- function() {
  articles <- remDr$findElements("css", ".SearchResult-searchResult")
  return(length(articles))
}
#count_articles()
desired_articles <- 1000
articles_loaded <- 0

while (articles_loaded < desired_articles) {
  # Scroll down (by defined amount of pixels)
  remDr$executeScript("window.scrollBy(0, 500);")
  # Wait for some time for the articles to load
  Sys.sleep(2)
  # Count the number of articles loaded
  articles_loaded <- count_articles()
}

articles_loaded
# Initialize variables
urls <- c()


# Retrieve the page source
response_content <- remDr$getPageSource()[[1]]

# Extract the URLs
links <- read_html(response_content) %>% html_nodes("a.resultlink")
page_urls <- links %>% html_attr("href")

# Add unique URLs to the list
urls <- unique(c(urls, page_urls))


# Close the Selenium browser
remDr$close()
selServ$server$stop()
#################################################################################
#################################################################################
#################################################################################


# Print the URLs
cat("Scraped URLs:\n")
cat(urls, sep = "\n")

CNBC_scraped_urls_UBS <- urls
output_file_urls <- "~/Masterarbeit/CNBC scraper/CNBC_scraped_urls_UBS.csv"
write.csv(CNBC_scraped_urls_UBS, file = output_file_urls, row.names = FALSE, col.names = c("URL"))



####################################################################
####################################################################
#SCRAPING LOOP
######################################################################
#####################################################################


# List of URLs to scrape
length(urls)
html <- read_html("https://www.cnbc.com/2024/04/05/ubs-ceo-says-credit-suisse-will-be-a-case-study-for-big-bank-mergers.html?&qsearchterm=")

url_list <- urls  # Replace with your actual URLs

# Create an empty dataframe to store the scraped content
scraped_data <- data.frame(article_title = character(),
                           article_headline = character(),
                           article_content = character(),
                           text_date = character(),
                           article_url = character(),
                           stringsAsFactors = FALSE)

# Loop through each URL and scrape the desired content

articles_scraped <- 0  # Initialize a counter for scraped articles

for (url in url_list) {
  tryCatch({
    # Perform scraping and extract article title, merged string, and text date
    # Modify the scraping code based on the structure of the website you are scraping
    # Replace the placeholders with the actual code for scraping each element
    
    html <- read_html(url)
    
    article_title <- html %>%
      html_nodes(".ArticleHeader-headline") %>% html_text()
    
    text_date <- html %>%
      html_node(xpath = "//time[@data-testid='lastpublished-timestamp']") %>%  
      html_attr("datetime") %>%                     
      as.Date()
    
    article_headline <- html %>%
      html_nodes(".RenderKeyPoints-list") %>% as.character() %>%
      read_html() %>%
      html_text() %>% str_replace_all("\n", "")
    
    
    article_content <- html %>%
      html_nodes(".ArticleBody-articleBody p") %>% 
      html_text() %>% paste(collapse = " ")
    
    article_url <- url
    
    
    # Check if all required elements have valid values
    if (length(article_title) > 0 && length(text_date) > 0 && nchar(article_content) > 0 && nchar(article_headline) > 0 && length(article_url) > 0) {
      # Add the scraped content to the dataframe
      scraped_data <- rbind(scraped_data, data.frame(article_title, article_headline, article_content, text_date, article_url, stringsAsFactors = FALSE))
      Sys.sleep(sample(3:4, 1))
      articles_scraped <- articles_scraped + 1  # Increment the counter
      cat(articles_scraped, "article(s) scraped\n")  # Print the number of articles scraped
    }
  }, error = function(e) {
    # Handle errors gracefully (e.g., print a message and continue)
    cat("Error while scraping URL:", url, "\n")
  })
}

# Print the scraped data
print(scraped_data[4,5])
CNBC_scraped_data_UBS_23_04 <- scraped_data
output_file <- "~/Masterarbeit/CNBC scraper/CNBC_scraped_data_UBS_23_04.csv"
write.csv(CNBC_scraped_data_UBS_23_04, file = output_file, row.names = FALSE)









scraped_data_CS_april[1,1]

# Close the browser and stop the Selenium server
remDr$close()
selServ$server$stop()






