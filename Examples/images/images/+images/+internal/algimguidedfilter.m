function B = algimguidedfilter(A, G, filtSize, inversionEpsilon, subsampleFactor)
% Main algorithm used by imguidedfilter function. See imguidedfilter.m for
% more details.

% The syntax algimguidedfilter(A, G, filtSize, inversionEpsilon, subsampleFactor)
% exposes the "Fast Guided Filter" algorithm by Kaiming He and Jian Sun.
% http://arxiv.org/abs/1505.00996. This is an approximate guided filter
% with improved computational speed.

% No input validation is done in this function.

% Copyright 2013-2016 The MathWorks, Inc.

sizeA = [size(A) 1];
sizeG = [size(G) 1];

doMultiChannelCovProcessing  = sizeG(3) > sizeA(3); % Represents condition when color covariance guided filter is required. Also, at this point, A and G have same number of channels or if not that, then only 1 or 3 channels.
isGuidanceChannelReuseNeeded = sizeG(3) < sizeA(3);

approximateGuidedFilter = nargin >= 5;
if approximateGuidedFilter
    % Adjust filtSize according to subsampleFactor
    % Note: This will have the effect of always returning an odd kernel
    % length in each dimension. The choice to use approximate guided
    % filtering always results in an odd sized kernel.
    filterRadius = (filtSize-1)/2;
    oddFiltDim = all(mod(filtSize,2) == 1);
    assert(oddFiltDim,'Fast guided filter is not well defined for even filter dimensions');
    goodApproximation = all(filterRadius/subsampleFactor >= 1);
    assert(goodApproximation,'subsampleFactor is too large for filter radius.');
    filterRadius = round(filterRadius/subsampleFactor);
    filtSize = 2*filterRadius+1;
else
    subsampleFactor = 1; % Make the sampling code fall through
end

% Use integral filtering for integer types if the filter kernel is big
% enough. Don't use integral images for floating point inputs to preserve
% NaN/Inf behavior for compatibility reasons. For approximate guided
% filter, go ahead and allow NaN/Inf to propogate in integral domain.
useIntegralFiltering = chooseFilterRegime(filtSize) &&...
    (~isfloat(A) || approximateGuidedFilter) && ~islogical(A);

orignalClassA = class(A);

% Cast A and G to double-precision floating point for computation
A = cast(A,'double'); % No-op when A is double
G = cast(G,'double');

B = zeros(size(A), 'like', A);

if ~doMultiChannelCovProcessing
    
    for k = 1:sizeA(3)
        
        P = A(1:subsampleFactor:end,1:subsampleFactor:end,k);
        
        if isGuidanceChannelReuseNeeded
            I = G(:,:,1);
        else
            I = G(:,:,k);
        end
        
        Iprime = I(1:subsampleFactor:end,1:subsampleFactor:end);
                
        % From [1] - Algorithm 1: Equation Group 1
        meanI  = meanBoxFilter(Iprime, filtSize, useIntegralFiltering);
        meanP  = meanBoxFilter(P, filtSize, useIntegralFiltering);
        corrI  = meanBoxFilter(Iprime.*Iprime, filtSize, useIntegralFiltering);
        corrIP = meanBoxFilter(Iprime.*P, filtSize, useIntegralFiltering);
        
        % From [1] - Algorithm 1: Equation Group 2
        varI  = corrI - meanI.*meanI;
        covIP = corrIP - meanI.*meanP;
        
        % From [1] - Algorithm 1: Equation Group 3
        a = covIP ./ (varI + inversionEpsilon);
        b = meanP - a.*meanI;
        
        % From [1] - Algorithm 1: Equation Group 4
        meana = meanBoxFilter(a, filtSize, useIntegralFiltering);
        meanb = meanBoxFilter(b, filtSize, useIntegralFiltering);
                             
        if approximateGuidedFilter
          meana = imresize(meana,size(I),'bilinear');
          meanb = imresize(meanb,size(I),'bilinear');
        end
        
        % From [1] - Algorithm 1: Equation Group 5
        B(:,:,k) = meana.*I + meanb;
    end
    
