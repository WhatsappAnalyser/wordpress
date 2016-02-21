#my_rscript.R

library(stringr)
library(ggplot2)
library(gridExtra)
library(lubridate)
library(tm)
library(RColorBrewer)
library(wordcloud)


setwd("C:/Users/Cas/Documents/Rstudio_opdracht")

file = read.csv("a.txt", stringsAsFactors = F, head=F)

dim(file)
head(file)

value <- length(file)

if(value < 2){
  pattern <- "[0-9]*-[0-9]*-[0-9]*"
  file$V2 = str_match(file$V1, pattern)
  file$V3 = gsub(pattern = pattern, replacement = "", file$V1)
  file$V1 <- NULL
}

names(file) = c("Datum", "Bericht")
names

TijdIncSec <- "[0-9]{2}:[0-9]{2}:[0-9]{2}"
TijdWithoutSec <- "[0-9]{2}:[0-9]{2}"
TijdPmAm <- "([0-9]{2}|[0-9]{1}):[0-9]{2} (PM|AM)"

TijdIncSecTable = str_match(file$Bericht, TijdIncSec)
TijdWithoutSecTable = str_match(file$Bericht, TijdWithoutSec) 
TijdPmAmTable = str_match(file$Bericht, TijdPmAm)

if(sum(is.na(TijdIncSecTable)) <= sum(is.na(TijdWithoutSecTable)) && sum(is.na(TijdIncSecTable)) < sum(is.na(TijdPmAmTable))){
  file$Tijd = str_match(file$Bericht, TijdIncSec)
  file$Bericht = gsub(pattern = TijdIncSec, replacement = "", file$Bericht)
  timePattern <- "%H:%M:%S"
} else if(sum(is.na(TijdWithoutSecTable)) < sum(is.na(TijdIncSecTable)) && sum(is.na(TijdWithoutSecTable)) < sum(is.na(TijdPmAmTable))){
  file$Tijd = str_match(file$Bericht, TijdWithoutSecTable)
  file$Bericht = gsub(pattern = TijdWithoutSec, replacement = "", file$Bericht)
  timePattern <- "%H:%M"
} else {
  file$Tijd = str_match(file$Bericht, TijdPmAm)
  file$Bericht = gsub(pattern = TijdPmAm, replacement = "", file$Bericht)
  timePattern <- "%H:%M"
}


#
#Bepaal het tussen stukje, in dit geval wordt '-' gebruikt
#

naamMetStreepje <- "- [A-z]{1,}"
naamMetDubbelePunt <- ": .*:"

naamMetStreepjeTable = str_match(file$Bericht, naamMetStreepje)
naamMetDubbelePuntTable = str_match(file$Bericht, naamMetDubbelePunt)

naamMetStreepjeTable
naamMetDubbelePuntTable


if(sum(is.na(naamMetStreepjeTable)) < sum(is.na(naamMetDubbelePuntTable))){
  file$Afzender = str_match(file$Bericht, naamMetStreepje)
  file$Bericht = gsub(pattern = naamMetStreepje, replacement = "", file$Bericht)
  file$Afzender = gsub(pattern = "-", replacement = "", file$Afzender)
}else{
  file$Afzender = str_match(file$Bericht, naamMetDubbelePunt)
  file$Bericht = gsub(pattern = naamMetDubbelePunt, replacement = "", file$Bericht)
  file$Afzender = gsub(pattern = ":", replacement = "", file$Afzender)
}


#
#Bepaal het stuk voor het bericht, in dit geval wordt ':' gebruikt
#


file$Bericht = gsub(pattern = ".*:", replacement = "", file$Bericht)


file = file[,c(1,3,4,2)]
file = file[complete.cases(file),]

frequentie = table(file$Afzender)
frequentie

##universal date parser

##select a sample set of lines
##dit moet een random selectie met grote tussenruimte worden
## nu het ik gewoon nog even de regels 2-12 gekozen

##dit is een nettere manier om het dataframe aan te maken, maar dat komt later
##testregels <- data.frame(Message=character(), 
##                 Date=as.Date(character()),
##                 Time=character(),
##                 Author=character(), 
##                 stringsAsFactors=FALSE) 

testregels = data.frame()
selectors = c(2, 4, 6, 8, 10, 12)
if (nrow(file)>11){
  testregels = data.frame(c(file[selectors,]))
}
names(testregels) = "Message"
for (i in 1:length(testregels)){
  unlist(testregels[,i])
}


##First find all the datelike tekst and put them in a separate column
dates = c("([0-9]+/[0-9]+/[0-9]+)", "([0-9]+-[0-9]+-[0-9]+)")
testregels$dateStamp = NA
for (i in 1:length(dates)){
  for (j in 1:nrow(testregels)){
    if(is.na(testregels$dateStamp[j])){
      testregels$dateStamp[j] = str_extract(testregels$Message[j], dates[i])
    }
    
  }
}

