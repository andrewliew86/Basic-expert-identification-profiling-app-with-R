# Shiny app for expert identification and basic profiling

Background: Identifying and gathering information on thought leaders are important steps when developing a marketing campaign or advisory board. Traditionally, expert profiling is performed by searching scientific literature databases (e.g. PubMed and Europe PMC) and manually counting the number of publications associated with each author.  Publishers/experts can then be ranked based on their publication counts. However, manual counting of publications can be time consuming and error-prone. 

Results: I created an R Shiny dashboard (see Figure below for screenshot) that allows the user to perform a keyword search of the Europe PMC database and automatically returns the volume of publications over time, the top 10 authors and the top 10 journals based on publication counts. I was able to use this shiny app to get a ‘quick’ overview of a scientific area and utilize the list of experts identified for further profiling. 

Libraries/tools used: Standard R libraries (Shiny, ggplot, dplyR) and the europepmc library - an R Client for the Europe PubMed Central RESTful Web Service.

Instructions: Copy and run the script in your local machine. Type a search term into the box and click on the search button. Wait for a minute (processing time will vary based on the number of hits) and several charts will be displayed (top authors, top journals, volumne of publications over time)


![alt tag](https://github.com/andrewliew86/KOL-mapping-with-Shiny-app/blob/main/UI_picture.PNG)
