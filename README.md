# Image-Processing
Edge Detection and image enhancement.
1. Desctiption: 
- 16-band dyadic (pyramid) decomposition and 22-band modified pyramid using Sub-band wavelet transform.
- Edge enhancement system using Robert’s gradient convolution masks to generate five gradient images in MATLAB.

2. Outcomes: 
- As we go removing higher frequency components, we achieve better denoising but at the same time we lose detail.
- We do this, as noise usually is at a higher frequency.
- This is seen in the case of 16-suband dyadic decomposition. On the contrary we observe that the detail is not lost in the case of the 22-suband modified dyadic decomposition.
- The modified achieves better results with lesser computation.
- The dark regions in the FFT graphs signify the removing of the frequencies.
