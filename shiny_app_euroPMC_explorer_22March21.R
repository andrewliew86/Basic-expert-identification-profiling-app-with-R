library(europepmc)
library(tidyr)
library(tidyverse)
library(ggplot2)
library(stringr)
library(shiny)
library(shinybusy)
# #query <- 'tenapanor'
# 
# #df <- europepmc::epmc_search(query = 'tenapanor', limit = 5000, synonym = TRUE)
# 
# # # TOp 10 most frequent journal pubs
# # journal <- df %>% 
# #   group_by(journalTitle) %>%
# #   summarise(count = n()) %>%
# #   drop_na(journalTitle) %>%
# #   top_n(n = 10, wt = count)
# # 
# # # Plot the 'journal' dataframe
# # ggplot(journal, aes(x = count, y = journalTitle)) +
# #          geom_col() +
# #   xlab("Count") +
# #   ylab("Journal") +
# #   ggtitle("Top 10 journals")
# 
# # Publications over time
# # First change the pubYear to numeric so that we can use a lineplot!
# df$pubYear <- as.numeric(df$pubYear)
# df %>% 
#   group_by(pubYear) %>%
#   summarise(count = n()) %>%
#   drop_na(pubYear) %>%
#   ggplot(aes(x = pubYear, y = count)) +
#   geom_point() +
#   geom_line() +
#   xlab("Year") + 
#   ylab("Count") +
#   ggtitle("Number of publications over time")
# 
# 
# # Top authors in the field 
# author_vec <- df %>% 
#   drop_na(authorString) %>%
#   # Create a new column called converted where each row is a vector of individual author names
#   mutate(converted = lapply(strsplit(authorString, ",", TRUE), as.vector))
# 
# # Extract all the individual names from the author column and count the occurances of each author
# my_list1 <- list(author_vec$converted) # turn the dataframe column into a list
# vec <- Reduce(c,my_list1)  # reduce lists into a single list of vectors
# vec <- unlist(vec) # turn list into a vector
# # Trim whitespace from each vector element and replace all '.' with ''
# vec_strp <-  trimws(vec) %>%
#   str_replace_all("\\.", "")
# 
# # Count the occurances of the individual authors and place those numbers in a dataframe
# author_df <- as.data.frame(table(vec_strp))
# # Plot the top 10 authors 
# author_df %>% 
#   top_n(n = 10, wt = Freq) %>%
#   ggplot(aes(x=Freq, y=vec_strp)) +
#   geom_col() +
#   xlab("Count") + 
#   ylab("Author") +
#   ggtitle("Top 10 authors")


# Lets build the shiny app

ui <- fluidPage(
  # Add in a spinner to show progress
  add_busy_spinner(spin = "fading-circle"),
  # Add a title to the app
  titlePanel("EuropePMC explorer"),
  # Add a text input (assign  as 'keyword' variable) in the sidebar that allows user to search using keyword of interest, note that the default here is tenapanor
  textInput('keyword', 'Enter keyword or author name', 'tenapanor'),
  # Add instructions for the app using a 'p' tag
  # Add the plots: top 10 journals, top 10 authors and publications over time
  mainPanel(actionButton("go", "Search"),
            p("EuropePMC explorer allows you to get an overview of the scientific literature of a field (e.g. top journals, publishers in the field) using the EuropePMC API"),
            p("Type a keyword (or author name) in the text box above and click the search button.Wait for publication download to be completed (it might take 60-90 seconds!) and a series of charts to appear. The charts show the top 10 journals, top 10 authors and number of publications (over time) associated with the keyword. Note that the maximum number of publications is 5000"),
            fluidRow(
    splitLayout(
            plotOutput('journal_plot', width = "100%"),
            plotOutput('author_plot', width = "100%"),
            plotOutput('time_plot', width = "100%")
            ))))


# Create the server side
server <- function(input, output, session) {
  # Create a dataframe (df) that will contain the results of your query to the EuropePMC API. This will be a 'global' variable
  df <- eventReactive(input$go, europepmc::epmc_search(query = input$keyword, limit = 5000, synonym = TRUE))
  # Note that the 'input$keyword' refers to the input variable entered by the user
  # eventReactive means that the API will only be called when we hit the search button (see UI section)
  output$journal_plot <- renderPlot({
    # Count the top publishing journals in the field
    # We summarize by determining the counts for each journal title
    # Note that 'df()' is used instead of 'df'. Because df above is reactive (i.e) it accepts user input, you need to add the paranthesis. See here: https://stackoverflow.com/questions/26454609/r-shiny-reactive-error
    journal <- df() %>%
      group_by(journalTitle) %>%
      summarise(count = n()) %>%
      # drop_na removes journals that have no recorded titles
      drop_na(journalTitle) %>%
      top_n(n = 10, wt = count)
    # Plot the 'journal' dataframe (top 10 journals)
    # the y = reorder is used to plot the journal titles in order of decreasing count
      ggplot(journal, aes(x = count, y = reorder(journalTitle, count))) +
      geom_col() +
      xlab("Count") +
      ylab("Journal") +
      ggtitle("Top 10 journals")
  })
  
  # Count the top 10 authors in the field 
  output$author_plot <- renderPlot({
    author_vec <- df() %>% 
    drop_na(authorString) %>%
    # Create a new column called converted where each row is a vector of individual author names
    mutate(converted = lapply(strsplit(authorString, ",", TRUE), as.vector))
  
  # Extract all the individual names from the author column and count the occurances of each author
  my_list1 <- list(author_vec$converted) # turn the dataframe column into a list
  vec <- Reduce(c,my_list1)  # reduce lists into a single list of vectors
  vec <- unlist(vec) # turn list into a vector
  # Trim whitespace from each vector element and replace all '.' with ''
  vec_strp <-  trimws(vec) %>%
    str_replace_all("\\.", "")
  
  # Count the occurances of the individual authors and place those numbers in a dataframe
  author_df <- as.data.frame(table(vec_strp))
  # Plot the top 10 authors dataframe
  author_df %>% 
    top_n(n = 10, wt = Freq) %>%
    ggplot(aes(x=Freq,  y = reorder(vec_strp, Freq))) +
    geom_col() +
    xlab("Count") + 
    ylab("Author") +
    ggtitle("Top 10 authors")
  })
  
  # Publications over time plot
  output$time_plot <- renderPlot({
  df() %>% 
    # First change the pubYear to numeric so that we can plot a lineplot!
    mutate(pubYear = as.numeric(pubYear)) %>%
  # groupby year and then summarize with counts of the number of publications
    group_by(pubYear) %>%
    summarise(count = n()) %>%
    drop_na(pubYear) %>%
    ggplot(aes(x = pubYear, y = count)) +
    geom_point() +
    geom_line() +
    xlab("Year") + 
    ylab("Count") +
    ggtitle("Number of publications over time")
    })
}

shinyApp(ui = ui, server = server)

