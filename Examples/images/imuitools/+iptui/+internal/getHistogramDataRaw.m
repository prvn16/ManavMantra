function histDataStruct = getHistogramDataRaw(data)
% GETHISTOGRAMDATA Returns data needed to create the image histogram.
%   The fields inside of HISTDATASTRUCT are:
%     histRange      Histogram Range
%     finalBins      Bin locations
%     counts         Histogram counts
%     nBins          Number of bins
%     xMin           Min of data
%     xMax           Max of data

%   Copyright 2005-2014 The MathWorks, Inc.

[hrange, fbins, cnts, numbins, xMin, xMax] = computeHistogramData(data);
histDataStruct.histRange = hrange;
histDataStruct.finalBins = fbins;
histDataStruct.counts    = cnts;
histDataStruct.nbins     = numbins;
histDataStruct.xMin      = xMin;
histDataStruct.xMax      = xMax;

end % getHistogramData

%==========================================================================
function [histRange, finalBins, counts, nbins,xMin,xMax] = computeHistogramData(data)
% This function does the actual computation

xMin = min(data(:));
xMax = max(data(:));
origRange = xMax - xMin;

% Compute Histogram for the image.  The Xlim([minX maxX]) is based on either the
% range of the class or the data range of the image.  In addition, we have to
% consider that users may need "wiggle room" in the xlim.  For example, customers
% may be working on images that have data ranges that are smaller than the display
% range. They may use the tool on several images to come up with a clim range  
% that works for all cases.

cdataType = class(data);

switch (cdataType)
   case {'uint8','int8'}
        nbins = 256;
        [counts, bins]     = imhist(data, nbins);
        calculateFinalBins = @(bins,~) bins;
        calculateNewCounts = @(counts,~) counts;

        calculateMinX      = @(~,~) intmin(cdataType);
        calculateMaxX      = @(~,~) intmax(cdataType);

   case {'uint16', 'uint32', 'int16', 'int32'}
      % The values are set with respect to the first and last bin containing image
      % data instead of the min and max of the datatype. If we didn't do this,
      % then a uint16 or uint32 image with a small data range would have a very
      % squished and not meaningful histogram.
      
      nbins = 512;
      minRange = double(intmin(cdataType));
      maxRange = double(intmax(cdataType));
      
      [counts,  bins]     = imhist(data, nbins);
      calculateFinalBins = @(bins,idx) bins(idx);
      calculateNewCounts = @(counts,idx) counts(idx);
      calculateMinX      = @(bins,idx) max(minRange, bins(idx(1)) - 100);
      calculateMaxX      = @(bins,idx) min(maxRange, bins(idx(end)) + 100);
  
  case {'double','single'}
        % Images with double CData often don't work well with IMHIST. Convert all
        % images to be in the range [0,1] and convert back later if necessary.
        if (xMin >= 0) && (xMax <= 1)
            nbins = 256;
            [counts, bins]     = imhist(data, nbins); %bins is in range [0,1]
            calculateFinalBins = @(bins,~) bins;
            calculateNewCounts = @(counts,~) counts;
            
            calculateMinX      = @(~,~) 0;
            calculateMaxX      = @(~,~) 1;

        else
            if (origRange > 1023) %JM doesn't remember why he chose 1023
                nbins = 1024;
                calculateFinalBins = @(bins,idx) bins(idx);
                calculateNewCounts = @(counts,idx) counts(idx);
                
            elseif (origRange > 255)
                nbins = 256;
                calculateFinalBins = @(bins,~) bins;
                calculateNewCounts = @(counts,~) counts;

            else
                nbins = max(round(origRange + 1), 2);
                calculateFinalBins = @(bins,idx) bins(idx);
                calculateNewCounts = @(counts,idx) counts(idx);

            end

            calculateMinX = @(~,~) min(data(:));
            calculateMaxX = @(~,~) max(data(:));
            
            data = mat2gray(data);
            [counts, bins] = imhist(data, nbins); %bins is in range [0,1]
            
            % Convert back to original data range.
            bins = bins .* origRange + xMin;
            if (origRange > 0.5)
                bins = round(bins); % bins in range of originalData
            end
        end

    otherwise
        error(message('images:imcontrast:classNotSupported'))
end

[counts,idxOfBinsWithImageData] = saturateOverlyRepresentedCounts(counts);
counts = calculateNewCounts(counts,idxOfBinsWithImageData);

finalBins = calculateFinalBins(bins,idxOfBinsWithImageData);
minX = calculateMinX(bins, idxOfBinsWithImageData);
maxX = calculateMaxX(bins, idxOfBinsWithImageData);
histRange = [minX maxX];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [counts,idxOfImage] = saturateOverlyRepresentedCounts(counts)

idx = find(counts ~= 0);
mu = mean(counts(idx));
sigma = std(counts(idx));

% ignore counts that are beyond 4 degrees of standard deviation.These are
% generally outliers.
countsWithoutOutliers = counts(counts <= (mu + 4 * sigma));
idx2 = countsWithoutOutliers ~= 0;
mu2 = mean(countsWithoutOutliers(idx2));

fudgeFactor = 5;
saturationValue = round(fudgeFactor * mu2); %should be an integer

counts(counts > saturationValue) = saturationValue;

%return idx of bins that contain Image Data
if isempty(idx)
    idxOfImage = 1 : numel(counts);
else
    idxOfImage = (idx(1) : idx(end))';
end

end
