## Short Description

I've adapted Neal Caren's script to split judicial opinions downloaded from Lexis Nexis. I use the adapted sript to combine
opinions by the US Supreme Court from the year 2005 with metadata from the Supreme Court Database for the same year into a single dataset. As an example of what could be done with these data, I've also produced some word clouds.

## Dependencies

1. R, version 3.1
2. Python 2.7, Anaconda distribution.

## Files

### Data

1. SCDB_2015_01_caseCentered_LegalProvision.csv: Most recent dataset from the Supreme Court Database ("case centered data""), available here: http://supremecourtdatabase.org/data.php 
2. U_S__Supreme_Court_Cases,_Lawyers'_Edition2015-12-08_20-42.TXT: Contains the text of every U.S. Supreme Court opinion delivered in calendar year 2005 (not to be confused with the 2005 SCOTUS term) collected via lexis nexis.
3. U_S__Supreme_Court_Cases,_Lawyers'_Edition2015-12-08_20-42.csv: The opinion dataset derived by the python script below from the raw data in the text file above. Tne dataset includes the name of each case, the "US Cite" docket number of the case, and the first 30,000 characters of the opinion. 

### Code

1. split_ln_dva.py: My adaptation of Neal Caren's script. It takes the text file above (raw data), splits on the opinions and produces the csv dataset in 3 above.
2. OR_Final_Project.R: Loads, cleans, and merges the raw Supreme Court Database dataset (1 above) and my opinion dataset (3 above) into the final combined data set below (1 below). It also does a text analysis of the opinions and produces the pdf word clouds in 2-4 below.

### Results

1. Supreme_Court_2005_Opinions.csv: Final dataset which includes the metadata from the Supreme Court Database and the text of the opinions.
2. all justices.pdf: Word cloud showing distinctive terms used by all Justices in opinions delivered in 2005.
3. Scalia.pdf: Word cloud showing distinctive terms used by Justice Scalia in opinions delivered in 2005.
4. Other than Scalia.pdf: Word cloud showing distinctive terms used by Justices other than Justice Scalia in opinions delivered in 2005.

## More Information

Due to cell size limitations, only the first 30,000 characters (approx. 50 pages) of each opinion are analyzed. This should be easily fixable, I just didn't have the time. Also, word clouds might be more interesting if we used a specialized vocabulary dictionary for stemming and cleaning (a la Rice and Zorn (2013)). Please feel free to contact me with any questions, concerns or comments at: ogidotradicatberkeleydotedu.