else % Do color covariance-based filtering
    
    % Computing Eqn. 19 from [1].         
    % Note that the system of equations in Eqn. 19 is solved using Cramer's
    % rule using closed-form 3x3 matrix inversion.
    
    Iprime = G(1:subsampleFactor:end,1:subsampleFactor:end,:);
    meanIrgb = meanBoxFilter(Iprime,filtSize,useIntegralFiltering);
    
    meanIr = meanIrgb(:,:,1);
    meanIg = meanIrgb(:,:,2);
    meanIb = meanIrgb(:,:,3);
    
    P = A(1:subsampleFactor:end,1:subsampleFactor:end,:);
    meanP  = meanBoxFilter(P,filtSize, useIntegralFiltering);
    
    IP = bsxfun(@times, Iprime, P);
    corrIrP = meanBoxFilter(IP(:,:,1),filtSize, useIntegralFiltering);
    corrIgP = meanBoxFilter(IP(:,:,2),filtSize, useIntegralFiltering);
    corrIbP = meanBoxFilter(IP(:,:,3),filtSize, useIntegralFiltering);
    
    varIrr = meanBoxFilter(Iprime(:,:,1).*Iprime(:,:,1),filtSize, useIntegralFiltering) - meanIr .* meanIr ...
        + inversionEpsilon;
    varIrg = meanBoxFilter(Iprime(:,:,1).*Iprime(:,:,2),filtSize, useIntegralFiltering) - meanIr .* meanIg;
    varIrb = meanBoxFilter(Iprime(:,:,1).*Iprime(:,:,3),filtSize, useIntegralFiltering) - meanIr .* meanIb;
    varIgg = meanBoxFilter(Iprime(:,:,2).*Iprime(:,:,2),filtSize, useIntegralFiltering) - meanIg .* meanIg ...
        + inversionEpsilon;
    varIgb = meanBoxFilter(Iprime(:,:,2).*Iprime(:,:,3),filtSize, useIntegralFiltering) - meanIg .* meanIb;
    varIbb = meanBoxFilter(Iprime(:,:,3).*Iprime(:,:,3),filtSize, useIntegralFiltering) - meanIb .* meanIb ...
        + inversionEpsilon;
    
    covIrP = corrIrP - meanIr .* meanP;
    covIgP = corrIgP - meanIg .* meanP;
    covIbP = corrIbP - meanIb .* meanP;
    
    invMatEntry11 = varIgg.*varIbb - varIgb.*varIgb;
    invMatEntry12 = varIgb.*varIrb - varIrg.*varIbb;
    invMatEntry13 = varIrg.*varIgb - varIgg.*varIrb;
    
    covDet = (invMatEntry11.*varIrr)+(invMatEntry12.*varIrg)+ ...
        (invMatEntry13.*varIrb);
    
    a = zeros(size(P), 'like', P); % Variable 'a' in Eqn. 19 in [1]
    
    a(:,:,1) = ((invMatEntry11.*covIrP) + ...
        ((varIrb.*varIgb - varIrg.*varIbb).*covIgP) + ...
        ((varIrg.*varIgb - varIrb.*varIgg).*covIbP))./covDet;
    
    a(:,:,2) = ((invMatEntry12.*covIrP) + ...
        ((varIrr.*varIbb - varIrb.*varIrb).*covIgP) + ...
        ((varIrb.*varIrg - varIrr.*varIgb).*covIbP))./covDet;
    
    a(:,:,3) = ((invMatEntry13.*covIrP) + ...
        ((varIrg.*varIrb - varIrr.*varIgb).*covIgP) + ...
        ((varIrr.*varIgg - varIrg.*varIrg).*covIbP))./covDet;
    
    % From [1] - Equation 20
    b = meanP - (a(:, :, 1).*meanIr) - (a(:, :, 2).*meanIg) ...
        - (a(:, :, 3).*meanIb);
    
    % From [1] - Equation 21
    a = meanBoxFilter(a, filtSize, useIntegralFiltering);
    b = meanBoxFilter(b, filtSize, useIntegralFiltering);
    
    if approximateGuidedFilter
        a = imresize(a,[size(G,1),size(G,2)],'bilinear');
        b = imresize(b,[size(G,1),size(G,2)],'bilinear');
    end
    
    B = sum(a.*G, 3) + b;
    
end

if strcmp(orignalClassA,'logical') %#ok<ISLOG>
    b = isnan(B); % Re-using variable 'b' to save memory
    B(b) = A(b);  % Do not filter pixels with NaN values
end

B = cast(B,orignalClassA);

end

function useIntegralFiltering = chooseFilterRegime(filtSize)

minKernelElementsForIntegralFiltering = images.internal.getBoxFilterThreshold();
useIntegralFiltering = prod(filtSize) >= minKernelElementsForIntegralFiltering;

end

function I = meanBoxFilter(I, filtSize, useIntegralFiltering)

numKernelElements = prod(filtSize);

if useIntegralFiltering
    Ipad = replicatePadImage(I,filtSize);
    intI = integralImage(Ipad);
    
    % We cannot use the integralFilter interface because it only supports
    % odd kernels sizes. So we use the internal MEX interface which
    % supports this if the image is padded correctly.
    I = images.internal.boxfiltermex(intI, filtSize, 1/numKernelElements, 'double', size(I));
else
    h = ones(filtSize)/numKernelElements;
    I = imfilter(I, h, 'replicate');
end

end


function I = replicatePadImage(I,filtSize)

filtCenter = floor((filtSize + 1)/2);
padSize = filtSize - filtCenter;

method = 'replicate';

nonSymmetricPadShift = 1 - mod(filtSize,2);
prePadSize = padSize;
prePadSize(1:2) = padSize(1:2) - nonSymmetricPadShift;

if any(nonSymmetricPadShift==1)
    I = padarray(I, prePadSize, method, 'pre');
    I = padarray(I, padSize, method, 'post');
else
    I = padarray(I, padSize, method, 'both');
end
end
