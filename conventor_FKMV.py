# -*- coding: utf-8 -*-
"""
Created on Tue Mar 31 19:06:41 2020

@author: PNGI
"""


from pywinauto.application import Application

from pywinauto.findwindows import WindowAmbiguousError, WindowNotFoundError

import pywinauto.keyboard

#import pywinauto.mouse

import time

import numpy  as np
import os.path
from importlib import reload
from xlrd import open_workbook
import matplotlib.pyplot as plt
import xlsxwriter 


def convertfiles(DepthinterestIDX, Directory,Location_name):    
    for i in DepthinterestIDX:
        
        File_name=Directory+Location_name+'_'+str(i)+".GWV"
        WindowsName="Variable Graph - "+ Windows_11+str(i)   
        
    
        if os.path.isfile(Directory+Location_name+str(i)+".txt"):
            print ("File exist")
            os.remove(Directory+Location_name+str(i)+".txt")
            
        if os.path.isfile(File_name):
            # app = Application(backend="win32").start("C:\GRLWEAP\Gwv.exe")
            app = Application(backend="win32").start("C:\PDI\GRLWEAP 2010\Gwv.exe")
        #    app.Open.type_keys(" C:\Projects\Test\FILE1.GWV")
            app.Open.type_keys(File_name)
            
            #app.Open.UP.click()
            time.sleep(1)
            app.Open.Open.click()
            
            time.sleep(1)
            
            #pywinauto.mouse.click(button='left', coords=(1267, 964))
            
            try:
                print ('Select "%s"' % WindowsName)
                #app.connect(title_re="%s" % WindowsName)
                dlg_spec = app.top_window_()
                dlg_spec.MenuSelect("Window -> &1 "+Location_name+str(i))
                dlg_spec.MenuSelect("File -> SaveAs")       
            except(WindowNotFoundError):     
                print( '"%s" not found' % WindowsName)
                pass
            except(WindowAmbiguousError):
                print ('There are too many "%s" windows found' % WindowsName)
                pass
    
    #    dlg_spec = app.window(title='Variable Graph - FILE1')
    #    dlg_spec = app.window(title=WindowsName)    
    #    app.VariableGraphFILE1.MenuSelect("Window -> &1 FILE1")
     
    #    app.VariableGraphFILE1.MenuSelect("Window -> &1 FILE1")
    #    
    #    app.VariableGraphFILE1.MenuSelect("File -> SaveAs")
        
    
        
            app.SaveAs.type_keys(Directory+Location_name+str(i)+".txt")
            
            time.sleep(2)
            
            app.SaveAs.Save.Click()
            time.sleep(1)    
            pywinauto.keyboard.send_keys("{ENTER}")
            
            time.sleep(3)
            dlg_spec = app.top_window_()
            dlg_spec.MenuSelect("File -> Exit")
            
            #app.VariableGraphFILE1.type_keys("%{F4}") 
            
        
            time.sleep(2)
        else:
            print ('file  "%s" not exists' % Location_name+str(i)+".GWV")
   
  
            ###########################################################################################
    ##### Readings the produced text files and stored in an dictionary
def axisDefault(ax,title,xlabel,ylabel):
    #just to load the default scientific layout for an axis object
    #ax.set_ylim(0,ymax)
    #ax.set_xlim(0,xmax)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.minorticks_on()
    ax.grid(linestyle='-',alpha=0.5,linewidth=1)
    ax.grid(which='minor',axis='both',
             linestyle='--',alpha=0.3,linewidth=1)
    ax.set_title(title)
    return
def extractFromFile(fname,ID,IDofSec):
    #fname must be a string
    #ID must be an integer
    #saving the headers starting from the first degment after pile top
    idxinters=np.argwhere(IDofSec==ID)
    idxinters = idxinters [0,0]
    #headers = np.loadtxt(fname,skiprows=5,max_rows=1,dtype=str)
    #headers = np.array(headers[4:],dtype=float)     PNGI
    #saving data, after storing time it is deleting all the column from 
    #the first till the column of pile top (included)
    data = np.loadtxt(fname,skiprows=6)
    t = data[:,1]
    data = data[:,4:]
    #extract the column that match the input ID
    #column = np.argwhere(headers==ID)  PNGI
    
    #column = column [0,0]   PNGI
    column=idxinters
    value = data[:,column] 
    return t,value

