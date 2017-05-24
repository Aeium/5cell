from __future__ import print_function

from Tkinter import *
from PIL import Image, ImageTk
import numpy as np
import random
import sys
from sys import stdout
from time import sleep
from bitstring import BitArray
from ConfigParser import SafeConfigParser

import grequests


ABOUT_TEXT = """
                          Welcome to Aeium's Map!

                Each pixel in the map represents an automation.

                                 Controls:

               Place reticule          - Mouse click near pixel

               Move reticule           - Arrow keys or 'WASD'

         Execute Selected Automation   - SpaceBar

       Save Selected Automation to png - ctrl+Spacebar

    Tip: Position windows with windows key and arrows (on windows PC).

    To see this prompt again, delete the settings.ini file then restart."""


FEILD_1   = """                                  Settings:

          How many characters per line do you want in the terminal?

                               Please type a number"""

FEILD_2   = """
           Do you want to contribute data for a collaborative heatmap?

                 heatmap URL: https://aeiums-map.herokuapp.com/

           (You may need to permit outbound traffic in your firewall)

                              Please enter 'y' or 'n'"""

DISCLAIMER = """
Contact:
Twitter: https://twitter.com/Aeium
Get in touch or follow for updates about this and other projects

Disclaimer:
This tool is provided as is. Aeium is not liable. Use at your own risk.
"""

	
	
root = Tk()
root.title("Aeium's Map")

rule = 0 #event.x/4 + (event.y /4) * 256

baseImage = Image.open('128.png').convert("RGB")
dispImage =  baseImage.resize((2**10, 2**10))
#image2  =  image.resize(2**10, 2**10)
display  =  ImageTk.PhotoImage(dispImage)
label = Label(root, image=display)
label.pack()


class configWindow(object):
    def __init__(self,master):
        top=self.top=Toplevel(master)
        T1 = Text(top,height=19, bg='lightgrey', relief='flat')
        T1.insert(END, ABOUT_TEXT)
        T1.config(state=DISABLED)
        T1.pack()
        #self.l1=Label(top,text=ABOUT_TEXT)
        #self.l1.pack()
        T2 = Text(top, height=5, bg='lightgrey', relief='flat')
        T2.insert(END, FEILD_1)
        T2.config(state=DISABLED)
        T2.pack()
        #self.l2=Label(top,text=FEILD_1)
        #self.l2.pack()
        self.e1=Entry(top)
        self.e1.insert(0,"116")
        self.e1.pack()
        T3 = Text(top, height=8, bg='lightgrey', relief='flat')
        T3.insert(END, FEILD_2)
        T3.config(state=DISABLED)
        T3.pack()
        #self.l3=Label(top,text=FEILD_2)
        #self.l3.pack()
        self.e2=Entry(top)
        self.e2.insert(0,"y")
        self.e2.pack()
        T4 = Text(top, height=8, bg='lightgrey', relief='flat')
        T4.insert(END, DISCLAIMER)
        T4.config(state=DISABLED)
        T4.pack()
        #self.l4=Label(top,text=DISCLAIMER)
        #self.l4.pack()
        self.b=Button(top,text='Ok',command=self.cleanup)
        self.b.pack()
        Toplevel.focus_force(top)
    def cleanup(self):
        self.value= self.e1.get(),self.e2.get()
        self.top.destroy()
		

		
parser = SafeConfigParser()
parser.read('settings.ini')

settings = None

try:
    termWidth = int(parser.get("Settings", 'Terminal_Width'))
    sendData  = parser.get("Settings", 'Send_Useage_Data')
    settings  = True
except:
    settings = False
	
if (settings == False):
    window = configWindow(root)

    root.wait_window(window.top)
	
    termWidth = int(window.value[0])
	
    if (window.value[1][0].lower() == 'y'):
        sendData = True
    else:
        sendData = False
		
    parser.add_section('Settings')
    parser.set('Settings', 'Terminal_Width', str(termWidth))
    parser.set('Settings', 'Send_Useage_Data',str(sendData))
	
    with open('settings.ini', 'w') as configfile:
        parser.write(configfile)
		
		
		
