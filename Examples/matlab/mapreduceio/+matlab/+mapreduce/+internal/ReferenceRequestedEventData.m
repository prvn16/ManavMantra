%ReferenceRequestedEventData
% Helper class for SoftReferableMixin that carries a writable Reference
% property to the listeners of ReferenceRequested event.

%   Copyright 2014 The MathWorks, Inc.

classdef (Sealed, Hidden) ReferenceRequestedEventData < event.EventData
    properties
        Reference; % A writable property to receive a reference from listeners.
    end
end
