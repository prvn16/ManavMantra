function s = size(this,varargin) 
%SIZE  Return the size of a time series.
%
%   SIZE(TS) returns [n 1] where n is the length of the time vector.
%
%   See also TIMESERIES/ISEMPTY, TIMESERIES/LENGTH
 
%   Copyright 2005-2010 The MathWorks, Inc.

narginchk(1,2);

if builtin('isempty',this)
    s = [0 0];
    return
end

% Find the size vector
s = [this.TimeInfo.Length 1];


% Deal with additional args
if nargin>=2
    if varargin{1}<=numel(s)
        s = s(varargin{1});
    else
        s = 1;
    end
end
