function tM = cell2mat(tC)
%CELL2MAT Convert the contents of a cell array into a single matrix.
%   M = CELL2MAT(C)
%
%   See also cell2mat, tall.

% Copyright 2016-2017 The MathWorks, Inc.

tC = tall.validateType(tC, upper(mfilename), {'cell'}, 1);
tM = chunkfun(@iCell2mat, tC);


function out = iCell2mat(c)
% Wrapper around cell2mat that marks the instances where we cannot be
% certain about size or type.
if size(c, 1) == 0
    out = matlab.bigdata.internal.UnknownEmptyArray.build();
else
    out = cell2mat(c);
end
