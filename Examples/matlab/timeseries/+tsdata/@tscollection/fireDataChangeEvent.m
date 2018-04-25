function fireDataChangeEvent(h,varargin)
%FIREDATACHANGEEVENT

% Copyright 2005-2017 The MathWorks, Inc.

if h.DataChangeEventsEnabled
    h.notify('datachange',varargin{:});
end
