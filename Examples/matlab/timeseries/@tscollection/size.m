function s = size(this,varargin) 
%SIZE  Return the size of the tscollection object.
%
%   SIZE(TSC) returns [n m] where n is the length of the time vector, 
%   m is the number of time series members.
%
%   See also ISEMPTY and LENGTH methods.
 
%   Copyright 2005-2011 The MathWorks, Inc.

if nargin==1
   s = [this.length length(gettimeseriesnames(this))];
else
    if isequal(varargin{1},1)
        s = this.Length;
    elseif isequal(varargin{1},2)
        s = length(gettimeseriesnames(this));
    else
        error(message('MATLAB:tscollection:size:badSizeSpec'))
    end
end