def drawReticule(cursorPix, x, y):

    cursorPix[x,y] = (255,0,0)

    cursorPix[(x + 2)%256,y] = (255,0,0)		
    cursorPix[(x + 3)%256,y] = (255,0,0)	
    cursorPix[(x + 4)%256,y] = (255,0,0)	

    cursorPix[(x - 2)%256,y] = (255,0,0)	
    cursorPix[(x - 3)%256,y] = (255,0,0)	
    cursorPix[(x - 4)%256,y] = (255,0,0)	
	
    cursorPix[x,(y + 2)%256] = (255,0,0)	
    cursorPix[x,(y + 3)%256] = (255,0,0)
    cursorPix[x,(y + 4)%256] = (255,0,0)
	
    cursorPix[x,(y - 2)%256] = (255,0,0)
    cursorPix[x,(y - 3)%256] = (255,0,0)
    cursorPix[x,(y - 4)%256] = (255,0,0)
	
    return cursorPix
	
def auto(ruleNum , length, printBool):


    init = np.zeros((length), dtype=np.uint8)
    count = 0
    for element in init:
        init[count] = random.randint(0,1)
        if printBool and init[count] == 1:
            print (u"\u2588", end="")
        elif printBool:
            print (" ", end="")
        count = count + 1

    if (not printBool):
        image = np.zeros((length, length), dtype=np.uint8)
		
    #if (printBool):
    #    print ("~~~~~~~~~~~~~~ %s ~~~~~~~~~~~~~~~~~" % ruleNum)

    rule = BitArray(uint=ruleNum, length=16)
	
    rule = rule[::-1]  # this is so the endian of the rule matches the code that create the image
	
	# 0101 0110 0110 0110

    # rule[0] = 0	rule[1] = 1
	
    end = init.shape[0]

    frame1 = init
    frame2 = np.zeros_like(frame1, dtype=np.uint8)

    oldDelta = 2.0
    newDelta = 1.0

    direction = 0

    count = 0

    #for j in range(4000):
	
    if (printBool):
        limit = 40
    else:
        limit = length
	
    while (count < limit):

        oldDelta = newDelta

        summation = 0 

        if (printBool):
            print ('')
        for i in range(end):
  
            ll  = int(frame1[(i-2)%end])
            l   = int(frame1[(i-1)%end])
            #c   = int(frame1[i])
            r   = int(frame1[(i+1)%end])
            rr  = int(frame1[(i+2)%end])

            frame2[i] = int(rule[int('%s%s%s%s' %(ll,l,r,rr),2)])   # take neighboorhood and look up output from rule


            if (frame2[i] == ll):
                direction = direction - 1
            if (frame2[i] == l):
                direction = direction - 1
            if (frame2[i] == rr):
                direction = direction + 1
            if (frame2[i] == r):
                direction = direction + 1

            #print direction

            if printBool and frame2[i] == 1:
                print (u"\u2588", end="")
            elif printBool:
                print (" ", end="")
            #summation = summation + int(frame2[i])
  
        #ratio = 1.0 * summation / end

        #print

        #delta = abs(silver - ratio)

        #newDelta = (oldDelta * 4 + delta) / 5 
        #print ratio #"summation = %s" % summation
        #if printBool:
        #    print delta

        if (not printBool):
            image[count,:] = frame2
		
        count = count + 1
		
        temp   = frame1
        frame1 = frame2
        frame2 = temp

    if (printBool):
        return direction
    else:
        return image
        
		
def click(event):

    global rule
    global baseImage
    global label
    rule = event.x/4 + (event.y /4) * 256
	
    cursor       = baseImage.copy()
    cursorPix    = cursor.load()
    cursorPix    = drawReticule(cursorPix, event.x/4,event.y/4)
    display      = ImageTk.PhotoImage(cursor.resize((2**10, 2**10)).convert("RGB"))
	
    label.configure(image=display)
    label.image = display
	
    print ("X: %03d  Y: %03d  Rule: %05d" % (event.x/4, event.y/4, rule))

def spaceKey(event):

    """
    for i in range(1,20):
        stdout.write("\r%d" % i)
        stdout.flush()
        sleep(.1)
    stdout.write("\n")

    """

    global termWidth
    global sendData
	
    lab= Label(root, text = 'X: %04d Y: %03d Rule: %05d' %(event.x, event.y, rule))
    lab.pack()
	
    print (rule)
	
    direction = auto(rule, termWidth, True)   # this actually runs the automation
	
    x = rule %  256
    y = rule // 256
		
    #print ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	
    print ("\nX: %03d  Y: %03d  Rule: %05d   Direction: %05d" % (x, y, rule, direction))
	
    if (sendData == 'True'):    # evaluate this alkwardly because it's a string
        urls = ['https://aeiums-map.herokuapp.com/userData']

        params = {'rule':rule}
        rs = (grequests.post(u, data=params) for u in urls)
        grequests.map(rs)
	
    #if (sendData == 'True'):    # evaluate this alkwardly because it's a string
    #    r = async.post('https://aeiums-map.herokuapp.com/userData', data = {'rule':rule})
    #"""


