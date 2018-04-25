function h = timeseries(varargin)

% Copyright 2004-2006 The MathWorks, Inc.

h = tsdata.timeseries;
if nargin==1 && isa(varargin{1},'timeseries') 
    h.tsValue = varargin{1};
elseif nargin==1 && isa(varargin{1},'tsdata.timeseries')
    h.tsValue = varargin{1}.tsValue;
else
    h.tsValue = timeseries(varargin{:});
end
h.Name = h.tsValue.Name;


