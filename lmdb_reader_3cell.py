import sys
import lmdb
import binascii
from PIL import Image
import numpy as np

from hilbert_curve import d2xy

# 34690 dot in the middle

imsize     = 2**8
tilePixels = imsize ** 2
#side       = 2**16
#total      = 2**32

#tiles  =  total // tilePixels

#print (tiles)

lmdb_env = lmdb.open(sys.argv[1])
lmdb_txn = lmdb_env.begin(buffers=True)
lmdb_cursor = lmdb_txn.cursor()

lmdb_env2 = lmdb.open(sys.argv[2])
lmdb_txn2 = lmdb_env2.begin(buffers=True)
lmdb_cursor2 = lmdb_txn2.cursor()

#for i in range(0, tiles):

 #   xTile = i % 16
 #   yTile = i // 16
	
 #   print (i)
 
output_img = np.zeros((imsize, imsize,3))
 
count = 0

champ = 0
 
for key, value in lmdb_cursor:
    numkey   = int(bytes(key), 16)
	
    if (numkey >= 2**16):
        break
    numvalue = np.int32(int(bytes(value), 16))
    print ("count: %d, value: %d" % (count, numvalue))
    count = count + 1

    #x, y = d2xy(16, numkey) 
    x = numkey//imsize
    y = numkey%imsize

    #if(numvalue == 100):	
    #    output_img[x][y][1] = 60#255 #numvalue / 40#* 5#location / 255#255#value
    #else:
    #    output_img[x][y][1] = numvalue * 5
	
    if (numvalue > 0):
        output_img[x][y][0] = 255
	
    #if(numvalue == 100):	
    #    output_img[numkey//imsize][numkey%imsize][1] = 60#255 #numvalue / 40#* 5#location / 255#255#value
    #else:
    #    output_img[numkey//imsize][numkey%imsize][1] = numvalue * 5	
	
    #if(numvalue < 0):
    #    output_img[numkey//256][numkey%256][2] = abs(numvalue)			

count = 0

for key, value in lmdb_cursor2:
    numkey   = int(bytes(key), 16)
	
    if (numkey >= 2**16):
        break
    numvalue = np.int32(int(bytes(value), 16))
    print ("count: %d, value: %d" % (count, numvalue))
    count = count + 1

    #x, y = d2xy(16, numkey) 
    x = numkey//imsize
    y = numkey%imsize

	
    """
    if(numvalue == 100):	
        output_img[x][y][0] = 60#255 #numvalue / 40#* 5#location / 255#255#value
    else:
        output_img[x][y][0] = numvalue * 5
    if(output_img[x][y][0] > 0 and output_img[numkey//imsize][numkey%imsize][1] > 0):
        output_img[x][y][2] = 255  
    """
    if (numvalue == output_img[x][y][0]):
        output_img[x][y][0] = 0
        output_img[x][y][2] = 0
    if (numvalue > output_img[x][y][0]):
        output_img[x][y][2] = 255
        output_img[x][y][0] = 0
        
		
    #if(numvalue == 100):	
    #    output_img[numkey//imsize][numkey%imsize][1] = 60#255 #numvalue / 40#* 5#location / 255#255#value
    #else:
    #    output_img[numkey//imsize][numkey%imsize][1] = numvalue * 5	
		
    #if(output_img[numkey//imsize][numkey%imsize][0] > 0 and output_img[numkey//imsize][numkey%imsize][1] > 0):
    #    output_img[numkey//imsize][numkey%imsize][2] = 255    	
		
    #if(numvalue < 0):
    #    output_img[numkey//256][numkey%256][2] = abs(numvalue)	

	
im = Image.fromarray(output_img.astype('uint8'))
	
im.save('tiles/%s.png' % sys.argv[3])

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