def plotTimeSeries(locName,anaName,GE_DepthinterestIDX,GE_Sections,FDLr,GE_Depth_Section,GE_SwitchSectionIn):
    
    CurrentDir=os.getcwd()
    for jjj in np.arange(len(locName)):
        location=locName[jjj]
        IDofSec=GE_Sections[jjj]
        DepthSection=GE_Depth_Section[jjj]
        plotDepth=GE_DepthinterestIDX[jjj]
        switchToPlot=GE_SwitchSectionIn[jjj]
        index_list=np.nonzero(switchToPlot)[0]
        IDtoPlot=[IDofSec[mmm] for mmm in index_list]
        excel_name = CurrentDir + '\\Output\\EW_1_55_Time_series.xlsx'
        workbook = xlsxwriter.Workbook(excel_name)
        for analysisID in np.arange(len(anaName)):
            analysis=anaName[analysisID]
            Foldername=FDLr[analysisID]
            if analysis[-3:]=='ACC':
                for i in range(len(IDtoPlot)): 
                    fig1 = plt.figure(figsize = (8.27,3.89))                           
                    subplot_index = 111
                    ax1 = fig1.add_subplot(subplot_index)
                    axisDefault(ax1,'Distance from pile head '+str(DepthSection[index_list[i]])+' m','Time [ms]',"Acceleration [g's]")
                    for j in range(len(plotDepth)):
                        t,acc = extractFromFile(CurrentDir+'\\'+Foldername+'\\'+location.rstrip()+analysis+str(plotDepth[j])+'.txt',IDtoPlot[i],IDofSec)#PLEASE CHECK THE FINAL NAMING + path
                        worksheet_name = 'Sec. 11 Acc_' + str(int(DepthSection[i])) + '_' + str(plotDepth[j])
                        worksheet = workbook.add_worksheet(worksheet_name)
                        worksheet.write_string('B1', 'Time')
                        worksheet.write_string('C1', 'Acceleration')
                        worksheet.write_string('B2', '[s]')
                        worksheet.write_string('C2', '[g\'s]')
                        for row_num, data in enumerate(t):
                            worksheet.write(row_num+2 , 1, data)
                        for row_num, data in enumerate(acc):
                            worksheet.write(row_num+2 , 2, data)
                        ax1.plot(t,acc,label='Penetration '+str(plotDepth[j])+ ' m')
                    ax1.legend(loc='upper right')
                    fig1.tight_layout()        
                    # fig1.savefig(CurrentDir+'\\Plots\\'+location.rstrip()+'_'+str(DepthSection[index_list[i]])+'_ACCTime.png',dpi=300)    
                    fig1.savefig(CurrentDir+'\\Plots\\'+location.rstrip()+'_'+str(i+1)+'_ACCTime.png',dpi=300)
            elif analysis[-3:]=="FOR":
                
                for i in range(len(IDtoPlot)):
                    fig2 = plt.figure(figsize = (8.27,3.89))
                    subplot_index = 111
                    ax2 = fig2.add_subplot(subplot_index)
                    axisDefault(ax2,'Distance from pile head '+str(DepthSection[index_list[i]])+' m','Time [ms]','Force [kN]')
                    for j in range(len(plotDepth)):                         
                        t,force = extractFromFile(CurrentDir+'\\'+Foldername+'\\'+location.rstrip()+analysis+str(plotDepth[j])+'.txt',IDtoPlot[i],IDofSec) 
                        worksheet_name = 'Sec. 11 Frc_' + str(int(DepthSection[i])) + '_' + str(plotDepth[j])
                        worksheet = workbook.add_worksheet(worksheet_name)                        
                        worksheet.write_string('B1', 'Time')
                        worksheet.write_string('C1', 'Force')
                        worksheet.write_string('B2', '[s]')
                        worksheet.write_string('C2', '[kN]')
                        for row_num, data in enumerate(t):
                            worksheet.write(row_num+2 , 1, data)
                        for row_num, data in enumerate(force):
                            worksheet.write(row_num+2 , 2, data)
                        ax2.plot(t,force,label='Penetration '+str(plotDepth[j])+ ' m')
                    ax2.legend(loc='upper right')
                    fig2.tight_layout()
                    # fig2.savefig(CurrentDir+'\\Plots\\'+location.rstrip()+'_'+str(DepthSection[index_list[i]])+'_FORTime.png',dpi=300)   
                    fig2.savefig(CurrentDir+'\\Plots\\'+location.rstrip()+'_'+str(i+1)+'_FORTime.png',dpi=300)
        workbook.close()
    return


