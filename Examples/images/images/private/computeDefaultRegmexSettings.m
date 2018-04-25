function [linearPortionOfTransform, translationVector, optimConfig] = computeDefaultRegmexSettings(...
                                                                        transformType,mref,fref)
% Compute initial transformation parameters.
%   Copyright 2012-2013 The MathWorks, Inc.

nDims = length(mref.ImageSize);

% Compute translation necessary to align geometric centers of two images.
% This is the default initial condition for registration unless a user
% specifies an initial condition.
initTranslation = [mean(mref.XWorldLimits)-mean(fref.XWorldLimits),...
                   mean(mref.YWorldLimits)-mean(fref.YWorldLimits)];
               
if(nDims==3)
    initTranslation(3) = mean(mref.ZWorldLimits)-mean(fref.ZWorldLimits);
end

otherScale  = 1;
angleScale  = 1;
scaleScale  = 1;
versorScale = 1;

% Use the diagonal of the two largest extents as the scale factor for
% translation in each dimension.
fixedSize = [fref.ImageExtentInWorldX fref.ImageExtentInWorldY];
if(nDims==3)
    fixedSize(3) = fref.ImageExtentInWorldZ;    
end

sortedSize       = sort(fixedSize);
maxTranslation   = hypot(sortedSize(1),sortedSize(2));
translationScale = otherScale/maxTranslation;
translationScale = repmat(translationScale, size(initTranslation));

% Initialize transformation parameters by specifying identity matrix for
% the linear portion of the transformation and a translation vector such
% that the geometric centers of the two images are aligned.
linearPortionOfTransform = eye(nDims);
translationVector = initTranslation;
    
% Initialize optimizer scales based on the transformation type.
switch (transformType)
    case 'affine'        
        % Affine transform matrix in row-major order followed by
        % translation vector.
        
        if(nDims==2)

            optimConfig = [...
                otherScale, otherScale,...
                otherScale, otherScale,...
                translationScale];
            
        else            
            
            optimConfig = [...
                otherScale, otherScale, otherScale, ...
                otherScale, otherScale, otherScale, ...
                otherScale, otherScale, otherScale, ...
                translationScale];
            
        end
        
    case 'similarity'        
        if(nDims==2)
            optimConfig = [scaleScale, angleScale, translationScale];

        else            
            optimConfig = [versorScale, versorScale, versorScale,...
                translationScale, ...                
                scaleScale];
        end
        
    case 'rigid'        
        if(nDims==2)
            optimConfig = [angleScale, translationScale];            
        else
            optimConfig = [angleScale, angleScale, angleScale,...
                translationScale];
            
        end        
        
    case 'translation'        
        optimConfig     = translationScale;
        
    otherwise        
        iptassert(false, ...
                  'images:imregister:badTransformType', transformType)
        
end

end