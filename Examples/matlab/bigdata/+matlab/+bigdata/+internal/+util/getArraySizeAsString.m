function strArr = getArraySizeAsString(dataNDims, dataSize)
%getArraySizeAsString Return a string array of dimensions
%   S = getArraySizeAsString(ND,DIMS) for number of dimensions ND (or NaN if not
%   known), actual dimensions DIMS (with NaN for missing dimensions) returns in
%   S a string array where each element is a correctly-formatted string
%   representing the size in that dimension.

% Copyright 2016 The MathWorks, Inc.

if isnan(dataNDims)
    % No size information at all, MxNx...
    dimStrs = {'M', 'N', '...'};
else
    % Known number of dimensions
    
    % unknownDimLetters are the placeholders we'll use in the size specification
    unknownDimLetters = 'M':'Z';
    
    dimStrs = cell(1, dataNDims);
    for idx = 1:dataNDims
        if isnan(dataSize(idx))
            if idx > numel(unknownDimLetters)
                % Array known to be 15-dimensional, but 15th (or higher) dimension is not
                % known. Not sure how you'd ever hit this.
                dimStrs{idx} = '?';
            else
                dimStrs{idx} = unknownDimLetters(idx);
            end
        else
            dimStrs{idx} = matlab.bigdata.internal.util.formatBigSize(dataSize(idx));
        end
    end
end
strArr = string(dimStrs);
end
