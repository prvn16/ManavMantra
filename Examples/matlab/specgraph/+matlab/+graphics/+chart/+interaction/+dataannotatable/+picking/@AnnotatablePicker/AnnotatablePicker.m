classdef (Sealed, ConstructOnLoad) AnnotatablePicker < handle
    %AnnotatablePicker Helper class for picking data from annotatable objects
    %
    %  AnnotatablePicker is a utility class that provides a set of standard
    %  data picking algorithms with interfaces that suit typical graphics
    %  object data formats and ensure that picking is performed in a
    %  reference frame that corresponds to the visual scene.
    %
    %  The algorithms are typically accessed through a shared instance
    %  which is provided by the static getInstance method.  This shared
    %  instance manages a transform cache to ensure that successive picks
    %  on the same object are optimized.
    
    %  Copyright 2013-2014 The MathWorks, Inc.
     
    methods
        function obj = AnnotatablePicker()
        end
    end
    
    methods(Static)
        function obj = getInstance()
            %getInstance Return the shared AnnotatablePicker instance
            %
            %  getInstance() returns a persistent instance of
            %  AnnotatablePicker that can be used by anyone that wants to
            %  benefit from results caching between calls.
            %
            %  The shared instance is not guaranteed to stay valid for
            %  extended periods of time.  Users should call the getInstance
            %  method each time they need to perform a picking operation
            %  rather than calling it once and holding a copy of the
            %  instance handle.
            
            persistent SharedInstance
            
            obj = SharedInstance;
            if isempty(obj) || ~isvalid(obj)
                obj = matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker();
                SharedInstance = obj;
            end
            
        end
    end
    
    methods(Access=private)
        % Utility methods that are used to convert data into a picking
        % reference frame
        pickLocations = convertToPickSpace(obj, hContext, data, valid, request3D)
        pickPoint = targetPointToPickSpace(obj, hContext, point, isPixel)
        valid = isValidInPickSpace(obj, hContext, varargin)  
    end
end
