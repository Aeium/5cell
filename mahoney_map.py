import sys
import lmdb
import binascii
from PIL import Image
import numpy as np
import sympy as sp
#from sympy.combinatorics.graycode import bin_to_gray
from decbingray import *

#from hilbert_curve import d2xy

# Mahoney Maps is the thing I was looking for
# http://davidbonal.com/karnaugh-and-mahoney-map-methods-for-minimizing-boolean-expressions/

from scipy.io.wavfile import write
import cv2


def pad(string, length):
    zeros = length - len(string)
    pad = ""
    for i in range(zeros):
        pad += "0"
		
    pad += string
    return pad
	
def index2KarXY(index, imsize):
    bin_key_string   = pad(dec2bin(index),imsize)
    key_x             = bin2gray(bin_key_string[::2])
    key_y             = bin2gray(bin_key_string[1::2])
    numkeyX = bin2dec(key_x)
    numkeyY = bin2dec(key_y)
    return numkeyX, numkeyY
	
def index2KarXY2(index, imsize):
    bin_key_string   = pad(dec2bin(index),imsize)
    key_x1             = bin2gray(bin_key_string[::4])
    key_x2             = bin2gray(bin_key_string[2::4])
    key_y1             = bin2gray(bin_key_string[1::4])
    key_y2             = bin2gray(bin_key_string[3::4])
    numkeyX = bin2dec(key_x1+key_x2)
    numkeyY = bin2dec(key_y1+key_y2)
    return numkeyX, numkeyY

	
def flipRight(x,y,count):
    #print "flipright " + str(count)
    span = (2 ** count)-1
    #print "span   %s" % span
    x = span - x
    return x,y
	
def flipDown (x,y,count):
    #print "flipdown " + str(count) 
    span = (2** count)-1
    #print "span  %s" % span
    y = span - y
    return x,y
	
	
def index2MahoneyXY(index, degree):

    print "index2MahoneyXY bitstring in : %s" % pad(dec2bin(index),degree)
    bin_key_string   = pad(dec2bin(index),degree)[::-1]
    print int(bin_key_string,2)
	
    #first2           = bin_key_string[:2]
    #rest             = bin_key_string[2:]
	
    first7  = bin_key_string[0:7]
    second7 = bin_key_string[9:16]
	
    rest = first7 + second7 #bin_key_string[1:-1]#
	
    #print "index --        " + str(index)
	
    #print "bin_key_string  " + bin_key_string
	
    #print "first2          " + first2
	
    #print "rest:           " + rest
	
    y = int(bin_key_string[7])  #first2[0])
    x = int(bin_key_string[8]) #first2[16])

    """
    count  = 0
    countR = 1
    countD = 1
    for bit in rest:
        #print "bit~~~~~~~" + bit
        if (count % 2 == 1):
            countR = countR + 1
            if(bit == '1'):
                x,y = flipRight(x,y,countR)
        if (count % 2 == 0):
            countD = countD + 1
            if(bit == '1'):			
                x,y = flipDown(x,y,countD)		
        count = count + 1
	"""
	
    count  = 0
    countR = 1
    countD = 1
    for bit in rest:
        #print "bit~~~~~~~" + bit
        if (count < 7):
            countR = countR + 1
            if(bit == '1'):
                x,y = flipRight(x,y,countR)
        else:
            countD = countD + 1
            if(bit == '1'):			
                x,y = flipDown(x,y,countD)		
        count = count + 1
		
    return x, y
	
# these are for inverting the mapping

def flipLeft(x,y,count):
    span = 2**(count/2)-1
    if(x >= (2**(count/2-1))):
        bit = "1"
        x = span - x
    else:
        bit = "0"
    return x,y, bit  
	
def flipUp (x,y,count):
    #print "flipdown " + str(count) 

    span = 2**(count/2)-1         # span is position of furthest edge
    if(y >= (2**(count/2-1))):    # check is for half of span (different order of operation for half instead of -1)
        bit = "1"
        y = span - y
    else:
        bit = "0"
    return x,y, bit  
	
	
def MahoneyXY2index(X,Y,degree):

    bitstring = ""
    flipCountX = 0
    flipCountY = 0
	
    first = True
    while (degree > 2):
    

        if(not first):
            X, Y, bit =  flipUp  (X,Y, degree)
            bitstring += bit
            flipCountY = flipCountY + 1
        if(first):
            X, Y, bit =  flipLeft(X,Y, degree)
            bitstring += bit
            flipCountX = flipCountX + 1			
			
        if (not first):
            degree = degree - 2
            first = True
        else:
            first = False		
			
    if(flipCountX % 2 == 0):    # this is to pick the correct position in the final box
        X = (X+1)%2
    if(flipCountY % 2 == 0):
        Y = (Y+1)%2 
		
			
    bitstring = bitstring + str(X) + str(Y)
    return int(bitstring,2)