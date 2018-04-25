function out = vertcatCellContents(c)
% Helper that performs a vertcat on the contents of a cell array.
%
% This exists as removing a layer of cells is done in the evaluation tight
% loop and the input has a good chance of being scalar. Avoiding vertcat in
% these cases proves to be much faster. Further, when there is an
% incompatible vertical concatenation, we need to ensure the error message
% points the user in the right direction.

%   Copyright 2016-2017 The MathWorks, Inc.

if isscalar(c)
    out = c{1};
else
    try
        out = vertcat(c{:});
    catch err
        if strcmp(err.identifier, 'MATLAB:catenate:dimensionMismatch')
            iHandleInvalidVertcat(c);
        else
            rethrow(err);
        end
    end
end

function iHandleInvalidVertcat(c)
% Handle a vertical concatenation error.
for ii = 1 : numel(c)
    for jj = 2 : numel(c)
        try
            vertcat(c{ii}, c{jj});
        catch
            matlab.bigdata.internal.throw(...
                message('MATLAB:bigdata:array:InvalidVertcatWithSizes', ...
                iGetChunkSizeDisplay(c{ii}), iGetChunkSizeDisplay(c{jj})));
        end
    end
end

matlab.bigdata.internal.throw(...
    message('MATLAB:bigdata:array:InvalidVertcat'));

function str = iGetChunkSizeDisplay(chunk)
% Generate a string that contains both the size and class of the chunk.
sz = size(chunk);
szStr = join(["M", string(sz(2:end))], getTimesCharacter());
str = [char(szStr), ' ', class(chunk)];
