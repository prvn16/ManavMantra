function featureMatchingVisualization_extrinsic(original,distorted,recovered, ...
    inlierOriginal, inlierDistorted, ...
    matchedOriginalLoc, matchedDistortedLoc, ...
    scaleRecovered, thetaRecovered)
% This functions is used for the visualization of the outputs of the
% function VisionrecovertformCodeGeneration_kernel. It does not support
% code generation.

% Show putatively matched points (including outliers)
figure; ax1 = axes;
showMatchedFeatures(original,distorted, ...
    matchedOriginalLoc,matchedDistortedLoc, 'Parent', ax1);
title(ax1, 'Putatively matched points (including outliers)');
legend(ax1, 'Original points','Distorted points');

% Show matching points (inliers only)
figure; ax2 = axes;
showMatchedFeatures(original,distorted, ...
    inlierOriginal, inlierDistorted, 'Parent', ax2);
title(ax2, 'Matching points (inliers only)');
legend(ax2, 'Original points','Distorted points'); 

% show the original and recovered images
figure, imshowpair(original,recovered,'montage')

% display numerical results at the prompt
disp1 = sprintf('scaleRecovered = %f\n', scaleRecovered);
disp2 = sprintf('thetaRecovered = %f\n', thetaRecovered);

disp(disp1);
disp(disp2);


