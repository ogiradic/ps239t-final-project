setwd("~/Documents/Ogi/ps239t-final-project/Data")
rm(list=ls())
library(foreign)
library(xtable)
library(Hmisc)
library(polycor)
#I want to subset the large supreme court metadata dataset I downloanded from the Supreme Court Database 
#and combine it with the opinion dataset I created from the lexis nexis txt files for the 2005 term.

#Loading in the big metadataset
MetadataSet <- read.csv("SCDB_2015_01_caseCentered_LegalProvision.csv", header=TRUE)

#Loading the 2005 term opinion dataset
OpinionSet <- read.csv("U_S__Supreme_Court_Cases,_Lawyers'_Edition2015-12-08_20-42.csv", header=TRUE)

#First, in order to limit the metadata set only to cases decided in 2005, I will have to coerce one of the dataset's 
#date-based variables (all of which are factors) into a numeric variable. This is most easily done with the "caseId" variable,
#which is ordered according to date of the decision (using the "dateDecision" variable turns into a mess). 
MetadataSet$NewCaseId <- as.numeric(MetadataSet$caseId)

#Subsetting the metadata set to include just the variables I'm interested in. Namely, (i) case number (which is different from 
#caseid), which I'll use for some de-duping, (ii) decision date, (iii) name of case, (iv) the "US cite" docket number, (v)
# opinion writer and (vi) the new numeric caseId.
SubmetadataSet <- MetadataSet[, c("caseIssuesId","dateDecision","caseName", "usCite", "majOpinWriter", "NewCaseId")]

#Now will limit the metadata subset to cases decided in 2005, which correspondes to NewCaseIds between 7767 and 7845 inclusive 
SubmetadataSet <- SubmetadataSet[which(SubmetadataSet$NewCaseId > 7766 & SubmetadataSet$NewCaseId < 7846), ]

#Multiple cases that are resolved by the same opinion are treated in the Supreme Court Database as different cases,
#notwithstanding that they share the same opinion, name and docket number (they may differ in their counsel, case history, etc.).
#For my purposes I de-dupe these using the case number, which includes the docket id, a dash, and an additional number. All
#case id's with a number higher than 1 after the dash are removed.
SubmetadataSet <- SubmetadataSet[which(SubmetadataSet$caseIssuesId != "2004-013-02-01" & SubmetadataSet$caseIssuesId != "2004-014-01-02" & SubmetadataSet$caseIssuesId != "2004-014-02-01" & SubmetadataSet$caseIssuesId != "2004-014-02-02" & SubmetadataSet$caseIssuesId != "2004-016-02-01" & SubmetadataSet$caseIssuesId != "2004-018-02-01" & SubmetadataSet$caseIssuesId != "2004-022-01-02" & SubmetadataSet$caseIssuesId != "2004-025-02-01" & SubmetadataSet$caseIssuesId != "2004-028-02-01" & SubmetadataSet$caseIssuesId != "2004-031-01-02" & SubmetadataSet$caseIssuesId != "2004-045-01-02" & SubmetadataSet$caseIssuesId != "2004-045-02-01" & SubmetadataSet$caseIssuesId != "2004-045-02-02" & SubmetadataSet$caseIssuesId != "2004-045-03-01" & SubmetadataSet$caseIssuesId != "2004-045-03-02" & SubmetadataSet$caseIssuesId != "2004-047-02-01" & SubmetadataSet$caseIssuesId != "2004-052-01-02" & SubmetadataSet$caseIssuesId != "2004-054-01-02" & SubmetadataSet$caseIssuesId != "2004-061-01-02" & SubmetadataSet$caseIssuesId != "2004-063-01-02" & SubmetadataSet$caseIssuesId != "2004-064-01-02" & SubmetadataSet$caseIssuesId != "2004-071-02-01" & SubmetadataSet$caseIssuesId != "2004-073-01-02" & SubmetadataSet$caseIssuesId != "2004-074-01-02" & SubmetadataSet$caseIssuesId != "2004-080-02-01" & SubmetadataSet$caseIssuesId != "2005-004-01-02" & SubmetadataSet$caseIssuesId != "2004-005-02-01"), ]

#The author of each opinion in the metadata set is coded with a number. However, opinions signed by the entire court (per curiam)
#are coded as NA. So as not to exclude those opinions from my analysis, I recode NA's as 99 (not used in original) for the 
#writer variable.
SubmetadataSet$majOpinWriter[is.na(SubmetadataSet$majOpinWriter)] <- 99

