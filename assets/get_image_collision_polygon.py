import sys
import cv2
import numpy as np

if len(sys.argv) != 2:
    print('Please use calling convention: python3 {this_script} [image_path]')
    exit(-1)
#print(sys.argv[1])

image_path = sys.argv[1]
img = cv2.imread(image_path, cv2.IMREAD_COLOR)

img_height = img.shape[0]
img_width = img.shape[1]

#cv2.imshow('test', img)

edged = cv2.Canny(img, 10, 240)
#cv2.imshow('test canny', edged)

contours, _ = cv2.findContours(edged.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_TC89_L1)
contours = sorted(contours, key = cv2.contourArea, reverse = True)

contours_image = img.copy()
contour = list(contours[len(contours) - 1])
#print(len(contours), len(contour))
cv2.drawContours(contours_image, contour, -1, (0, 255, 0), 9)

cv2.namedWindow('image', cv2.WINDOW_NORMAL)
cv2.imshow('image', contours_image)

print('polygon = PoolVector2Array( ', end='', sep='')
for i in range(len(contour)):
    if i < len(contour) - 1:
        print(contour[i][0][0] - img_width / 2, ', ', contour[i][0][1] - img_height / 2, ', ', end='', sep='')
    else:
        print(contour[i][0][0] - img_width / 2, ', ', contour[i][0][1] - img_height / 2, ' )', end='', sep='')

cv2.waitKey(0)
cv2.destroyAllWindows()
