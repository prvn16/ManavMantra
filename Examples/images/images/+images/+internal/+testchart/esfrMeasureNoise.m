function noiseTable = esfrMeasureNoise(chart)
%eSFRMeasureNoise Perform noise measurements on an esfrChart
%
%   noiseTable = eSFRMeasureNoise(chart) performs noise measurements using
%   the GrayROIs of an esfrChart object.
%   
%   The rows of the noiseTable correspond to individual gray
%   ROIs sequentially numbered as displayed when using the
%   displayChart function. Variables or columns of the noiseTable
%   correspond to the following:
%  
%         1. ROI                      : Index of an ROI
%         2. MeanIntensity_R          : Mean of R channel pixels in a ROI
%         3. MeanIntensity_G          : Mean of G channel pixels in a ROI
%         4. MeanIntensity_B          : Mean of B channel pixels in a ROI
%         5. RMSNoise_R               : Root measn square (RMS) noise of R pixels
%         6. RMSNoise_G               : Root measn square noise of G pixels
%         7. RMSNoise_B               : Root measn square noise of B pixels
%         8. PercentNoise_R           : RMS noise of R expressed as a percentage
%                                       of the maximum of the original chart image datatype
%         9. PercentNoise_G           : RMS noise of G expressed as a percentage
%                                       of the maximum of the original chart image datatype
%        10. PercentNoise_B           : RMS noise of B expressed as a percentage
%                                       of the maximum of the original chart image datatype
%        11. SignalToNoiseRatio_R     : Ratio of signal to noise in R
%        12. SignalToNoiseRatio_G     : Ratio of signal to noise in G
%        13. SignalToNoiseRatio_B     : Ratio of signal to noise in B
%        14. SNR_R                    : Signal to noise ratio in dB (20*log(Signal/Noise)) for R
%        15. SNR_G                    : Signal to noise ratio in dB (20*log(Signal/Noise)) for G
%        16. SNR_B                    : Signal to noise ratio in dB (20*log(Signal/Noise)) for B
%        17. PSNR_R                   : Peak signal to noise ratio in dB for R
%        18. PSNR_G                   : Peak signal to noise ratio in dB for G
%        19. PSNR_B                   : Peak signal to noise ratio in dB for B
%        20. RMSNoise_Y               : RMS noise for Y channel in YCbCr color space
%        21. RMSNoise_Cb              : RMS noise for Cb channel in YCbCr color space
%        22. RMSNoise_Cr              : RMS noise for Cr channel in YCbCr color space
%
%   NOTE
%   ----
%   Use of this function is discouraged as it might change in future
%   releases. Use esfrChart/measureNoise instead.
%
%   Example
%   -------
%
%   I = imread('eSFRTestImage.jpg');
%   chart = esfrChart(I);
%   displayChart(chart);
%   noiseTable = images.internal.testchart.eSFRMeasureNoise(chart);

%   Copyright 2017 The MathWorks, Inc.

imChroma = rgb2ycbcr(chart.Image);
numPatches = chart.numGrayPatches;

intensity_R = zeros(numPatches,1);
intensity_G = zeros(numPatches,1);
intensity_B = zeros(numPatches,1);

noise_meas_R = zeros(numPatches,1);
noise_meas_G = zeros(numPatches,1);
noise_meas_B = zeros(numPatches,1);

noise_meas_Y = zeros(numPatches,1);
noise_meas_Cb = zeros(numPatches,1);
noise_meas_Cr = zeros(numPatches,1);

for i = 1:numPatches
    ROI = chart.GrayROIs(i).ROI;
    intensity_R(i) = mean2(double(chart.GrayROIs(i).ROIIntensity(:,:,1)));
    intensity_G(i) = mean2(double(chart.GrayROIs(i).ROIIntensity(:,:,2)));
    intensity_B(i) = mean2(double(chart.GrayROIs(i).ROIIntensity(:,:,3)));
    
    noise_meas_R(i) = std2(double(chart.GrayROIs(i).ROIIntensity(:,:,1)));
    noise_meas_G(i) = std2(double(chart.GrayROIs(i).ROIIntensity(:,:,2)));
    noise_meas_B(i) = std2(double(chart.GrayROIs(i).ROIIntensity(:,:,3)));
    
    noise_meas_Y(i) = std2(double(imChroma(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3),1)));
    noise_meas_Cb(i) = std2(double(imChroma(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3),2)));
    noise_meas_Cr(i) = std2(double(imChroma(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3),3)));