def leftKey(event):

    global rule
    global baseImage
    global label
    rule = rule - 1
	
    x = rule %  256
    y = rule // 256

    cursor         = baseImage.copy()
    cursorPix      = cursor.load()
    cursorPix      = drawReticule(cursorPix,x,y)
    display        = ImageTk.PhotoImage(cursor.resize((2**10, 2**10)).convert("RGB"))
    label.configure(image=display)
    label.image = display
	
    print ("X: %03d  Y: %03d  Rule: %05d" % (x, y, rule))

def rightKey(event):

    global rule
    global baseImage
    global label
    rule = rule + 1
	
    x = rule %  256
    y = rule // 256
	
    cursor         = baseImage.copy()
    cursorPix      = cursor.load()
    cursorPix      = drawReticule(cursorPix,x,y)
    display        = ImageTk.PhotoImage(cursor.resize((2**10, 2**10)).convert("RGB"))
    label.configure(image=display)
    label.image = display

    print ("X: %03d  Y: %03d  Rule: %05d" % (x, y, rule))
	
def upKey(event):

    global rule
    global baseImage
    global label
    rule = (rule - 256) % 2**16
	
    x = rule %  256
    y = rule // 256

    cursor         = baseImage.copy()
    cursorPix      = cursor.load()
    cursorPix      = drawReticule(cursorPix,x,y)
    display        = ImageTk.PhotoImage(cursor.resize((2**10, 2**10)).convert("RGB"))
    label.configure(image=display)
    label.image = display
	
    print ("X: %03d  Y: %03d  Rule: %05d" % (x, y, rule))

def downKey(event):

    global rule
    global baseImage
    global label
    rule = (rule + 256) % 2**16
	
    x = rule %  256
    y = rule // 256

    cursor         = baseImage.copy()
    cursorPix      = cursor.load()
    cursorPix      = drawReticule(cursorPix,x,y)
    display        = ImageTk.PhotoImage(cursor.resize((2**10, 2**10)).convert("RGB"))
    label.configure(image=display)
    label.image = display
	
    print ("X: %03d  Y: %03d  Rule: %05d" % (x, y, rule))

IMAGE_SETTINGS_1 = """Please enter the dimension of the image you want to save."""

IMAGE_SETTINGS_2 = """Please enter the filename. (.png will be added automatically)"""

	
class imageWindow(object):
    def __init__(self,master):
        top=self.top=Toplevel(master)
        self.l1=Label(top,text=IMAGE_SETTINGS_1)
        self.l1.pack()
        self.e1=Entry(top)
        self.e1.insert(10,"512")
        self.e1.pack()
        self.l2=Label(top,text=IMAGE_SETTINGS_2)
        self.l2.pack()
        self.e2=Entry(top)
        self.e2.pack()
        self.b=Button(top,text='Ok',command=self.cleanup)
        self.b.pack()
        Toplevel.focus_force(top)
    def cleanup(self):
        print("Processing image: '%s.png'" % self.e2.get())
        binaryImageValues = auto(rule, int(self.e1.get()), False)
        output_img = np.multiply(binaryImageValues, 255)
        im = Image.fromarray( output_img.astype('uint8'))
        im.save('%s.png' % self.e2.get())
        if (sendData == 'True'):    # evaluate this alkwardly because it's a string
            urls = ['https://aeiums-map.herokuapp.com/userDataIm']
            params = {'rule':rule}
            rs = (grequests.post(u, data=params) for u in urls)
            grequests.map(rs)
		
        #if (sendData == 'True'):    # evaluate this alkwardly because it's a string
        #    r = async.post('https://aeiums-map.herokuapp.com/userDataIm', data = {'rule':rule})
        print("Done")
        self.top.destroy()
		
def imagefunc(event):

    global root
	
    window = imageWindow(root)

    root.wait_window(window.top)

root.bind('<Button-1>', click)
	
root.bind('<Left>' , leftKey)
root.bind('<a>'    , leftKey)
root.bind('<Right>', rightKey)
root.bind('<d>'    , rightKey)
root.bind('<Up>'   , upKey)
root.bind('<w>'    , upKey)
root.bind('<Down>' , downKey)
root.bind('<s>'    , downKey)

root.bind('<Control-KeyPress-space>'  , imagefunc)

root.bind('<space>', spaceKey)

root.mainloop()
