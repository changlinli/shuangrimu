---
title: "OpenCV 1.x, Tesseract, and NumPy: Single-Segment Buffer Object Errors"
cover-image: opencv_cover.jpg
author: Rimu Shuang
attribution: 'Redding, Sandy. sandy.redding. "Railroad Crossing". Flickr.
http://www.flickr.com/photos/dotdoubledot/379374457/sizes/o/. Under a Creative
Commons License BY-NC-SA v2.0
(http://creativecommons.org/licenses/by-nc-sa/2.0/).'
subhead: A tale of debugging Single-Segment Buffer Object Errors
tags: opencv
date: 2013-02-10T04:20:08-0500
---

I've been using OpenCV (Open Computer Vision library built with C++) for the past several weeks as part of work on an image processing project. OpenCV and its Python bindings have been great for providing a foundation of algorithms to work from and for the most part I've been happy. 

I did stumble across a rather odd error. OpenCV has a rather fast development cycle that is willing to sacrifice backwards-compatibility for better features and a cleaner API. This is especially true for the Python bindings for OpenCV's C++ libraries, which are generally not as well documented as the native C++ libraries. In this case, the error stemmed from the fact that the two major iterations of OpenCV (OpenCV 1.x and OpenCV 2.x) do not work very well together. 

OpenCV 1.x did not mesh well with other Python modules used for image processing (notably with NumPy and SciPy). A major example was the image format OpenCV 1.x used, a custom format that had to be translated back and forth to be used with those other modules. OpenCV 2.x has rectified that situation by using NumPy arrays for its images. Unfortunately, because of OpenCV's fast development cycle, a lot of other libraries that claim compatibility with OpenCV are only compatible with OpenCV1. 

In my case, I was using Google's Tesseract library for character recognition (and Python-Tesseract for Python bindings). Lo and behold, Python-Tesseract was only compatible for OpenCV1. The code looked like the following:
<pre><code class="prettyprint">
# Python Tesseract bindings
import tesseract
# Importing OpenCV 1.x part of OpenCV 2.x library
import cv2.cv as cv

def detect_words(img):
    """
    Detects words in an image. Returns a string of the words detected. If the
    words are all whitespace, returns None. Adapted from example from 
    Python-Tesseract homepage at http://code.google.com/p/python-tesseract/.

    Keyword arguments:
    img -- the input image that we want to perform detection on
    """
    api = tesseract.TessBaseAPI()
    api.Init(".", "eng", tesseract.OEM_DEFAULT)
    api.SetPageSegMode(tesseract.PSM_AUTO)
    # Tesseract only works with OpenCV1 so have to translate
    cv1img = cv.fromarray(img)
    grey = cv.CreateImage((cv1img.width, cv1img.height), 8, 1)
    cv.CvtColor(cv1img, grey, cv.CV_BGR2GRAY)
    tesseract.SetCvImage(grey, api)
    text = api.GetUTF8Text()
    if text.isspace():
        return None
    else:
        return text
</code></pre>
Strangely, when I imported this into other files using OpenCV2 functions, errors in NumPy started showing up in code that was sequentially BEFORE where <code>detect_words</code> was located. All sorts of simple things started going wrong. OpenCV2 functions that depended on NumPy went bonkers. Even just <code class="prettyprint">numpy.asarray([1, 2, 3])</code> didn't work. They all gave the error <code class="prettyprint lang-python">TypeError: expected a single-segment buffer object</code>. 

I traced it back to taking a slice of a NumPy array which was then run through <code>detect_img</code>. 

After spending an inordinate amount of time with Winpdb, for some reason, if I just copied a NumPy array using the built-in copy method and then used that copy for all my NumPy and OpenCV2 needs. 
<pre><code class=prettyprint>
import numpy as np

# Capture image from source as img...
# Crop img
# This will break if we run detect_words on cropped_img
cropped_img = img[BOTTOM_Y: TOP_Y, LEFT_X: RIGHT_X]
# This will not break
temp_crop = img[BOTTOM_Y: TOP_Y, LEFT_X: RIGHT_X]
cropped_img = temp_crop.copy()
# Do stuff
detect_words(cropped_img)
</code></pre>

I'm still trying to investigate why this is the case, but hopefully for now this is enough to help at least someone trying to bridge the gap between OpenCV1 and OpenCV2. 
