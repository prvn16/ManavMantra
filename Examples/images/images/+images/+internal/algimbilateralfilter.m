function Bout = algimbilateralfilter(Ain, NeighborhoodSize, RangeSigma, SpatialSigma, PadString, PadVal)

% Copyright 2017 The MathWorks, Inc.

%#codegen

isColor = size(Ain,3)==3;

% Always work in floating point for most accuracy
origClass = class(Ain);
if ~isfloat(Ain)
    A = double(Ain);
else
    A = Ain;
end

B = zeros(size(A), 'like', A);

% Pad (Note NeighborhoodSize is expected to be odd)
padSize = floor(NeighborhoodSize/2);
if strcmpi(PadString, 'constant')
    A = padarray(A, padSize, PadVal, 'both');
else
    A = padarray(A, padSize, PadString, 'both');
end

% (Pre-normalized) Spatial Gaussian weights
spatialWeights = fspecial('gaussian',...
    NeighborhoodSize, SpatialSigma);

rangeSigmaTerm = 2*RangeSigma^2;

isCodegen = ~coder.target('MATLAB');

for col = 1:size(B,2)
    for row = 1:size(B,1)
        % Account offset due to padding
        arow = row+padSize(1);
        acol = col+padSize(2);
        % Extract Neighborhood around current pixel
        ALocalNeighbor = A(arow-padSize(1):arow+padSize(1),...
            acol-padSize(2):acol+padSize(2), :);
        
        % Compute intensity weights
        ACenterPixel = A(arow, acol,:);
        if isColor
            % Euclidean distance. Defer sqrt in distance
            % computation to cancel out .^2 in Gaussian
            % computation.
            if isCodegen                             
                intensityDiff = coder.nullcopy(ALocalNeighbor);
                intensityDiff(:,:,1) = (ALocalNeighbor(:,:,1) - ACenterPixel(1,1,1)).^2;
                intensityDiff(:,:,2) = (ALocalNeighbor(:,:,2) - ACenterPixel(1,1,2)).^2;
                intensityDiff(:,:,3) = (ALocalNeighbor(:,:,3) - ACenterPixel(1,1,3)).^2;
            else
                intensityDiff = (ALocalNeighbor - ACenterPixel).^2;
            end
            intensityDiff = sum(intensityDiff,3);
            intensityWeights = exp(-(intensityDiff) / rangeSigmaTerm);
        else
            intensityDiff = ALocalNeighbor-ACenterPixel;
            intensityWeights = exp(-(intensityDiff).^2 / rangeSigmaTerm);
        end
        
        weights = spatialWeights.*intensityWeights;
        if isColor && isCodegen
            weightedPixels = coder.nullcopy(ALocalNeighbor);
            weightedPixels(:,:,1) = weights.*ALocalNeighbor(:,:,1);
            weightedPixels(:,:,2) = weights.*ALocalNeighbor(:,:,2);
            weightedPixels(:,:,3) = weights.*ALocalNeighbor(:,:,3);
        else
            weightedPixels = weights.*ALocalNeighbor;
        end
        
        B(row,col, :) = sum(sum(weightedPixels,1),2) ./ (sum(weights(:))+eps);
    end
end

Bout = cast(B, origClass);

end