def readFile(fileName):
    file = open(fileName,'r') 
    allLines = file.readlines()
    lines = []
    for line in allLines:
        if line[0] != '#':
            lines.append(line)
    file.close()
    return lines


wb = open_workbook('PDAcalc.xlsx')
sheet1 = wb.sheet_by_name('LOCATIONS')



Locationdata =[[sheet1.cell_value(r,c) for c in np.arange(1,sheet1.ncols)] for r in np.arange(1,sheet1.nrows)]

sheet2 = wb.sheet_by_name('PROJ')

Folderdata =[[sheet2.cell_value(r,c) for c in np.arange(1,3)] for r in np.arange(2,8)]

Labledata =[[sheet2.cell_value(r,c) for c in np.arange(1,24)] for r in np.arange(12,17)]


CurrentDir=os.getcwd()



#General information on the analysis
FileGeninfo=CurrentDir+'\\Python_Exchange\\GeneralInfo_Analysis.txt'  
  
lines=readFile(FileGeninfo)
data=[]
for i in range(len(lines)):
    Sline=lines[i].strip().split(' ')
    data.append(Sline)
    Foldername=[]
    Analysislabe=[]
    
Labl=['__Frc_','__Acc_']
    
for i in np.arange(len(data)):
    Analysislabe.append(data[i][1])
    Foldername.append(data[i][0])
    
    
#Name of the locations 
FileGeninfo=CurrentDir+'\\Python_Exchange\\LocationNames.txt'    
Locations=readFile(FileGeninfo)
GE_Sections=[]
GE_Depth_Section=[]
GE_DepthinterestIDX=[]
GE_SwitchSectionIn=[]
for loc in np.arange(len(Locations)):

    for analysis in np.arange(len(Analysislabe)): 
        SectionsOfInter = []
        DepthSecOfInter = []
        SwitchSectionIn = []
        Peninforfile=CurrentDir+'\\Python_Exchange\\' +'Pen_Depth'+Locations[loc].rstrip()+Analysislabe[analysis]+'.txt'        
        lines = np.loadtxt(Peninforfile, dtype='i')    
        Impact_depth = []
        for i in range(len(lines)):
            if lines[i,1] == 0:  Impact_depth.append(i)
        if Impact_depth[-1] == Impact_depth[-2]:   Impact_depth[-1] = Impact_depth[-1] + 1
            
        Middle=int(len(Impact_depth)/2)
        FirstQuarter=int(len(Impact_depth)*1/6)
        #FirstQuarter=2
        ThirdQuarter=int(len(Impact_depth)*5/6)        
        DepthinterestIDX=[Impact_depth[FirstQuarter],Impact_depth[Middle],Impact_depth[-2]]           
        SectioninfoFile=CurrentDir+'\\Python_Exchange\\' +'SectionInfo'+Locations[loc].rstrip()+Analysislabe[analysis]+'.txt'        
        lines = np.loadtxt(SectioninfoFile, dtype=float)
        for i in np.arange(len(lines)):
            if lines[i,0] != 0:
                SectionsOfInter.append(lines[i,1])
                DepthSecOfInter.append(lines[i,0])
                SwitchSectionIn.append(lines[i,2])                   
        Location_name=Locations[loc].rstrip()+Analysislabe[analysis]
        Windows_11=Locations[loc].rstrip()+Analysislabe[analysis]
        First_Depth_Blow=Impact_depth[2]
        #First_Depth_Blow=33 
        Last_Depth=Impact_depth[-1]
        #Last_Depth=48
        Impact_depth = Impact_depth[1:-1]
        DicFiles=Foldername[analysis]      # 
        Directory=CurrentDir+'\\'+DicFiles+'\\'
        File_Number=np.arange(First_Depth_Blow,Last_Depth)
        convertfiles(Impact_depth, Directory,Location_name)
    GE_Sections.append(SectionsOfInter)
    GE_Depth_Section.append(DepthSecOfInter)
    GE_DepthinterestIDX.append(DepthinterestIDX)
    GE_SwitchSectionIn.append(SwitchSectionIn)
plotTimeSeries(Locations,Analysislabe,GE_DepthinterestIDX,GE_Sections,Foldername,GE_Depth_Section,GE_SwitchSectionIn)  
        
    
    #%%
#plotTimeSeries(['AO4'],['FULL_UB_'],[45,46,47],[2,10])
 
  
    

    
    