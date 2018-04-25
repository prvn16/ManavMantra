function out = standardizeMissing(in, varargin)
%STANDARDIZEMISSING  Convert to standard missing data
%
%    B = STANDARDIZEMISSING(A,INDICATORS)
%    B = STANDARDIZEMISSING(A,INDICATORS,'DataVariables',DATAVARS)
%
%   See also: STANDARDIZEMISSING, TALL/ISMISSING.

% Copyright 2015-2017 The MathWorks, Inc.

tall.checkIsTall(upper(mfilename), 1, in);
narginchk(2, maxArgsForInput(in));

in = tall.validateType(in, mfilename, ...
    {'numeric', 'logical', 'categorical', ... 
    'datetime', 'duration', ...
    'string', 'char', 'cellstr', ...
    'table', 'timetable'}, 1); 

tall.checkNotTall(upper(mfilename), 1, varargin{:});
checkMissingIndicators(varargin{1}, mfilename);

% All inputs except the first are broadcast and the operation is
% effectively elementwise in that it preserves all dimensions.
out = elementfun(@(x) standardizeMissing(x,varargin{:}), in);
out.Adaptor = in.Adaptor;
end

function n = maxArgsForInput(in)
% Determine how many inputs are allowed for this input argument type
% tables allow up to four inputs while all other types allow two.
adaptor = matlab.bigdata.internal.adaptors.getAdaptor(in);
if strcmp(adaptor.Class, 'table')
    n = 4;
else
    n = 2;
end
end
