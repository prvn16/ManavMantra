% A mixin class that adds the ability for objects to obtain a reference to
% instances of obj class without holding any form of lifetime ownership.

%   Copyright 2014 The MathWorks, Inc.

classdef (Abstract, Hidden) SoftReferableMixin < handle
    
    properties (Access = private, Transient)
        SoftReference; % The Soft reference associated with obj instance.
        ReferenceRequestedEventListener; % A listener for events sent to obj instance by the soft reference.
    end
    
    methods
        % On delete we signal to the soft reference that it should report as invalid.
        function delete(obj)
            if ~isempty(obj.SoftReference)
                obj.SoftReference.hInvalidate();
            end
        end
    end
    
    methods (Hidden)
        % Get the soft reference to obj instance.
        function softReference = hGetSoftReference(obj)
            import matlab.mapreduce.internal.SoftReference;
            
            softReference = obj.SoftReference;
            if isempty(softReference)
                obj.SoftReference = SoftReference.hBuild(); %#ok<PROP>
                obj.ReferenceRequestedEventListener = event.listener(...
                    obj.SoftReference, 'ReferenceRequested', @obj.pReferenceRequestedCallback);
                
                softReference = obj.SoftReference;
            end
        end
    end
    
    methods (Access = private)
        % Callback function that responds to the soft reference when it is
        % requesting a hard reference to us.
        function pReferenceRequestedCallback(obj, ~, output)
            output.Reference = obj;
        end
    end
end
