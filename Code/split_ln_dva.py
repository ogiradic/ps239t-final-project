#!/usr/bin/env python
# encoding: utf-8
"""
split_ln.py

Created by Neal Caren on 2012-05-14.
neal.caren@unc.edu

Takes a downloaded plain text LexisNexis file and converts it into a CSV file.


sample usage:
$ python split_ln.py T*.txt
Processing The_New_York_Times_TP_2012_1.txt
Processing The_New_York_Times_TP_2012_2.txt
Done

$ python split_ln.py ap_tp_201201.txt
Processing ap_tp_201201.txt
Done

"""



def split_ln(fname):
    print 'Processing\t',fname
    #Imort the two required modules
    import re
    import csv
    outname=fname.replace(fname.split('.')[-1],'csv') #replace the extension with "csv"
    #setup the output file. Maybe give the option for seperate text files, if desired.
    outfile=open(outname,'wb')
    writer = csv.writer(outfile)

    lnraw=open(fname).read() #read the file

       
    workfile=re.sub('                ([0-9]*?) of 110 DOCUMENTS\\r\\n','ENDOFILE',lnraw) #silly hack to find the end of the documents
    workfile=workfile.replace('\xef\xbb\xbf\r\n','') #clean up crud at the beginning of the file
    workfile=workfile.split('ENDOFILE') #split the file into a list of documents.
    workfile=[f for f in workfile if len(f.split('\r\n\r\n'))>2] #remove an blank rows
    
    #Figure out what special meta data is being reported
    meta_tuple=('NAME','usCite','TEXT')
    writer.writerow(meta_tuple)  


    #Begin loop over each file 
    for f in workfile:
	tiers=f.split('OPINION:') #split the files where opinion begins
	top=tiers[0] #everything before opinion begins
	bottom=tiers[1] #everything after opinion begins
	bottombottom=bottom.split('It is so ordered.\\r\\n') #split everything after opinion begins where opinion ends
	opinion=bottombottom[0] #this includes just the opinion and excludes what comes after opinion ends
	text=opinion[0:30000] #cuts the opinion at 30,000 characters so it can fit into one cell.

	#Split into lines, and clean up the hard returns at the end of each line.   
        filessplit=[row.replace('\r\n',' ') for row in f.split('\r\n\r\n') if len(row)>0]
        #The id number (from that search) is the first text in the first item of the list
        predocket=filessplit[3].lstrip()
        docket=predocket.split(';')[0] #SCOTUS cases have a few docket id’s. I only need one (“usCite”) to merge with other dataset
        name=filessplit[0] 
        
        #Output the results to a csv file
        meta_tuple=(name,docket,text)
        writer.writerow(meta_tuple)        
        #output.write(name+'\t'+docket+'\t'+text+'\n')   
    print 'Wrote\t\t',outname
    

if __name__ == "__main__":
    import sys
    try: 
        flist=sys.argv[1:]
    except:
        print 'Only one argument please. But you can use things like *.txt'
    else:
        for fname in flist:
            split_ln(fname)
        print 'Done'
    