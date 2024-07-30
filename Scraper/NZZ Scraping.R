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

##################
# nzz anmeldedaten
# adywy@gmx.ch
#pw: Cholmoos5610

#Setup Selenium Server
selServ <- rsDriver(port = 4568L , browser = c("firefox"), chromever = NULL)



# Connect to the remote driver
remDr <- selServ$client
remDr$navigate("https://www.nzz.ch/wirtschaft/die-razzia-in-den-niederlanden-ratlose-credit-suisse-ld.155649")


# Extract the dynamically generated URL
dynamic_url <- remDr$getCurrentUrl()
dynamic_url


response_content <- remDr$getPageSource()[[1]]
response_content


links <- read_html(response_content) %>% html_nodes("a.teaser__link")
links

# Extract the URLs from the href attribute of the selected <a> tags
urls <- links %>% html_attr("href")
urls

#remove duplicates 
urls_unique <- unique(urls)
urls_unique


#show more bar to get further search results
elem <- remDr$findElement(
  "css selector", 
  ".button--loadmore"
)


elem$clickElement()
Sys.sleep(2)








#################################################################################################################### get all URLs




# Initialize variables
urls <- c()
max_pages <- 450  #750 for CS, "300" for "UBS"
search_query <- "UBS"
# Construct the search URL
search_url <- paste0("https://www.nzz.ch/suche?q=", search_query, "&filter=none")

# Navigate to the initial search URL
remDr$navigate(search_url)
Sys.sleep(sample(1:2, 1))

# Loop until the maximum number of pages is reached
for (page in 1:max_pages) {
  # Extract the URLs from the current page
  response_content <- remDr$getPageSource()[[1]]
  links <- read_html(response_content) %>% html_nodes("a.teaser__link")
  page_urls <- links %>% html_attr("href")
  
  # Add unique URLs to the list
  urls <- unique(c(urls, page_urls))
  
  # Check if there's a "Load More" button on the page
  elem <- remDr$findElement(using = "css selector", value = ".button--loadmore")
  
  if (!is.null(elem)) {
    # Click the "Load More" button
    elem$clickElement()
    Sys.sleep(sample(1:2, 1))  # Wait for the new content to load
  } else {
    cat("No more 'Load More' button found. Total URLs scraped:", length(urls), "\n")
    break
  }
}





#############################################3
# Close the Selenium browser
remDr$close()
selServ$server$stop()

# Print the URLs
cat("Scraped URLs:\n")
cat(urls, sep = "\n")


# scraped_urls_4k_UBS_april <- urls
# output_file_urls <- "~/Masterarbeit/nzz scraper/scraped_urls_4k_UBS_april.csv"
# write.csv(scraped_urls_4k_UBS_april, file = output_file_urls, row.names = FALSE, col.names = c("URL"))



#################################################################################### article 1
remDr$navigate("https://www.nzz.ch/wirtschaft/die-razzia-in-den-niederlanden-ratlose-credit-suisse-ld.155649")
html <- remDr$getPageSource()[[1]]
html <- read_html(html)

#get article title
title_text <- html %>%
  html_nodes(".headline__title") %>% html_text()
title_text

#get article date
text_date <- html %>%
  html_node(".metainfo__item--date time") %>%  # Select the time element within the specified class
  html_attr("datetime") %>%                     # Extract the 'datetime' attribute
  as.character() %>%                            # Convert to character
  str_extract("\\d{4}-\\d{2}-\\d{2}") %>%      # Extract date part
  as.Date() %>%                                 # Convert to Date object
  format("%d.%m.%Y")     

#get headlinetext
headline_lead_text <- html %>% 
  html_node(".headline__lead") %>%     # Select the p element with the class "headline__lead"
  html_text()
headline_lead_text


#get article content
article_content <- html %>%
  html_nodes(".articlecomponent.text") %>%
  html_text() %>% paste(collapse = " ")
article_content










####################################################################
####################################################################
#SCRAPING LOOP
######################################################################
#####################################################################
write.table(urls,"~/Masterarbeit/nzz scraper/urls_4k_UBS_april.txt")
fixed_urls <- sub("^/", "https://www.nzz.ch/", urls)
write.table(fixed_urls,"~/Masterarbeit/nzz scraper/fixed_urls_4k_UBS_april.txt")



