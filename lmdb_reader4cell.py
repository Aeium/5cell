import sys
import lmdb
import binascii
from PIL import Image
import numpy as np
#import sympy as sp
#from sympy.combinatorics.graycode import bin_to_gray

from hilbert_curve import d2xy
from mahoney_map import index2MahoneyXY, MahoneyXY2index

from scipy.io.wavfile import write
import cv2

# 34690 dot in the middle

imsize     = 256
tilePixels = imsize ** 2
#side       = 2**16
#total      = 2**32

#tiles  =  total // tilePixels

#print (tiles)

lmdb_env = lmdb.open(sys.argv[1])
lmdb_txn = lmdb_env.begin(buffers=True)
lmdb_cursor = lmdb_txn.cursor()

#lmdb_env2 = lmdb.open(sys.argv[2])
#lmdb_txn2 = lmdb_env.begin(buffers=True)
#lmdb_cursor2 = lmdb_txn.cursor()

#for i in range(0, tiles):

 #   xTile = i % 16
 #   yTile = i // 16
	
 #   print (i)
 
output_img   = np.zeros((imsize , imsize))
output_sound = np.zeros((imsize * imsize))
 
count = 0

champ = 0

zerocount = 0

for i in range (0,1):#(257,2048):

    #lmdb_cursor = lmdb_txn.cursor()
 

 
    for key, value in lmdb_cursor:
    #for j in range(0,2**16):
        numkey   = int(bytes(key), 16)
	
        if (numkey) >= 2**16:
            break
        numvalue = np.int32(int(bytes(value), 16))
        #if(numvalue > 0):
        #print (count)
        if numvalue == 0:
            zerocount = zerocount + 1	
        if (numvalue > champ):
            champ = numvalue	
            print ("%s: %s" %(numkey, numvalue))

        output_sound[count] = numvalue

        print numkey
		
        #numkey_x, numkey_y  = d2xy(j,16)
        j = numkey
		
        
        numkey_x, numkey_y = index2MahoneyXY(j, 16)	
        """		
        if (MahoneyXY2index(numkey_x, numkey_y, 16) == j):
            print ("inverse function match %s " % j)
        else:
            print ("NO MATCH!!!          j:%s " % j)
            print ("Inverse try            %s " % MahoneyXY2index(numkey_x, numkey_y, 16))
            print (MahoneyXY2index(numkey_x, numkey_y, 16) == j)
            kill = 1/0			
        count = count + 1		
        """        
		#numkey = (numkey + 32 * i) % (2**16)

        #if (count % 256 == 0):
        #		print count
#for j in range (0, imsize):
	
#    for h in range (0, imsize):
		
            #location = h + (j * imsize)

            #print (location)
			
            #hex = str("0x%0.8x" % location)
			
            #print (hex)
			
            #buf = lmdb_txn.get(hex[2:].encode())
            #value = np.int32(int(bytes(buf), 16))

    #if numvalue > 10:#00000:
    #    numvalue = 10#00000
    #if numvalue < -10:#00000:
    #    numvalue = -10#00000

    #numvalue = numvalue * 25#/ 3921


            #buf2 = lmdb_txn2.get(hex[2:].encode())
            #value = np.int32(int(bytes(buf), 16))			
            #value2 = np.int32(int(bytes(buf2), 16))
            #if value2 > 4000:
            #    value2 = 4000
            #if value2 < -4000:
            #    value2 = -4000

            #value2 = value2 / 16
				
            #output_img[j][h][1]     = value2
			
    #x, y = d2xy(16, numkey)
    #output_img[x][y] =  (numkey % 8)#13) * (numkey % 27)
			

        #if(numvalue == 0):	
        #    output_img[numkey_x][numkey_y] = 0#255 #numvalue / 40#* 5#location / 255#255#value
        #else:
        #    output_img[numkey_x][numkey_y] = numvalue * 5
		
        #"""
		
        #if(numvalue == 0):	
        #    output_img[numkey//256][numkey%256] = 0#255 #numvalue / 40#* 5#location / 255#255#value
        #else:
        #    output_img[numkey//256][numkey%256] = numvalue * 5	
        #if(numvalue < 0):
        #    output_img[numkey//256][numkey%256][2] = abs(numvalue)

        mod = i
		
        output_img[numkey_x][numkey_y] =  numvalue * 5 #j # (255 // (mod-1)) #numvalue * 5			
		
		
		#"""
		
    #print "~~~~~" + str(zerocount)
		
    #print output_sound.shape
    #sp = np.fft.fft(output_sound)
    #print sp.shape
	
    #im = Image.fromarray(np.reshape(sp, (256, 256)).astype('uint8'))   #output_img.astype('uint8'))
	
	
    #im.save('tiles-hough/fft-%s.png' % ( sys.argv[2]))
		
    im = Image.fromarray(  output_img.astype('uint8'))
    im.save('inv-mahoney/%s.png' % ( sys.argv[2] ))




    #scaled = np.int16(output_img.flatten()//np.max(np.abs(output_img.flatten())) * 32767)
    #write('audio/%s.wav' % sys.argv[2], 44100, scaled)


"""
for key, value in lmdb_cursor:
    #print ("%s: %s" %(key, value))
    numkey   = int(key, 16)
    numvalue = int(value, 16)
	
    if numvalue > champ:
        print ("NEW CHAMP    %s: %s    ~~~ " %(numkey, numvalue))
        champ = numvalue

    if ((numvalue + .01) / (champ + .01)) > .6:
        print ("close one    %s: %s" %(numkey, numvalue))
"""
