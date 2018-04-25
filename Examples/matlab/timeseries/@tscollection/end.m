function index = end(this,position,numindices)
%END  Overloaded END for tscollection object
%
%   TSC(end,:) returns a new tscollection object which contains only the
%   last sample of TSC.
%
%   TSC(:,end) returns a new time series object which contains only the
%   last time series object stored in TSC.
%
%   See also SUBSREF, SUBSASGN.

%   Copyright 2005-2006 The MathWorks, Inc.

if position == 1
    index = this.Length;
elseif position == 2
    index = length(gettimeseriesnames(this));
end