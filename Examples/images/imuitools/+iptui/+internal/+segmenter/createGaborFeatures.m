function gaborFeatures = createGaborFeatures(im)

% Copyright 2016 The MathWorks, Inc.

if size(im,3) == 3
    im = prepLab(im);
end

im = im2single(im);

imageSize = size(im);
numRows = imageSize(1);
numCols = imageSize(2);

wavelengthMin = 4/sqrt(2);
wavelengthMax = hypot(numRows,numCols);
n = floor(log2(wavelengthMax/wavelengthMin));
wavelength = 2.^(0:(n-2)) * wavelengthMin;

deltaTheta = 45;
orientation = 0:deltaTheta:(180-deltaTheta);

g = gabor(wavelength,orientation);
gabormag = images.internal.gaborFilterFFT(im(:,:,1),g,true);

if isempty(gabormag)
    gaborFeatures = [];
    return
end

for i = 1:length(g)
    sigma = 0.5*g(i).Wavelength;
    K = 3;
    gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),K*sigma);
end

% Increases liklihood that neighboring pixels/subregions are segmented
% together
X = 1:numCols;
Y = 1:numRows;
[X,Y] = meshgrid(X,Y);
featureSet = cat(3,gabormag,X);
featureSet = cat(3,featureSet,Y);

featureSet = reshape(featureSet,numRows*numCols,[]);

% Normalize feature set
featureSet = featureSet - mean(featureSet);
featureSet = featureSet ./ std(featureSet);

gaborFeatures = reshape(featureSet,[numRows,numCols,size(featureSet,2)]);

% Add color/intensity into feature set
gaborFeatures = cat(3,gaborFeatures,im);

end

function out = prepLab(in)
%prepLab - Convert L*a*b* image to range [0,1]

out = in;
out(:,:,1)   = in(:,:,1) / 100;  % L range is [0 100].
out(:,:,2:3) = (in(:,:,2:3) + 100) / 200;  % a* and b* range is [-100,100].

end