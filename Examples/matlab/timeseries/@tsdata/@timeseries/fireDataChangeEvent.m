function fireDataChangeEvent(h,varargin)
%FIREDATACHANGEEVENT  Fire datachange event

%   Author(s): James Owen
%   Copyright 2004-2006 The MathWorks, Inc.

if h.DataChangeEventsEnabled
    if nargin>=2
        h.send('datachange',varargin{1});
    else % Must include the source in the dataChangeEvent
        h.send('datachange',tsdata.dataChangeEvent(h,[],[]));
    end
end