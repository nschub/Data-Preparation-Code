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
selServ <- rsDriver(port = 4566L , browser = c("firefox"), chromever = NULL)



# Connect to the remote driver
remDr <- selServ$client
remDr$navigate("https://www.ft.com/search?q=Credit+Suisse&dateTo=2023-06-30&dateFrom=2019-01-01&sort=relevance&expandRefinements=true")


response_content <- remDr$getPageSource()[[1]]

# Extract the URLs
links <- read_html(response_content) %>% html_nodes(".o-teaser__heading a")
page_urls <- links %>% html_attr("href")

#################################################################################################################### get all URLs



# Define the search query
search_query <- "UBS"
encoded_query <- gsub(" ", "+", search_query)
remDr$navigate(search_url)
# Initialize variables
urls <- c()
page <- 0
max_pages <- 39  # Maximum number of pages to scrape
#2019-01-01 to 2019-12-29, 39 pages
# Loop until there are no more search results or maximum pages reached
while (TRUE) {
  # Construct the search URL
  search_url <- paste0("https://www.ft.com/search?q=", encoded_query,"&page=", page+1, "&dateTo=2019-12-29&dateFrom=2019-01-01&sort=relevance&expandRefinements=true&isFirstView=false&contentType=article")
  
  # Navigate to the search URL
  remDr$navigate(search_url)
  Sys.sleep(5)
  
  # Extract the dynamically generated URL
  dynamic_url <- remDr$getCurrentUrl()[[1]]
  cat("Scraping URLs from:", dynamic_url, "\n")
  
  # Retrieve the page source
  response_content <- remDr$getPageSource()[[1]]
  
  # Extract the URLs
  links <- read_html(response_content) %>% html_nodes(".o-teaser__heading a")
  page_urls <- links %>% html_attr("href")
  
  # Add unique URLs to the list
  urls <- unique(c(urls, page_urls))
  
  # Click the "Show More" button
  elem <- remDr$findElement("css selector", ".search-pagination__next-page")
  elem$clickElement()
  Sys.sleep(5)
  
  # Increment the page number
  page <- page + 1
  
  #
  
  # Check if there are no more search results or maximum pages reached
  if (length(page_urls) == 0 || page >= max_pages) {
    cat("No more search results or reached maximum pages. Total URLs scraped:", length(urls), "\n")
    break
  }
}

# Close the Selenium browser
remDr$close()
selServ$server$stop()

# Print the URLs
cat("Scraped URLs:\n")
cat(urls, sep = "\n")

##########################################################################CS URLS
#####batch 1:2022-10-30 to 2023-06-30, 38 pages
### urls <- as.matrix(read.csv("~/Masterarbeit/FT scraper/FT_scraped_urls_CS_batch1.csv", header = TRUE))
# FT_scraped_urls_CS_batch1 <- urls
# output_file_urls <- "~/Masterarbeit/FT scraper/FT_scraped_urls_CS_batch1.csv"
# write.csv(FT_scraped_urls_CS_batch1, file = output_file_urls, row.names = FALSE, col.names = c("URL"))



# batch 2: 2021-04-30 to 2022-10-29, 36 pages
###urls <- as.matrix(read.csv("~/Masterarbeit/FT scraper/FT_scraped_urls_CS_batch2.csv", header = TRUE))
# FT_scraped_urls_CS_batch2 <- urls
# output_file_urls <- "~/Masterarbeit/FT scraper/FT_scraped_urls_CS_batch2.csv"
# write.csv(FT_scraped_urls_CS_batch2, file = output_file_urls, row.names = FALSE, col.names = c("URL"))

# batch 3: 2019-10-30 to 2021-04-29, 39 pages
# FT_scraped_urls_CS_batch3 <- urls
# output_file_urls <- "~/Masterarbeit/FT scraper/FT_scraped_urls_CS_batch3.csv"
# write.csv(FT_scraped_urls_CS_batch3, file = output_file_urls, row.names = FALSE, col.names = c("URL"))

# batch 4: 2019-01-01 to 2019-10-29, 22 pages
# 
# FT_scraped_urls_CS_batch4 <- urls
# output_file_urls <- "~/Masterarbeit/FT scraper/FT_scraped_urls_CS_batch4.csv"
# write.csv(FT_scraped_urls_CS_batch4, file = output_file_urls, row.names = FALSE, col.names = c("URL"))


##########################################################################UBS URLS
#####batch 1:2022-10-30 to 2023-06-30, 24 pages
### urls <- as.matrix(read.csv("~/Masterarbeit/FT scraper/FT_scraped_urls_CS_batch1.csv", header = TRUE))
# FT_scraped_urls_UBS_batch1 <- urls
# output_file_urls <- "~/Masterarbeit/FT scraper/FT_scraped_urls_UBS_batch1.csv"
# write.csv(FT_scraped_urls_UBS_batch1, file = output_file_urls, row.names = FALSE, col.names = c("URL"))

