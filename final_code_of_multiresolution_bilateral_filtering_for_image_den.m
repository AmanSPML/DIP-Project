% Step 1: Load the input image
input_image = imread ("C:\Users\Let`s engineer\Downloads\Digital Image Processing\Ground truth image for multiresolution bilateral filtering.jpg");  % Replace with the actual path to your grayscale image.

    % Display the input image
figure;
subplot(1,3,1);
imshow(input_image);
title('Input Image');
axis off;

% Step 2: Add noise to the input image (you can change the type and parameters of noise)
noise_type = 'gaussian';
mean = 0;
variance = 1000;
sigma = sqrt(variance);
noise = normrnd(mean, sigma, size(input_image));
noised_input = double(input_image) + noise;

    % Display the noised input image
subplot(1,3,2);
imshow(uint8(noised_input));
title('Noised Input Image with the SNR value of 15.20');
axis off;

% Step 3: Perform wavelet decomposition
[cA_o, cH_o, cV_o, cD_o] = dwt2(noised_input, 'haar');
                                                                                                                                                                            
    % Now, to get the second level of coefficients for cA, cH, cV, and cD
[cA_2nd, cH_2nd, cV_2nd, cD_2nd] = dwt2(cA_o, 'haar'); % cA_2nd, cH_2nd, cV_2nd, and cD_2nd now represent the second-level coefficients
                                                                                    
                                                                                     
% Step 4: Apply bilateral filtering to the approximation subband of level 2.

approximation_filtered_level2 = imbilatfilt(cA_2nd, 31 ,1.5);

% Step 5: Calculating the threshold value using the Visushrink strategy.
[THR, SORH, KEPAPP] = ddencmp('den', 'wv', noised_input);
threshold = THR; 

% Step 6: Applying the wavelet thresholding to the second level of detailed coefficients
cH_2ndthresh = wthresh(cH_2nd, 's', threshold);
cV_2ndthresh = wthresh(cV_2nd, 's', threshold);
cD_2ndthresh = wthresh(cD_2nd, 's', threshold);


% Step 7: Combining the approximate coefficients and detail coefficients at the second level.

reconstruct_approx_level2 = idwt2(approximation_filtered_level2, cH_2ndthresh, cV_2ndthresh, cD_2ndthresh, 'haar');

% Step 8: Bilteral filtering on the reconstructed approximation coefficients of the first level.
bilat_rec_approx_level2 = imbilatfilt(reconstruct_approx_level2, 31, 1.5);

% Step 9: Thresholding the level1 detailed coefficients
threshold = THR;  % You may need to adjust this threshold value
cH_thresh = wthresh(cH_o, 's', threshold);
cV_thresh = wthresh(cV_o, 's', threshold);
cD_thresh = wthresh(cD_o, 's', threshold);


% Step 10: Reconstructing the final output image that has to be passed through the final bilateral filter

final_rec_image = idwt2(bilat_rec_approx_level2, cH_thresh, cV_thresh, cD_thresh, 'haar');

% Step 11: Final bilateral filtering

denoised_image = imbilatfilt(final_rec_image, 31, 1.5);
                                                                                         
    % Display the denoised output image
subplot(1,3,3);
imshow(uint8(denoised_image));
title('Denoised Output Image, with SNR of 24.71');
axis off;

% Show the plot
sgtitle('Denoising of Grayscale Image Using Multiresolution Framework', 'FontSize', 20);

% Calculate the SNR value of output image
input_image = double(input_image);
denoised_image = double(denoised_image);
snr_value = 10 * log10(sum(sum(input_image.^2)) / sum(sum((input_image - denoised_image).^2)));
fprintf('SNR of the denoised image: %.2f dB\n', snr_value);

snr_value_noisy = 10 * log10(   sum(sum(input_image.^2))   /   sum(sum((input_image - double(noised_input)).^2))   );
fprintf('SNR of the noisy image: %.2f dB\n', snr_value_noisy);

