%SoftReference
% A helper class for SoftReferableMixin. An instance of obj class can
% obtain a reference to the soft Referable class without having lifetime
% ownership of the soft referable.

%   Copyright 2014 The MathWorks, Inc.

classdef (Sealed, Hidden) SoftReference < handle
    
    properties (SetAccess = private)
        Valid = true; % Flag to say if the referable still exists.
    end
    
    events
        ReferenceInvalidated; % Event that allows listeners to react to the reference being invalidated.
    end
    
    events (Hidden)
        ReferenceRequested; % Event that tells SoftReferableMixin to give us a reference.
    end
    
    methods
        % Retrieve a full reference to the soft referable class.
        function reference = get(obj)
            import matlab.mapreduce.internal.ReferenceRequestedEventData;
            outputData = ReferenceRequestedEventData;
            notify(obj, 'ReferenceRequested', outputData);
            reference = outputData.Reference;
        end
    end
    
    methods (Access = private)
        % Instances of obj class must be built through the hidden build function.
        function obj = SoftReference()
        end
    end
    
    methods (Hidden)
        % Hidden function to set the Valid flag to false. 
        % This should only be called by SoftReferableMixin.
        function hInvalidate(obj)
            obj.Valid = false;
            notify(obj, 'ReferenceInvalidated');
        end
    end
    
    methods (Hidden, Static)
        % Hidden build function.
        function obj = hBuild()
            import matlab.mapreduce.internal.SoftReference;
            obj = SoftReference();
        end
    end
end