urls <- as.matrix(read.table("~/Masterarbeit/nzz scraper/urls_4k_UBS_april.txt", header = TRUE))
fixed_urls <- sub("^/", "https://www.nzz.ch/", urls)

url_list <- fixed_urls

# List of URLs to scrape

#ubs part1
#url_list <- fixed_urls[651:2100]

#ubs part2
url_list <- fixed_urls[2101:3601]

#url_list <- fixed_urls[1:250]  
#url_list <- fixed_urls[251:500]
#url_list <- fixed_urls[501:750]
#url_list <- fixed_urls[751:1250]
#url_list <- fixed_urls[1251:1750]

# Create an empty dataframe to store the scraped content
scraped_data <- data.frame(article_title = character(),
                           headline = character(),
                           article_content = character(),
                           text_date = character(),
                           stringsAsFactors = FALSE)


articles_scraped <- 0  # Initialize a counter for scraped articles

for (url in url_list) {
  tryCatch({
    # Perform scraping and extract article title, merged string, and text date
    # Modify the scraping code based on the structure of the website you are scraping
    # Replace the placeholders with the actual code for scraping each element
    
    Sys.sleep(sample(1:2, 1))
    remDr$navigate(url)
    Sys.sleep(sample(1:2, 1))
    html <- remDr$getPageSource()[[1]]
    html <- read_html(html)
    
    article_title <- html %>%
      html_nodes(".headline__title") %>% html_text()
    
    text_date <- html %>%
      html_node(".metainfo__item--date time") %>%  # Select the time element within the specified class
      html_attr("datetime") %>%                     # Extract the 'datetime' attribute
      as.character() %>%                            # Convert to character
      str_extract("\\d{4}-\\d{2}-\\d{2}") %>%      # Extract date part
      as.Date() %>%                                 # Convert to Date object
      format("%d.%m.%Y")   
    
    headline <- html %>% 
      html_node(".headline__lead") %>%     # Select the p element with the class "headline__lead"
      html_text()
    
    article_content <- html %>%
      html_nodes(".articlecomponent.text") %>%
      html_text() %>% paste(collapse = " ")
    
    # Check if all required elements have valid values
    if (length(article_title) > 0 && length(text_date) > 0 && nchar(article_content) > 0 && nchar(headline) > 0) {
      # Add the scraped content to the dataframe
      scraped_data <- rbind(scraped_data, data.frame(article_title, headline, article_content, text_date, stringsAsFactors = FALSE))
      articles_scraped <- articles_scraped + 1  # Increment the counter
      cat(articles_scraped, "article(s) scraped\n")  # Print the number of articles scraped
    }
  }, error = function(e) {
    # Handle errors gracefully (e.g., print a message and continue)
    cat("Error while scraping URL:", url, "\n")
  })
}

##################################################################### old loop without error
####################################3
##########################################################33


for (url in url_list) {
  # Perform scraping and extract article title, merged string, and text date
  # Modify the scraping code based on the structure of the website you are scraping
  # Replace the placeholders with the actual code for scraping each element
  
  Sys.sleep(sample(1:2, 1))
  remDr$navigate(url)
  Sys.sleep(sample(1:2, 1))
  html <- remDr$getPageSource()[[1]]
  html <- read_html(html)
  
  article_title <- html %>%
    html_nodes(".headline__title") %>% html_text()
  
  text_date <- html %>%
    html_nodes(".metainfo__item--date")%>% 
    html_nodes("time") %>%     # Select all time elements
    first() %>%                # Select the first time element
    html_attr("datetime") %>% as.character() %>%
    str_extract("\\d{4}-\\d{2}-\\d{2}") %>% as.Date() %>%
    format("%d.%m.%Y")
  
  headline <- html %>% 
    html_node(".headline__lead") %>%     # Select the p element with the class "headline__lead"
    html_text()
  
  article_content <- html %>%
    html_nodes(".articlecomponent.text") %>%
    html_text() %>% paste(collapse = " ")
  
  
 
  
  
  
  
  # Check if all required elements have valid values
  if (length(article_title) > 0 && length(text_date) > 0 && nchar(article_content) > 0 && nchar(headline) > 0) {
    # Add the scraped content to the dataframe
    scraped_data <- rbind(scraped_data, data.frame(article_title, headline, article_content, text_date, stringsAsFactors = FALSE))
  }
}

