from __future__ import print_function

from Tkinter import *
from ctypes import windll
from PIL import Image, ImageTk
import numpy as np
import random
from sys import stdout
from time import sleep
from bitstring import BitArray


root = Tk()


rule = 0 #event.x/4 + (event.y /4) * 256

baseImage = Image.open('128.png').convert("RGB")
dispImage =  baseImage.resize((2**10, 2**10))
#image2  =  image.resize(2**10, 2**10)
display  =  ImageTk.PhotoImage(dispImage)
label = Label(root, image=display)
label.pack()


def printline(step):

    count = 0	
    for i in step:	
        if count > 16 and count < 116:
            if (i == 1):
                print ("X", end="")
            else:
                print (" ", end="")
        count = count + 1
		
		
		
def auto(ruleNum , length, printBool):


    init = np.zeros((length), dtype=np.uint8)
    count = 0
    for element in init:
        init[count] = random.randint(0,1)
        if printBool and init[count] == 1:
            print ("X", end="")
        elif printBool:
            print (" ", end="")
        count = count + 1

    #if (printBool):
    #    print ("~~~~~~~~~~~~~~ %s ~~~~~~~~~~~~~~~~~" % ruleNum)

    rule = BitArray(uint=ruleNum, length=16)
	
    #rule = rule[::-1]
	
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
    while count < (40): #newDelta < oldDelta:

        count = count + 1
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
                print ("X", end="")
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

        temp   = frame1
        frame1 = frame2
        frame2 = temp

        #output_img[count,:] = frame1

    return direction #output_img, direction #np.array_equal(frame1, first)
		
		
def click(event):

    global rule
    global baseImage
    global label
    rule = event.x/4 + (event.y /4) * 256
	
    cursor                      = baseImage.copy()
    cursorPix                   = cursor.load()
    cursorPix[event.x/4,event.y/4] = (255,0,0)
    cursor.save('%s.png' % rule)
    display                     = ImageTk.PhotoImage(cursor.resize((2**10, 2**10)).convert("RGB"))
    label.configure(image=display)
    label.image = display

def spaceKey(event):

    """
    for i in range(1,20):
        stdout.write("\r%d" % i)
        stdout.flush()
        sleep(.1)
    stdout.write("\n")

    """

	
    lab= Label(root, text = 'X: %04d Y: %03d Rule: %05d' %(event.x, event.y, rule))
    lab.pack()
	
    print (rule)
	
    direction = auto(rule, 116, True)

    x = rule %  256
    y = rule // 256
		
    print ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	
    print ("X: %03d  Y: %03d  Rule: %05d   Direction: %05d" % (x, y, rule, direction))
    #"""


root.bind('<Button-1>', click)


def leftKey(event):

    global rule
    global baseImage
    global label
    rule = rule - 1
	
    x = rule %  256
    y = rule // 256

    cursor         = baseImage.copy()
    cursorPix      = cursor.load()
    cursorPix[x,y] = (255,0,0)
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
    cursorPix[x,y] = (255,0,0)
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
    cursorPix[x,y] = (255,0,0)
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
    cursorPix[x,y] = (255,0,0)
    display        = ImageTk.PhotoImage(cursor.resize((2**10, 2**10)).convert("RGB"))
    label.configure(image=display)
    label.image = display
	
    print ("X: %03d  Y: %03d  Rule: %05d" % (x, y, rule))


root.bind('<Left>', leftKey)
root.bind('<Right>', rightKey)
root.bind('<Up>', upKey)
root.bind('<Down>', downKey)

root.bind('<space>', spaceKey)

root.mainloop()