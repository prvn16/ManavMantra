function filterSize = validateTwoDFilterSize(filterSize_) %#codegen
%%validateTwoDFilterSize validates filter size for 2-D filter kernels to
% be non-sparse, real, numeric, odd and integer-valued with 1 or 2
% elements.

% Copyright 2015 The MathWorks, Inc.

validateattributes(filterSize_,{'numeric'}, ...
    {'real','nonsparse','nonempty','positive','integer','odd'}, ...
    mfilename,'filterSize');

if isscalar(filterSize_)
    filterSize = [double(filterSize_),double(filterSize_)];
else
    coder.internal.errorIf(numel(filterSize_) ~= 2, ...
        'images:validate:badVectorLength','filterSize',2);
    
    filterSize = [double(filterSize_(1)),double(filterSize_(2))];
end
