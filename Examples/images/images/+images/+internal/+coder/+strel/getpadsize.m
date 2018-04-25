function [padul, padlr] = getpadsize(varargin)
%GETNHOOD Internal helper function to get structuring element neighborhood.

% Copyright 2013 The MathWorks, Inc.

se = strel(varargin{:});
[padul, padlr] = getpadsize(se);
end