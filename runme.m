%EEE 508 - Fall 2022
%Project 1- Image Denoising using suband wavelet transform.

%A walk through of the project:
%Step 1: Reading the data. The given images are 512x512-8bit imaage. 
clc
close all;
clear all;
% One of the given imge is a clear black and white image.
Orignal=imread('lena512.bmp');
%The other is a noisy version of the same. 
Noisy=imread('lena512noisy.bmp');
%In this initial step, the Fast Fourier Transform of the noisy image is plotted. 
N_fft = log(abs(fftshift(fft2(Noisy)))+1); 
%The following show the Image, the noisy version and the FFT of the noisy image:
figure();
subplot(221); 
imshow(Orignal)
title('original image without noise')
subplot(222);
imshow(Noisy); 
title('Original Image wit Noise');
subplot(223);
imshow(N_fft,[]); 
title('FFT of Noisy Image');

%Step 2: 16-band dyadic decomposition.   
%The 16-band dyadic decomposition is performed by using the inbuilt MATLAB function "[A,H,V,D] = swt2(X,N,wname) %returns the approximation coefficients A and the horizontal, vertical, and diagonal detail coefficients H, V, and D, respectively, %of the stationary 2-D wavelet decomposition of the image X at level N using the wavelet wname." Since 16 bands are needed, %a 5 level swt2 would satisfy the requirments. 
[A,H,V,D] = swt2(Noisy,5,'haar');
%Step 3: Reconstruction.[1]
%Designed a for loop to reconstruct approximation at Level 5-1 taking the detailsdetails from coefficients. 
temp = zeros(size(A));
A_temp = temp;
A_temp(:,:,5) = iswt2(A,temp,temp,temp,'haar');
H_temp = temp; V_temp = temp; D_temp = temp;
for i = 1:5
temp_tensor = temp; 
temp_tensor(:,:,i) = H(:,:,i);
H_temp(:,:,i) = iswt2(temp,temp_tensor,temp,temp,'haar');
temp_tensor = temp; 
temp_tensor(:,:,i) = V(:,:,i);
V_temp(:,:,i) = iswt2(temp,temp,temp_tensor,temp,'haar');
temp_tensor = temp; 
temp_tensor(:,:,i) = D(:,:,i);
D_temp(:,:,i) = iswt2(temp,temp,temp,temp_tensor,'haar');
end
%My next goal was to reconstruct and display approximations at Levels 1, 2, 3, 4 from approximation at Level 5 and details at Levels 1, 2, 3, 4 and 5.
A_temp(:,:,4) = A_temp(:,:,5) + H_temp(:,:,5) + V_temp(:,:,5) + D_temp(:,:,5);
A_temp(:,:,3) = A_temp(:,:,4) + H_temp(:,:,4) + V_temp(:,:,4) + D_temp(:,:,4);
A_temp(:,:,2) = A_temp(:,:,3) + H_temp(:,:,3) + V_temp(:,:,3) + D_temp(:,:,3);
A_temp(:,:,1) = A_temp(:,:,2) + H_temp(:,:,2) + V_temp(:,:,2) + D_temp(:,:,2);
%Step 4: Set the required High frequencies to zero.
%Used a zero matrix of size 512x512 to force the requires bands to 0. 
force_zero = zeros(size(Noisy));
%1 highest freq zero
reconstruct_1 = iswt2(A_temp(:,:,1), H_temp(:,:,1), V_temp(:,:,1), force_zero,'haar');
% 3 highest freq zero
reconstruct_2 = iswt2(A_temp(:,:,1), force_zero, force_zero, force_zero,'haar');
%6 highest freq zero
reconstruct_3 = iswt2(A_temp(:,:,2), force_zero, force_zero, force_zero,'haar');
%Found the fourier transform of the noisy image when 1st,3rd and 6th highest frequency are zero resppectively. 
fft_1 = log(abs(fftshift(fft2(reconstruct_1)))+1);
fft_2 = log(abs(fftshift(fft2(reconstruct_2)))+1);
fft_3 = log(abs(fftshift(fft2(reconstruct_3)))+1);
%The following displays the  reconstructed image in all three cases:
figure(); 
colormap gray
subplot(221);
imagesc(reconstruct_1);
title('Reconstruction')
subtitle('Setting 1st highest subband zero');
subplot(222);
imagesc(reconstruct_2);
title('Reconstruction')
subtitle('Setting 3rd highest subband zero');subplot(223);
imagesc(reconstruct_3);
title('Reconstruction')
subtitle('Setting 6th highest subband zero');figure();
%The following displays the fourier transform of the three cases:
figure();
subplot(221);
imshow(fft_1,[]);
title('highest subband zero');
subplot(222);
imshow(fft_2,[]);
title('3 highest subband zero');
subplot(223);
imshow(fft_3,[]);
title('6 highest subband zero');
%Step 6: Modified dyadic decomposiiton, with 22-subbands. 
%The following shows the nomenclature used for each subband in the project.
%The swt2 is used again, but instead of using 5 levels, we level 1 decomposition to diffrent subands. 
%To achive 22 subands, we perform a level two swt2 on the aproximation layer A11 (from the figure shown above).  
[A,H,V,D] = swt2(Noisy,1,'haar');
[D11,D12,D21,D22] = swt2(D,1,'haar');
[H11,H12,H21,H22] = swt2(H,1,'haar');
[V11,V12,V21,V22] = swt2(V,1,'haar');
[A11,A12,A21,A22] = swt2(A,1,'haar');
[AMa,AMh,AMv,AMd] = swt2(A11,2,'haar');
%Step 7: Reconstruction.[1]
%Performing the inverse fourier transform of all the decomposed levels for the reconstruction. 
%On the quantrary a for loop is not used in this as its not the same as the 16-band. 
%Here we can just perform the inverse for the coeficients that aim towards the three given cases,i.e. 3 highest subbands zero,10 highest subbands %zero
temp = zeros(size(D11));
A_temp1 = temp;
A_temp1(:,:,1) = iswt2(A11,temp,temp,temp,'haar');
A_temp2 = temp;
A_temp2(:,:,1) = iswt2(H11,temp,temp,temp,'haar');
A_temp3 = temp;
A_temp3(:,:,1) = iswt2(V11,temp,temp,temp,'haar');
A_temp4 = temp;
A_temp4(:,:,1) = iswt2(D11,temp,temp,temp,'haar');
Aprox_temp = A + H + V + D11;
%For the reconstruction without the 3rd highest frequency, we need A,H,V and D11 from the figure above, and force the rest to zero.
%For the reconstruction without the 10th highest frequency, we need A, Inverse of H11and inverse of V11 from the figure above, and force the rest %to zero.
%For the reconstruction without the 15th highest frequency, we need A11 from the figure above, and force the rest to zero.
reconstruct_3f = iswt2(Aprox_temp, temp, temp, temp,'haar');
reconstruct_10f = iswt2(A, A_temp2, A_temp3, temp,'haar');
reconstruct_15f = iswt2(A11,temp,temp,temp,'haar');
%Found the fourier transform of the noisy image when 3rd, 10th and 15th highest frequency are zero resppectively. 
fft_1_22 = log(abs(fftshift(fft2(reconstruct_3f)))+1);
fft_2_22 = log(abs(fftshift(fft2(reconstruct_10f)))+1);
fft_3_22 = log(abs(fftshift(fft2(reconstruct_15f)))+1);
%The following displays the  reconstructed image in all three cases:
figure(); 
colormap gray
subplot(221); 
imagesc(reconstruct_3f);
title('Reconstruction')
subtitle('Setting 3rd highest subband zero');
subplot(222); 
imagesc(reconstruct_10f);
title('Reconstruction')
subtitle('Setting 10th highest subband zero');
subplot(223); 
imagesc(reconstruct_15f);
title('Reconstruction')
subtitle('Setting 15th highest subband zero');
%The following displays the fourier transform of the three cases:
figure();
subplot(221); 
imshow(fft_1_22,[]);
title('3 highest subbands zero');
subplot(222); 
imshow(fft_2_22,[]);
title('10 highest subbands zero');
subplot(223); 
imshow(fft_3_22,[]);
title('15 highest subbands zero');

