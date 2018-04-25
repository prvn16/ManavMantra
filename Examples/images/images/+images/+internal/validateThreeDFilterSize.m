function filterSize = validateThreeDFilterSize(filterSize)
%%validateThreeDFilterSize validates filter size for 3-D filter kernels to
% be non-sparse, real, numeric, odd and integer-valued with 1 or 3
% elements.

% Copyright 2015 The MathWorks, Inc.

validateattributes(filterSize, {'numeric'}, {'real','nonsparse','nonempty','positive','integer','odd'}, mfilename, 'filterSize');

if isscalar(filterSize)
    filterSize = [filterSize filterSize filterSize];
end

if numel(filterSize)~= 3
    error(message('images:validate:badVectorLength','filterSize',3));
end

if ~isrow(filterSize)
    filterSize = [filterSize(1) filterSize(2) filterSize(3)];
end

filterSize = double(filterSize);

end