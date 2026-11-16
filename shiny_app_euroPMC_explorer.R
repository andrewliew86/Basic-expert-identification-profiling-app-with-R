library(europepmc)
library(tidyr)
library(tidyverse)
library(ggplot2)
library(stringr)
library(shiny)
library(shinybusy)

# Create a Shiny app that displays top journals, authors, and publication counts.
ui <- fluidPage(
  tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$style(HTML("
      body {
        background: #f3f6fa;
        color: #172b4d;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      }
      .container-fluid { max-width: 1440px; padding: 28px 32px 40px; }
      .app-header {
        background: linear-gradient(120deg, #102d4f, #176b87);
        border-radius: 14px;
        color: #fff;
        margin-bottom: 24px;
        padding: 26px 32px;
      }
      .app-header h1 { font-size: 30px; font-weight: 700; margin: 0 0 7px; }
      .app-header p { color: #d7e8f1; font-size: 15px; margin: 0; }
      .search-panel, .content-intro, .chart-card {
        background: #fff;
        border: 1px solid #e3eaf1;
        border-radius: 12px;
        box-shadow: 0 3px 12px rgba(24, 49, 79, .05);
      }
      .row > .col-sm-3 > .well {
        background: transparent;
        border: 0;
        box-shadow: none;
        padding: 0;
      }
      .search-panel { padding: 22px; }
      .search-panel h3 { font-size: 18px; font-weight: 650; margin: 0 0 18px; }
      .control-label { color: #344967; font-weight: 600; }
      .form-control {
        border: 1px solid #d5dee8;
        border-radius: 7px;
        box-shadow: none;
        height: 42px;
      }
      .form-control:focus {
        border-color: #1685a2;
        box-shadow: 0 0 0 3px rgba(22, 133, 162, .12);
      }
      .btn-primary {
        background: #087e9d;
        border-color: #087e9d;
        border-radius: 7px;
        font-weight: 600;
        padding: 9px 18px;
      }
      .btn-primary:hover, .btn-primary:focus {
        background: #06677f;
        border-color: #06677f;
      }
      .search-note { color: #718198; font-size: 12px; line-height: 1.5; margin-top: 14px; }
      .content-intro { margin-bottom: 18px; padding: 20px 24px; }
      .content-intro h2 { font-size: 19px; font-weight: 650; margin: 0 0 6px; }
      .content-intro p { color: #63748a; margin: 0; line-height: 1.55; }
      .chart-card { margin-bottom: 18px; overflow: hidden; padding: 18px 20px 10px; }
      .chart-card h3 { color: #253b59; font-size: 16px; font-weight: 650; margin: 0 0 8px; }
      .chart-card .shiny-plot-output { width: 100%; }
      .busy-spinner { z-index: 1000; }
      @media (max-width: 767px) {
        .container-fluid { padding: 16px 14px 28px; }
        .app-header { padding: 22px 20px; }
        .app-header h1 { font-size: 25px; }
        .search-panel { margin-bottom: 18px; }
      }
    "))
  ),
  add_busy_spinner(spin = "fading-circle"),
  tags$div(
    class = "app-header",
    tags$h1("Europe PMC Explorer"),
    tags$p("Explore publication trends and discover leading journals and researchers.")
  ),
  sidebarLayout(
    sidebarPanel(
      tags$div(
        class = "search-panel",
        tags$h3("Search the literature"),
        textInput("keyword", "Keyword or author name", "tenapanor"),
        actionButton("go", "Search publications", class = "btn-primary"),
        tags$p(
          class = "search-note",
          "Searches Europe PMC and retrieves up to 5,000 publications. Larger searches may take 60-90 seconds."
        )
      ),
      width = 3
    ),
    mainPanel(
      tags$div(
        class = "content-intro",
        tags$h2("Literature overview"),
        tags$p("Publication counts, frequent contributors, and activity over time for your search.")
      ),
      fluidRow(
        column(
          width = 6,
          tags$section(
            class = "chart-card",
            tags$h3("Top 10 journals"),
            plotOutput("journal_plot", height = "360px")
          )
        ),
        column(
          width = 6,
          tags$section(
            class = "chart-card",
            tags$h3("Top 10 authors"),
            plotOutput("author_plot", height = "360px")
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          tags$section(
            class = "chart-card",
            tags$h3("Publications over time"),
            plotOutput("time_plot", height = "340px")
          )
        )
      ),
      width = 9
    )
  )
)


# Create the server side
server <- function(input, output, session) {
  # Create a dataframe (df) that will contain the results of your query to the EuropePMC API. This will be a 'global' variable
  df <- eventReactive(input$go, europepmc::epmc_search(query = input$keyword, limit = 5000, synonym = TRUE))
  # The 'input$keyword' refers to the input variable entered by the user

  # Count and plot the top publishing journals in the field
  output$journal_plot <- renderPlot({
    # Summarize by determining the counts for each journal title
    journal <- df() %>%
      group_by(journalTitle) %>%
      summarise(count = n()) %>%
      # drop_na removes journals that have no recorded titles
      drop_na(journalTitle) %>%
      top_n(n = 10, wt = count)
    # Plot the 'journal' dataframe (top 10 journals)
    # the y = reorder is used to plot the journal titles in order of decreasing count
      ggplot(journal, aes(x = count, y = reorder(journalTitle, count))) +
      geom_col(fill = "#087e9d", width = 0.72) +
      xlab("Count") +
      ylab("Journal") +
      ggtitle("Top 10 journals") +
      theme_minimal(base_size = 12) +
      theme(
        plot.title = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title = element_text(color = "#61738a"),
        axis.text = element_text(color = "#344967")
      )
  })
  
  # Count and plot the top 10 authors in the field 
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
    geom_col(fill = "#087e9d", width = 0.72) +
    xlab("Count") + 
    ylab("Author") +
    ggtitle("Top 10 authors") +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_blank(),
      axis.title = element_text(color = "#61738a"),
      axis.text = element_text(color = "#344967")
    )
  })
  
  # Plot publications over time
  output$time_plot <- renderPlot({
  df() %>% 
    # First change the pubYear to numeric so that we can plot a lineplot
    mutate(pubYear = as.numeric(pubYear)) %>%
    # groupby year and then summarize with counts of the number of publications
    group_by(pubYear) %>%
    summarise(count = n()) %>%
    drop_na(pubYear) %>%
    ggplot(aes(x = pubYear, y = count)) +
    geom_line(color = "#087e9d", size = 1) +
    geom_point(color = "#087e9d", size = 2) +
    xlab("Year") + 
    ylab("Count") +
    ggtitle("Number of publications over time") +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_blank(),
      panel.grid.minor = element_blank(),
      axis.title = element_text(color = "#61738a"),
      axis.text = element_text(color = "#344967")
    )
    })
}

shinyApp(ui = ui, server = server)