end

%% Calculate percent noise and SNRs
% Noise expressed as percentage of max pixel value
classRange = getrangefromclass(chart.Image);
classMax = classRange(2);

perc_noise_meas_R = 100*noise_meas_R/classMax;
perc_noise_meas_G = 100*noise_meas_G/classMax;
perc_noise_meas_B = 100*noise_meas_B/classMax;

% Measure singnal to noise ratio
S_by_N_R = intensity_R./noise_meas_R;
S_by_N_G = intensity_G./noise_meas_G;
S_by_N_B = intensity_B./noise_meas_B;

% Measure SNR in dB
SNR_R = 20*log10(S_by_N_R);
SNR_G = 20*log10(S_by_N_G);
SNR_B = 20*log10(S_by_N_B);

% Measure peak SNR in dB
P_SNR_R = 20*log10(classMax./noise_meas_R);
P_SNR_G = 20*log10(classMax./noise_meas_G);
P_SNR_B = 20*log10(classMax./noise_meas_B);

ROI = 1:numPatches;
ROI = ROI';

columnNames = {'ROI',...
    'MeanIntensity_R',...
    'MeanIntensity_G',...
    'MeanIntensity_B',...
    'RMSNoise_R',...
    'RMSNoise_G',...
    'RMSNoise_B',...
    'PercentNoise_R',...
    'PercentNoise_G',...
    'PercentNoise_B',...
    'SignalToNoiseRatio_R',...
    'SignalToNoiseRatio_G',...
    'SignalToNoiseRatio_B',...
    'SNR_R',...
    'SNR_G',...
    'SNR_B',...
    'PSNR_R',...
    'PSNR_G',...
    'PSNR_B',...
    'RMSNoise_Y',...
    'RMSNoise_Cb',...
    'RMSNoise_Cr'};
noiseTable = table(ROI,intensity_R,intensity_G,intensity_B,...
    noise_meas_R,noise_meas_G,noise_meas_B,...
    perc_noise_meas_R,perc_noise_meas_G,perc_noise_meas_B, ...
    S_by_N_R, S_by_N_G, S_by_N_B,...
    SNR_R, SNR_G, SNR_B, ...
    P_SNR_R, P_SNR_G, P_SNR_B,...
    noise_meas_Y,noise_meas_Cb,noise_meas_Cr, ...
    'VariableNames',columnNames);

variableUnits = {'','','','','','','','','','','','','','dB','dB','dB','dB', ...
    'dB','dB','','',''};
noiseTable.Properties.VariableUnits = variableUnits;
noiseTable.Properties.Description = getString(message('images:esfrChart:NoiseTableDescription'));
noiseTable.Properties.VariableDescriptions = {getString(message('images:esfrChart:ROIIndexVariableDescription')),...
    getString(message('images:esfrChart:MeanIntensity_RVariableDescription')),...
    getString(message('images:esfrChart:MeanIntensity_GVariableDescription')),...
    getString(message('images:esfrChart:MeanIntensity_BVariableDescription')),...
    getString(message('images:esfrChart:RMSNoise_RVariableDescription')),...
    getString(message('images:esfrChart:RMSNoise_GVariableDescription')),...
    getString(message('images:esfrChart:RMSNoise_BVariableDescription')),...
    getString(message('images:esfrChart:PercentNoise_RVariableDescription')),...
    getString(message('images:esfrChart:PercentNoise_GVariableDescription')),...
    getString(message('images:esfrChart:PercentNoise_BVariableDescription')),...
    getString(message('images:esfrChart:SignalToNoiseRatio_RVariableDescription')),...
    getString(message('images:esfrChart:SignalToNoiseRatio_GVariableDescription')),...
    getString(message('images:esfrChart:SignalToNoiseRatio_BVariableDescription')),...
    getString(message('images:esfrChart:SNR_RVariableDescription')),...
    getString(message('images:esfrChart:SNR_GVariableDescription')),...
    getString(message('images:esfrChart:SNR_BVariableDescription')),...
    getString(message('images:esfrChart:PSNR_RVariableDescription')),...
    getString(message('images:esfrChart:PSNR_GVariableDescription')),...
    getString(message('images:esfrChart:PSNR_BVariableDescription')),...
    getString(message('images:esfrChart:RMSNoise_YVariableDescription')),...
    getString(message('images:esfrChart:RMSNoise_CbVariableDescription')),...
    getString(message('images:esfrChart:RMSNoise_CrVariableDescription'))};
end