## determine date format

## build a dataframe with the possible patterns that uniquely identify dateformats
dateFormats = data.frame(dmySlash = as.character(c("(1[3-9]/0[1-9]/[0-9]{2}\\b)",
                                                   "([2,3][0-9]/0[1-9]/[0-9]{2}\\b)",
                                                   "(1[3-9]/1[0,1,2]/[0-9]{2}\\b)",
                                                   "([2,3][0-9]/1[0,1,2]/[0-9]{2}\\b)")),
                         dmyDash = as.character(c("(1[3-9]-0[1-9]-[0-9]{2}\\b)",
                                                  "([2,3][0-9]-0[1-9]-[0-9]{2}\\b)",
                                                  "(1[3-9]-1[0,1,2]-[0-9]{2}\\b)",
                                                  "([2,3][0-9]-1[0,1,2]-[0-9]{2}\\b)")),
                         mdySlash = as.character(c(   "(0[1-9]/1[3-9]/[0-9]{2}\\b)",
                                                      "(0[1-9]/[2,3][0-9]/[0-9]{2}\\b)",
                                                      "(1[0,1,2]/1[3-9]/[0-9]{2}\\b)",
                                                      "(1[0,1,2]/[2,3][0-9]/[0-9]{2}\\b)")),
                         mdyDash = as.character(c(   "(0[1-9]-1[3-9]-[0-9]{2}\\b)",
                                                     "(0[1-9]-[2,3][0-9]-[0-9]{2}\\b)",
                                                     "(1[0,1,2]-1[3-9]-[0-9]{2}\\b)",
                                                     "(1[0,1,2]-[2,3][0-9]-[0-9]{2}\\b)")),
                         dmYSlash = as.character(c("(1[3-9]/0[1-9]/[0-9]{4})",
                                                   "([2,3][0-9]/0[1-9]/[0-9]{4})",
                                                   "(1[3-9]/1[0,1,2]/[0-9]{4})",
                                                   "([2,3][0-9]/1[0,1,2]/[0-9]{4})")),
                         dmYDash = as.character(c("(1[3-9]-0[1-9]-[0-9]{4})",
                                                  "([2,3][0-9]-0[1-9]-[0-9]{4})",
                                                  "(1[3-9]-1[0,1,2]-[0-9]{4})",
                                                  "([2,3][0-9]-1[0,1,2]-[0-9]{4})")),
                         mdYSlash = as.character(c(   "(0[1-9]/1[3-9]/[0-9]{4})",
                                                      "(0[1-9]/[2,3][0-9]/[0-9]{4})",
                                                      "(1[0,1,2]/1[3-9]/[0-9]{4})",
                                                      "(1[0,1,2]/[2,3][0-9]/[0-9]{4})")),
                         mdYDash = as.character(c(   "(0[1-9]-1[3-9]-[0-9]{4})",
                                                     "(0[1-9]-[2,3][0-9]-[0-9]{4})",
                                                     "(1[0,1,2]-1[3-9]-[0-9]{4})",
                                                     "(1[0,1,2]-[2,3][0-9]-[0-9]{4})")))
## make sure the dateformats are characterstrings and not vectors
for (i in 1:ncol(dateFormats)){
  dateFormats[,i] = as.character(dateFormats[,i])
  
}

##set your counters for recognition of patterns to zero
counter = data.frame(dmySlash = c(0,0,0,0),
                     dmyDash = c(0,0,0,0),
                     mdySlash = c(0,0,0,0),
                     mdyDash = c(0,0,0,0),
                     dmYSlash = c(0,0,0,0),
                     dmYDash = c(0,0,0,0),
                     mdYSlash = c(0,0,0,0),
                     mdYDash = c(0,0,0,0))

##test per dateformat the differnt patterns on each of the instances of date in our test set
##if a pattern matches set the corresponding cel to the number of matches
for (i in 1:ncol(counter)) {
  for(j in 1:nrow(counter)){
    check = 0
    for(k in 1:length(testregels$dateStamp)){
      matches <- str_match(testregels$dateStamp[k],dateFormats[j,i])
      check = check + (length(matches[!is.na(matches)])/2)
    }
    counter[j,i]= check        
  }
}
counter

## sum all the patterns of a particular format
## guess that highest sum is the one that matches most. 
datePatterns = c("%d/%m/%y","%d-%m-%y","%m/%d/%y","%m-%d-%y","%d/%m/%Y","%d-%m-%Y","%m/%d/%Y","%m-%d-%Y")
index = which(colSums(counter) == max(colSums(counter)))
## decide that that one is your datepattern
datePattern = datePatterns[index]

