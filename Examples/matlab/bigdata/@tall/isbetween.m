function tf = isbetween(varargin)
%ISBETWEEN Determine if tall array of datetimes are contained in an interval.
%   TF = ISBETWEEN(A,LOWER,UPPER)
%
%   Limitations:
%   tall character vectors are not supported.
%   
%   See also DATETIME/ISBETWEEN.

%   Copyright 2016 The MathWorks, Inc.

narginchk(3,3)
varargin = cellfun(@iMaybeWrapChar, varargin, 'UniformOutput', false);
[varargin{1:nargin}] = tall.validateType(varargin{:}, upper(mfilename), {'datetime','cellstr'}, 1:nargin);
tf = elementfun(@isbetween,varargin{:});
tf = setKnownType(tf, 'logical');
end

function x = iMaybeWrapChar(x)
%covert character vector to cell
if ~istall(x) && ischar(x) && isrow(x)
    x = {x};
end
end