#The opinion dataset also requires some subsetting. LexisNexis includes among 2005 opinions pro forma orders, which the
#Supreme Court Database does not count as opinions. The docket numbers for such orders have 4 digits, so I exclude them
#on that basis.
SubOpinionSet <- OpinionSet[which(OpinionSet$usCite != "543 U.S. 1045" & OpinionSet$usCite != "543 U.S. 1139" & OpinionSet$usCite != "543 U.S. 1140" & OpinionSet$usCite != "543 U.S. 1141" & OpinionSet$usCite != "543 U.S. 1142" & OpinionSet$usCite != "126 S. Ct. 1" & OpinionSet$usCite != "544 U.S. 1046" & OpinionSet$usCite != "544 U.S. 1301"), ]

#In addition, two rulings on motions, which the Court expounded upon in writing are included in the Lexis search results, 
#but are not treated as opinions by the Supreme Court database. I exclude these from the analysis as well.
SubOpinionSet <- SubOpinionSet[which(SubOpinionSet$usCite != "544 U.S. 936" & SubOpinionSet$usCite != "544 U.S. 942"), ]

#Merging the opinion and metadata datasets
NewDataSet <- merge(SubmetadataSet, SubOpinionSet)

#I can remove the columns used to de-dupe and order the cases by date and the extra name column, keeping (i) docket id, (ii)
#decision date, (iii) name, (iv) opinion author and (v) text of the opinion.
NewDataSet <- NewDataSet[, c("dateDecision","caseName", "usCite", "majOpinWriter", "TEXT")]

#Write to csv.
write.csv(NewDataSet,"Supreme_Court_2005_Opinions.csv")

#Text Analysis

setwd("~/Documents/Ogi/ps239t-final-project/Results")
rm(list=ls())
library(tm)
library(RTextTools)
library(lsa)
library(cluster)
library(fpc)
library(SnowballC)
library(matrixStats)
library(wordcloud)

docs.df <- read.csv("Supreme_Court_2005_Opinions.csv", header=TRUE)
docs <- Corpus(VectorSource(docs.df$TEXT))
dtm <- DocumentTermMatrix(docs,
           control = list(stopwords = T,
                          tolower = TRUE,
                          removeNumbers = TRUE,
                          removePunctuation = TRUE,
                          removeWords = c("ese"),
                          stemming=TRUE))

dtm <- removeSparseTerms(dtm, .99)
dim(dtm)
dtm.m <- as.data.frame(as.matrix(dtm))

#adding a column for author of each opinion
dtm.m$author <- docs.df$majOpinWriter

#Subset into 2 dtms: one for Scalia and one for everyone else. From SC Database codebook, I know scalia is author number 5.

scalia <- subset(dtm.m,author==105, select = -author)#8 opinions 
rest <- subset(dtm.m,!author==105, select = -author)#71 opinions

#means and variances
means.scalia <- colMeans(scalia)
var.scalia <- colVars(as.matrix(scalia))
means.rest <- colMeans(rest)
var.rest <- colVars(as.matrix(rest))

#overall score
num <- (means.scalia - means.rest) 
denom <- sqrt((var.scalia/3) + (var.rest/3))
score <- num / denom

# sort and view
score <- sort(score)
head(score,10) # top rest words
tail(score,10) # top scalia words
#in general, other justices like to annotate, digest, maintain, adhere, help and reach. They also like to mention juries (probably in conjuction with "reach") alot.
#Scalia, in contrast, likes to use the words "must", "hard" and "substant-" the most. He also like the words "true", "seem" and "think".

#wordcloud for all decisions
freq <- colSums(as.matrix(dtm))
wordcloud(names(freq), freq, max.words=100, colors=brewer.pal(6,"Dark2"))

#wordcloud just for Scalia
freqScalia <- colSums(as.matrix(scalia))
wordcloud(names(freqScalia), freq, max.words=100, colors=brewer.pal(6,"Dark2"))

#wordcloud excluding Scalia
freqRest <- colSums(as.matrix(rest))
wordcloud(names(freqRest), freq, max.words=100, colors=brewer.pal(6,"Dark2"))

#We see that the Court, the government and the statute of limitations/timebar loom large in all three wordclouds. What distinguishes Scalia is that he doesn't refer as frequently
#to the constitution or rules or laws (though he mentions law books alot). Another thing that sticks out is that Scalia mentions the right of newborns enought that it appears in
#the cloud.  The rest of of the Court (and the Court as a whole) frequently refers to the constitution and laws and cases.
