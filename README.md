# Shiny app for expert identification and profiling

Challenge: Identifying and gathering information on thought leaders are important steps when developing a marketing campaign or advisory board. Traditionally, expert profiling was conducted by searching scientific literature databases (e.g. PubMed and Europe PMC) and manually counting the number of publications associated with each author. Publication count was then used to rank the authors/experts. At present, Europe PMC does not provide information on top authors in a scientific discipline.

Solution: I created an R Shiny dashboard that allows the user to perform a keyword search of the Europe PMC database and automatically returns the volume of publications over time, the top 10 authors and the top 10 journals based on publication counts. I was able to use this shiny app to get a ‘quick’ overview of a scientific area and utilize the list of experts identified for further profiling. 

Tools used: Standard R libraries (Shiny, ggplot, dplyR) and the europepmc library - an R Client for the Europe PubMed Central RESTful Web Service.

Instructions: Type a search term into the box below and click on the search button. Wait for a minute (processing time will vary based on the number of hits) and several charts will be displayed (top authors, top journals, volumne of publications over time)


![alt tag](https://github.com/andrewliew86/KOL-mapping-with-Shiny-app/blob/main/UI_picture.PNG)