# batch 2: 2021-04-30 to 2022-10-29, 30 pages
###urls <- as.matrix(read.csv("~/Masterarbeit/FT scraper/FT_scraped_urls_CS_batch2.csv", header = TRUE))
# FT_scraped_urls_UBS_batch2 <- urls
# output_file_urls <- "~/Masterarbeit/FT scraper/FT_scraped_urls_UBS_batch2.csv"
# write.csv(FT_scraped_urls_UBS_batch2, file = output_file_urls, row.names = FALSE, col.names = c("URL"))

# batch 3: 2019-12-30 to 2021-04-29, 39 pages
# FT_scraped_urls_UBS_batch3 <- urls
# output_file_urls <- "~/Masterarbeit/FT scraper/FT_scraped_urls_UBS_batch3.csv"
# write.csv(FT_scraped_urls_UBS_batch3, file = output_file_urls, row.names = FALSE, col.names = c("URL"))

# batch 4: 2019-01-01 to 2019-12-29, 39 pages
# 
# FT_scraped_urls_UBS_batch4 <- urls
# output_file_urls <- "~/Masterarbeit/FT scraper/FT_scraped_urls_UBS_batch4.csv"
# write.csv(FT_scraped_urls_UBS_batch4, file = output_file_urls, row.names = FALSE, col.names = c("URL"))

#https://www.ft.com/search?q=UBS&dateTo=2023-06-30&dateFrom=2022-10-30&sort=relevance&expandRefinements=true&isFirstView=false

####################################################################
####################################################################
#SCRAPING LOOP
######################################################################
#####################################################################
#read in urls

urls <- FT_scraped_urls_UBS_batch4

fixed_urls <- sub("^/", "https://www.ft.com/", urls)
urls <- fixed_urls

# List of URLs to scrape
url_list <- urls  # Replace with your actual URLs

# #get article title
#     title_text <- html %>%
#       html_nodes(".article-classifier__gap") %>% html_text()
#     
#     
#     #get article date
#     text_date <- html %>%
#       html_node(".article-info__time-byline time") %>%  # Select the time element within the specified class
#       html_attr("datetime") %>%                     # Extract the 'datetime' attribute
#       as.character() %>%                            # Convert to character
#       str_extract("\\d{4}-\\d{2}-\\d{2}") %>%      # Extract date part
#       as.Date() %>%                                 # Convert to Date object
#       format("%d.%m.%Y")
#     
#     #get headlinetext
#     headline_lead_text <- html %>% 
#       html_node(".o-topper__standfirst") %>%     # Select the p element with the class "headline__lead"
#       html_text()
#     
#     
#     
#     #get article content
#     article_content <- html %>%
#       html_nodes(".n-content-body > :not(aside)") %>%
#       html_text() %>% paste(collapse = " ")
   
# Create an empty dataframe to store the scraped content
scraped_data <- data.frame(article_title = character(),
                           headline = character(),
                           article_content = character(),
                           text_date = character(),
                           stringsAsFactors = FALSE)
    
    
# Loop through each URL and scrape the desired content

articles_scraped <- 0  # Initialize a counter for scraped articles

for (url in url_list) {
  tryCatch({
    # Print URL being scraped
    cat("Scraping URL:", url, "\n")
    
    # Perform scraping and extract info
    Sys.sleep(sample(1:2, 1))
    remDr$navigate(url)
    Sys.sleep(sample(1:2, 1))
    html <- remDr$getPageSource()[[1]]
    html <- read_html(html)
    
    # Get article title
    article_title <- html %>%
      html_nodes(".article-classifier__gap") %>% 
      html_text()
    
    # Get article date
    text_date <- html %>%
      html_node(".article-info__time-byline time") %>% 
      html_attr("datetime") %>%                     
      as.character() %>%                            
      str_extract("\\d{4}-\\d{2}-\\d{2}") %>%      
      as.Date() %>%                                 
      format("%d.%m.%Y")
    
    # Get headline text
    headline <- html %>% 
      html_node(".o-topper__standfirst") %>%     
      html_text()
    
    # Get article content
    article_content <- html %>%
      html_nodes(".n-content-body > :not(aside)") %>%
      html_text() %>% paste(collapse = " ")
    
    # Check if all required elements have valid values
    if (length(article_title) > 0 && length(text_date) > 0 && nchar(article_content) > 0 && nchar(headline) > 0 ) {
      # Add the scraped content to the dataframe
      scraped_data <- bind_rows(scraped_data, data.frame(article_title, headline, article_content, text_date, stringsAsFactors = FALSE))
      articles_scraped <- articles_scraped + 1  # Increment the counter
      cat(articles_scraped, "article(s) scraped\n")  # Print the number of articles scraped
    }
    # Introduce a random sleep time between 1 and 2 seconds
    Sys.sleep(sample(1:2, 1))
  }, error = function(e) {
    # Handle errors gracefully (e.g., print a message and continue)
    cat("Error while scraping URL:", url, "\n")
  })
}


# Print the scraped data
print(scraped_data[1,1])

FT_data_UBS_batch4 <- scraped_data
output_file <- "~/Masterarbeit/FT scraper/FT_data_UBS_batch4.csv"
write.csv(FT_data_UBS_batch4, file = output_file, row.names = FALSE)






# Close the browser and stop the Selenium server
remDr$close()
selServ$server$stop()

