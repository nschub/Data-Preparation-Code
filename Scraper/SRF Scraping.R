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
remDr$navigate("https://www.srf.ch/suche?q=credit+suisse&date=all&page=0")

#################################################################################################################### get all URLs

# Define the search query
search_query <- "CS"
encoded_query <- gsub(" ", "+", search_query)


# Initialize variables
urls <- c()
page <- 0
max_pages <- 100  # Maximum number of pages to scrape

# Loop until there are no more search results or maximum pages reached
while (TRUE) {
  # Construct the search URL
  search_url <- paste0("https://www.srf.ch/suche?q=", encoded_query, "&date=all&page=", page)
  
  # Navigate to the search URL
  remDr$navigate(search_url)
  Sys.sleep(5)
  
  # Extract the dynamically generated URL
  dynamic_url <- remDr$getCurrentUrl()[[1]]
  cat("Scraping URLs from:", dynamic_url, "\n")
  
  # Retrieve the page source
  response_content <- remDr$getPageSource()[[1]]
  
  # Extract the URLs
  links <- read_html(response_content) %>% html_nodes("a.teaser-ng--article")
  page_urls <- links %>% html_attr("href")
  
  # Add unique URLs to the list
  urls <- unique(c(urls, page_urls))
  
  # Click the "Show More" button
  elem <- remDr$findElement("css selector", ".show-more-bar")
  elem$clickElement()
  Sys.sleep(5)
  
  # Increment the page number
  page <- page + 1
  
  # Check if there are no more search results or maximum pages reached
  if (length(page_urls) == 0 || page >= max_pages) {
    cat("No more search results or reached maximum pages. Total URLs scraped:", length(urls), "\n")
    break
  }
}

# Close the Selenium browser
remDr$close()
selServ$server$stop()

urls[1]

# Print the URLs
cat("Scraped URLs:\n")
cat(urls, sep = "\n")

scraped_urls_CS_april <- urls
output_file_urls <- "~/Masterarbeit/srf scraper/scraped_urls_CS_april.csv"
write.csv(scraped_urls_CS_april, file = output_file_urls, row.names = FALSE, col.names = c("URL"))

####################################################################
####################################################################
#SCRAPING LOOP
######################################################################
#####################################################################
#read in urls


fixed_urls <- sub("^/", "https://www.srf.ch/", urls)
urls <- fixed_urls
urls[1]
# List of URLs to scrape
url_list <- urls  # Replace with your actual URLs

# Create an empty dataframe to store the scraped content
scraped_data <- data.frame(article_title = character(),
                           merged_string = character(),
                           text_date = character(),
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
    html_nodes(".article-title__text") %>% html_text()
  
  text_date <- html %>%
    html_nodes(".js-dateline") %>% html_attr("data-publicationdate")
  
  article_content <- html %>%
    html_nodes(".article-content") %>% as.character() %>%
    read_html() %>% html_nodes(".article-content > :not([class])") %>%
    html_text() 
  
  
  merged_string <- ""
  add_dot <- FALSE
  
  for (i in 1:length(article_content)) {
    if (article_content[i] == "" && i < length(article_content)) {
      add_dot <- TRUE
    } else if (add_dot && article_content[i] != "") {
      merged_string <- paste0(merged_string, article_content[i], ": ")
      add_dot <- FALSE
    } else if (article_content[i] != "") {
      merged_string <- paste0(merged_string, article_content[i], " ")
    }
  }
  
  
  
  # Remove leading whitespace and newlines
  merged_string <- trimws(merged_string) %>% str_replace_all("\n", "")
  
  # Check if all required elements have valid values
  if (length(article_title) > 0 && length(text_date) > 0 && nchar(merged_string) > 0) {
    # Add the scraped content to the dataframe
    scraped_data <- rbind(scraped_data, data.frame(article_title, merged_string, text_date, stringsAsFactors = FALSE))
    Sys.sleep(sample(1:2, 1))
    articles_scraped <- articles_scraped + 1  # Increment the counter
    cat(articles_scraped, "article(s) scraped\n")  # Print the number of articles scraped
  }
  }, error = function(e) {
    # Handle errors gracefully (e.g., print a message and continue)
    cat("Error while scraping URL:", url, "\n")
  })
}

# Print the scraped data
print(scraped_data[379,1])
scraped_data_CS_april <- scraped_data


output_file <- "~/Masterarbeit/scraped_data_UBS_290424.csv"
write.csv(scraped_data_UBS_april, file = output_file, row.names = FALSE)











# Close the browser and stop the Selenium server
remDr$close()
selServ$server$stop()