###################################################################################333
######################################################################################
#####################################################################################33


# Print the scraped data
print(scraped_data[1299,3])

# 
# nzz_scraped_data_CS_april_part1 <- scraped_data
# output_file1 <- "~/Masterarbeit/nzz scraper/nzz_scraped_data_CS_april_part1.csv"
# write.csv(nzz_scraped_data_CS_april_part1, file = output_file1, row.names = FALSE)


# nzz_scraped_data_CS_april_part2 <- scraped_data
# output_file2 <- "~/Masterarbeit/nzz scraper/nzz_scraped_data_CS_april_part2.csv"
# write.csv(nzz_scraped_data_CS_april_part2, file = output_file2, row.names = FALSE)

# nzz_scraped_data_CS_april_part3 <- scraped_data
# output_file3 <- "~/Masterarbeit/nzz scraper/nzz_scraped_data_CS_april_part3.csv"
# write.csv(nzz_scraped_data_CS_april_part3, file = output_file3, row.names = FALSE)

scraped_data[1,1]
####500
# scraped_data[444,3]
# nzz_scraped_data_CS_april_part4 <- scraped_data
# output_file4 <- "~/Masterarbeit/nzz scraper/nzz_scraped_data_CS_april_part4.csv"
# write.csv(nzz_scraped_data_CS_april_part4, file = output_file4, row.names = FALSE)

#####500
# nzz_scraped_data_CS_april_part5 <- scraped_data
# output_file5 <- "~/Masterarbeit/nzz scraper/nzz_scraped_data_CS_april_part5.csv"
# write.csv(nzz_scraped_data_CS_april_part5, file = output_file5, row.names = FALSE)


###################################################################################333
######################################################################################
#####################################################################################33


# nzz_scraped_data_part2 <- scraped_data
# output_file2 <- "~/MA/nzz scraper/nzz_scraped_data_part2.csv"
# write.csv(nzz_scraped_data_part2, file = output_file2, row.names = FALSE)
# 
# nzz_scraped_data_part3 <- scraped_data
# output_file3 <- "~/MA/nzz scraper/nzz_scraped_data_part3.csv"
# write.csv(nzz_scraped_data_part3, file = output_file3, row.names = FALSE)
# 
# nzz_scraped_data_part4 <- scraped_data
# output_file4 <- "~/MA/nzz scraper/nzz_scraped_data_part4.csv"
# write.csv(nzz_scraped_data_part4, file = output_file4, row.names = FALSE)




nzz_scraped_data_UBS_part1 <- scraped_data
output_file_UBS_1 <- "~/Masterarbeit/nzz scraper/nzz_scraped_data_UBS_part1.csv"
write.csv(nzz_scraped_data_UBS_part1, file = output_file_UBS_1, row.names = FALSE)


nzz_scraped_data_UBS_part2 <- scraped_data
output_file_UBS_2 <- "~/Masterarbeit/nzz scraper/nzz_scraped_data_UBS_part2.csv"
write.csv(nzz_scraped_data_UBS_part2, file = output_file_UBS_2, row.names = FALSE)
nzz_scraped_data_UBS_part2[1303,3]

# Close the browser and stop the Selenium server
remDr$close()
selServ$server$stop()





urls

####################################################################33

