# KOL-mapping-with-Shiny-app

Challenge: One quick way to perform key opinion leader (KOL) mining and profiling is to search literature databases (e.g. PubMed or Europe PMC) to identify experts who publish high volumes of peer-reviewed articles. Analyzing publication data can also reveal influential journals and volume of literature over time. At present, Europe PMC does not information on the top journals or authors in a scientific discipline.

Solution: I created an R Shiny dashboard that allows the user to perform a keyword search of the Europe PMC database and returns the volume of publications over time, the top 10 authors and the top 10 journals based on publication counts. I was able to use this shiny app to get a ‘quick’ overview of a scientific area and utilize the list of experts identified for further profiling. 

Tools used: Standard R libraries (Shiny, ggplot, dplyR) and the europepmc library - an R Client for the Europe PubMed Central RESTful Web Service.
