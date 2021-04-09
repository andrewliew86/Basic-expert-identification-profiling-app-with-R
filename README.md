# Shiny app for expert identification and basic profiling

Background: Identifying and gathering information on thought leaders are important steps when developing a marketing campaign or advisory board. Traditionally, the intiail stages of expert profiling involves searching scientific literature databases (e.g. PubMed and Europe PMC) and counting the number of publications associated with each author.   Publishers/experts are then ranked based on their publication counts. However, manual counting of publications can be time consuming and error-prone. 

Results: I created an R Shiny app/dashboard (see Figure below for screenshot) that allows the user to perform a keyword (or author) search of the Europe PMC database and automatically obtain a list of the top 10 authors/experts associated with the search term. Apart from the names of experts, the app also provides indicators of research activity in a scientific field of interest (volume of publications over time and top 10 journals). The app/dashboard can be a good starting point for literature-based expert identification and profiling.   

R libraries/tools: Standard R libraries (Shiny, ggplot, dplyR) and the europepmc library - an R Client for the Europe PubMed Central RESTful Web Service.

Instructions: Copy and run the script in your local machine. Type a search term into the box and click on the search button. Wait for a minute (processing time will vary based on the number of hits) and several charts will be displayed (top authors, top journals, volumne of publications over time)


![alt tag](https://github.com/andrewliew86/KOL-mapping-with-Shiny-app/blob/main/UI_picture.PNG)