#failed urls: 
# Error while processing URL: https://www.srf.ch/news/infografik/die-credit-suisse-unter-brady-dougan 
# Error while processing URL: https://www.srf.ch/sport/mehr-sport/sports-awards/sports-awards-impressionen-von-den-creditsuissesportsawards 
# Error while processing URL: https://www.srf.ch/news/infografik/die-schweizer-grossbanken-im-vergleich 
# Error while processing URL: https://www.srf.ch/sendungen/glanz-und-gloria/international-bryan-adams-die-schweizer-sind-toll 
# Error while processing URL: https://www.srf.ch/news/wirtschaft/wirtschaft-keine-gnade-fuer-die-cs-im-netz 
# Error while processing URL: https://www.srf.ch/sport/mehr-sport/sports-awards/sports-awards-die-besten-impressionen-der-sportsawards-2015 
# Error while processing URL: https://www.srf.ch/news/infografik/die-schweizer-grossbanken-im-vergleich-2 
# Error while processing URL: https://www.srf.ch/sendungen/glanz-und-gloria/schweiz-hochs-und-tiefs-das-waren-die-groessten-sport-emotionen-2015 
# Error while processing URL: https://www.srf.ch/news/wirtschaft/finanzplatz-zuerich-versicherungen-laufen-den-banken-den-rang-ab 
# Error while processing URL: https://www.srf.ch/news/wirtschaft/too-big-to-fail-nicht-alle-schweizer-banken-sind-offiziell-krisensicher 
# Error while processing URL: https://www.srf.ch/news/wirtschaft/nach-flash-crash-wall-street-erholt-sich-smi-baut-verluste-aus 
####################################################################################################3