totalPattern = paste(datePattern, " ",timePattern, sep = "")

cbbPalette <- c("#43D854", "#35ac43", "#288132", "#1a5621", "#0d2b10", "#8ee798", "#b3efba",
                "#CC79A7", "#088da5", "#045463", "#39a3b7", "#6abac9", "#9cd1db", "#cde8ed")

#End SetUp

png(filename="D:/Dev/wordpress/wp-content/themes/whatsappanalyser/plots/temp.png", width=500, height=500)


  file <- transform(file, timestamp=as.POSIXct(paste(Datum, Tijd),format = totalPattern))
  file$Dag <- weekdays(file$timestamp)
  file$Dag = gsub(pattern = "maandag", replacement = "1. maandag", file$Dag)
  file$Dag = gsub(pattern = "dinsdag", replacement = "2. dinsdag", file$Dag)
  file$Dag = gsub(pattern = "woensdag", replacement = "3. woensdag", file$Dag)
  file$Dag = gsub(pattern = "donderdag", replacement = "4. donderdag", file$Dag)
  file$Dag = gsub(pattern = "vrijdag", replacement = "5. vrijdag", file$Dag)
  file$Dag = gsub(pattern = "zaterdag", replacement = "6. zaterdag", file$Dag)
  file$Dag = gsub(pattern = "zondag", replacement = "7. zondag", file$Dag)
  weekdagen = data.frame(table(file$Afzender, file$Dag))
  names(weekdagen) = c("Afzender","Dag", "Frequentie")
  ggplot(data=weekdagen, aes(x=Dag, y=Frequentie, group=Afzender, colour=Afzender)) +
    geom_line(size=1) + theme_bw() + scale_colour_manual(values=cbbPalette) + ggtitle("Verzonden berichten per dag")
    
  
dev.off()  

png(filename="D:/Dev/wordpress/wp-content/themes/whatsappanalyser/plots/temp1.png", width=500, height=500)
  
  file <- transform(file, timestamp=as.POSIXct(paste(Datum, Tijd),format = totalPattern))
  file$Dag <- weekdays(file$timestamp)
  file$Dag = gsub(pattern = "maandag", replacement = "1. maandag", file$Dag)
  file$Dag = gsub(pattern = "dinsdag", replacement = "2. dinsdag", file$Dag)
  file$Dag = gsub(pattern = "woensdag", replacement = "3. woensdag", file$Dag)
  file$Dag = gsub(pattern = "donderdag", replacement = "4. donderdag", file$Dag)
  file$Dag = gsub(pattern = "vrijdag", replacement = "5. vrijdag", file$Dag)
  file$Dag = gsub(pattern = "zaterdag", replacement = "6. zaterdag", file$Dag)
  file$Dag = gsub(pattern = "zondag", replacement = "7. zondag", file$Dag)
  file$Blok <- hour(file$timestamp)
  tijdstippen = data.frame(table(file$Afzender, file$Blok))
  names(tijdstippen) = c("Afzender","Tijd", "Frequentie")
  ggplot(data=tijdstippen, aes(x=Tijd, y=Frequentie, group=Afzender, colour=Afzender)) +
    geom_line(size=1) + theme_bw() +  scale_colour_manual(values=cbbPalette) + ggtitle("Verzonden berichten per tijd")
    
  
dev.off()

png(filename="D:/Dev/wordpress/wp-content/themes/whatsappanalyser/plots/temp2.png", width=500, height=500)
  
  file = file[complete.cases(file),]
  summary(file)
  frequentie = table(file$Afzender)
  barplot(frequentie,main = "wie stuurt de meeste chats", col=c("#43D854","#cccccc"),border = NA)
    
dev.off()

png(filename="D:/Dev/wordpress/wp-content/themes/whatsappanalyser/plots/temp3.png", width=500, height=500)
    
  file = file[,c(1,3,4,2)]
  
  file = file[complete.cases(file),]
  
  corpus <- Corpus(VectorSource(as.character(file$Bericht)))
  corpus <- tm_map(corpus, tolower)
  corpus <- tm_map(corpus, PlainTextDocument)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("dutch"))
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removeWords, c("jouw", "echt", "heel", "media", "jij", "wel", "enzo", "even", "miss", "okee", "weggelaten", "haha", "weer", "ofzo"))   
  
  tdm <-TermDocumentMatrix(corpus)
  
  freq <- slam::row_sums(tdm)
  words <- names(freq)
  pal <- c('#999999', '#216c2a', '#2e973a', '#43D854')
  wordcloud(words, freq, min.freq=10, scale=c(8,.5), colors=pal, main="WordCloud")
  

dev.off()
  