# [1] "https://www.srf.ch/news/schweiz/credit-suisse-die-puk-kommt-aber-wie-viel-biss-wird-sie-haben"                                                 
# [2] "https://www.srf.ch/news/wirtschaft/cs-krise-auch-buero-des-staenderats-stimmt-puk-zur-credit-suisse-zu"                                        
# [3] "https://www.srf.ch/news/wirtschaft/uebernahme-der-credit-suisse-ubs-wird-dank-cs-uebernahme-rekordgewinn-erzielen"                             
# [4] "https://www.srf.ch/news/wirtschaft/uebernahme-der-credit-suisse-kommission-des-staenderats-empfiehlt-puk"                                      
# [5] "https://www.srf.ch/news/wirtschaft/cs-uebernahme-durch-ubs-ubs-will-kauf-der-credit-suisse-bis-anfang-juni-abschliessen"                       
# [6] "https://www.srf.ch/news/wirtschaft/nach-cs-uebernahme-durch-ubs-die-patientin-credit-suisse-liegt-nach-wie-vor-im-spital"                      
# [7] "https://www.srf.ch/news/wirtschaft/nach-cs-uebernahme-durch-ubs-credit-suisse-weist-geldabfluesse-von-61-milliarden-franken-aus"               
# [8] "https://www.srf.ch/news/schweiz/ausserordentliche-session-leere-drohungen-der-parteien-im-fall-credit-suisse"                                  
# [9] "https://www.srf.ch/news/wirtschaft/nach-rettung-der-credit-suisse-notfallplan-von-postfinance-und-zkb-laut-finma-nicht-umsetzbar"              
# [10] "https://www.srf.ch/news/wirtschaft/nach-rettung-der-credit-suisse-bundesrat-streicht-cs-kadern-die-boni-die-wichtigsten-antworten"             
# [11] "https://www.srf.ch/news/wirtschaft/credit-suisse-vor-uebernahme-das-war-die-letzte-generalversammlung-der-credit-suisse"                       
# [12] "https://www.srf.ch/news/wirtschaft/diskussion-ueber-cs-uebernahme-finanzkommissionen-beider-raete-fordern-analyse-bei-credit-suisse"           
# [13] "https://www.srf.ch/news/schweiz/praemie-fuer-ausfallgarantien-so-viel-verdient-der-bund-an-den-garantien-fuer-die-credit-suisse"               
# [14] "https://www.srf.ch/wissen/mensch/nach-dem-aus-der-credit-suisse-was-das-vertrauen-in-banken-mit-einer-liebesbeziehung-zu-tun-hat"              
# [15] "https://www.srf.ch/news/schweiz/uebernahme-der-credit-suisse-nationalratsbuero-will-cs-uebernahme-untersuchen-lassen"                          
# [16] "https://www.srf.ch/sendungen/school/fruehling-und-cs-uebernahme-tierischer-fruehlingsstart-und-credit-suisse-debakel"                          
# [17] "https://www.srf.ch/news/schweiz/cs-uebernahme-durch-ubs-die-credit-suisse-soll-doch-nicht-ganz-sterben"                                        
# [18] "https://www.srf.ch/news/wirtschaft/uebernahme-der-credit-suisse-bund-stoppt-auszahlung-gewisser-cs-boni-das-muessen-sie-wissen"                
# [19] "https://www.srf.ch/kids/eltern/fuer-kinder-erklaert-credit-suisse-was-passiert-da-gerade"                                                      
# [20] "https://www.srf.ch/sendungen/school/eine-bank-geht-unter-credit-suisse-was-ist-da-los"                                                         
# [21] "https://www.srf.ch/kultur/gesellschaft-religion/cs-uebernahme-durch-die-ubs-grosse-kulturhaeuser-bangen-um-sponsoring-gelder-der-credit-suisse"
# [22] "https://www.srf.ch/news/wirtschaft/cs-uebernahme-durch-die-ubs-so-hat-die-credit-suisse-das-vertrauen-der-kunden-verloren"                     
# [23] "https://www.srf.ch/news/wirtschaft/cs-uebernahme-durch-die-ubs-167-jahre-credit-suisse-das-ende-einer-traditionsbank"                          
# [24] "https://www.srf.ch/news/wirtschaft/cs-uebernahme-durch-die-ubs-ubs-uebernimmt-credit-suisse-die-wichtigsten-punkte"                            
# [25] "https://www.srf.ch/news/wirtschaft/krise-bei-der-credit-suisse-credit-suisse-die-ereignisse-der-letzten-tage-im-ueberblick"                    
# [26] "https://www.srf.ch/news/wirtschaft/krise-bei-der-credit-suisse-reto-lipp-es-zeichnet-sich-ein-erdbeben-auf-dem-finanzplatz-ab"                 
# [27] "https://www.srf.ch/news/wirtschaft/krise-bei-der-credit-suisse-ubs-und-cs-zwei-unterschiedliche-bankenschwergewichte"                          
# [28] "https://www.srf.ch/news/wirtschaft/cs-krise-medienberichte-ubs-fuehrt-uebernahme-gespraeche-mit-credit-suisse"                                 
# [29] "https://www.srf.ch/news/wirtschaft/angeschlagene-credit-suisse-cs-aktie-beendet-die-woche-unter-zwei-franken"                                  
# [30] "https://www.srf.ch/news/wirtschaft/krise-bei-der-credit-suisse-wie-die-cs-das-vertrauen-der-kunden-zurueckgewinnen-kann"                       
# [31] "https://www.srf.ch/news/wirtschaft/snb-kredit-fuer-credit-suisse-schweiz-chef-der-cs-klar-50-milliarden-ist-eine-grosse-zahl"                  
# [32] "https://www.srf.ch/kultur/gesellschaft-religion/strauchelnde-credit-suisse-wie-es-in-der-geschichte-zu-bank-runs-kam"                          
# [33] "https://www.srf.ch/news/wirtschaft/hilfe-fuer-grossbank-der-fall-credit-suisse-und-die-vertrauenskrise-ein-ueberblick"                         
# [34] "https://www.srf.ch/news/schweiz/credit-suisse-in-schieflage-die-sorgenfalten-werden-auch-in-der-zuercher-politik-groesser"                     
# [35] "https://www.srf.ch/news/wirtschaft/rettung-der-grossbank-credit-suisse-muss-jetzt-transparenz-schaffen"                                        
# [36] "https://www.srf.ch/news/wirtschaft/kredit-fuer-die-credit-suisse-fall-cs-politiker-fordern-transparenz-ueber-snb-rettungsaktion"               
# [37] "https://www.srf.ch/news/wirtschaft/hilfe-fuer-credit-suisse-kann-die-nationalbank-die-cs-vertrauenskrise-stoppen-1"                            
# [38] "https://www.srf.ch/news/wirtschaft/hilfe-fuer-credit-suisse-cs-aktie-hat-sich-kraeftig-erholt-snb-stuetzt-mit-50-milliarden"                   
# [39] "https://www.srf.ch/news/wirtschaft/historischer-kurssturz-snb-sichert-credit-suisse-im-bedarfsfall-liquiditaetshilfe-zu"                       
# [40] "https://www.srf.ch/news/wirtschaft/angezaehlte-grossbank-was-die-credit-suisse-zu-fall-bringen-wuerde"                                         
# [41] "https://www.srf.ch/news/wirtschaft/cs-aktie-im-freien-fall-aktie-der-credit-suisse-stuerzt-kurzzeitig-um-15-prozent-ab"                        
# [42] "https://www.srf.ch/news/wirtschaft/wegen-us-boersenaufsicht-credit-suisse-vertagt-veroeffentlichung-des-geschaeftsberichts"                    
# [43] "https://www.srf.ch/news/wirtschaft/ruege-im-fall-greensill-die-credit-suisse-hat-ein-gravierendes-vertrauensproblem"                           
# [44] "https://www.srf.ch/news/wirtschaft/probleme-mit-greensill-fonds-finma-stellt-bei-der-credit-suisse-schwere-maengel-fest"                       
# [45] "https://www.srf.ch/news/schweiz/datenklau-bei-bank-ex-mitarbeiter-stiehlt-personaldaten-von-credit-suisse"                                     
# [46] "https://www.srf.ch/news/wirtschaft/grossbank-in-der-krise-credit-suisse-schreibt-jahresverlust-von-7-3-milliarden"                             
# [47] "https://www.srf.ch/news/wirtschaft/cs-gegen-inside-paradeplatz-credit-suisse-verklagt-finanzblog-inside-paradeplatz"                           
# [48] "https://www.srf.ch/news/wirtschaft/kapital-fuer-credit-suisse-cs-aktionaere-zeichnen-neue-aktien-ueber-zwei-milliarden-franken"                
# [49] "https://www.srf.ch/news/wirtschaft/krise-bei-der-credit-suisse-axel-lehmann-wir-haben-einige-sehr-gute-mitarbeiter-verloren"                   
# [50] "https://www.srf.ch/news/wirtschaft/neues-geld-neue-verluste-das-bluten-der-credit-suisse-dauert-an"                                            
# [51] "https://www.srf.ch/news/wirtschaft/massive-abfluesse-credit-suisse-verkuendet-quartalsverlust-und-kapitalerhoehung"                            
# [52] "https://www.srf.ch/news/schweiz/sitzblockade-vor-credit-suisse-zuercher-gericht-erhoeht-strafe-fuer-klima-protest"                             
# [53] "https://www.srf.ch/news/wirtschaft/stellenabbau-bei-der-cs-credit-suisse-schliesst-in-der-schweiz-14-von-109-filialen"                         
# [54] "https://www.srf.ch/news/wirtschaft/credit-suisse-und-die-saudis-auf-moralische-themen-sind-unternehmen-oft-schlecht-vorbereitet"               
# [55] "https://www.srf.ch/news/wirtschaft/krise-bei-der-credit-suisse-schmerzt-sie-der-verlust-der-schweizer-banken-jobs-herr-rohner"                 
# [56] "https://www.srf.ch/news/wirtschaft/krisen-bank-im-umbau-credit-suisse-streicht-bis-jahresende-540-schweizer-stellen"                           
# [57] "https://www.srf.ch/news/wirtschaft/beispiel-credit-suisse-mitarbeitende-leiden-bei-schlechten-nachrichten-mit"                                 
# [58] "https://www.srf.ch/news/wirtschaft/finanzhilfe-aus-nahost-die-credit-suisse-und-das-geld-aus-saudi-arabien"                                    
# [59] "https://www.srf.ch/news/wirtschaft/neue-strategie-der-cs-die-credit-suisse-versucht-den-befreiungsschlag"                                      
# [60] "https://www.srf.ch/news/wirtschaft/nach-massivem-quartalsverlust-so-will-die-credit-suisse-aus-der-krise-finden"

scraped_data_1000[20,2]
