classdef ( AllowedSubclasses={?matlab.graphics.chart.interaction.dataannotatable.ImageAdaptor,?matlab.graphics.chart.interaction.dataannotatable.LineAdaptor,?matlab.graphics.chart.interaction.dataannotatable.PatchAdaptor,?matlab.graphics.chart.interaction.dataannotatable.SurfaceAdaptor,?matlab.graphics.chart.interaction.dataannotatable.PolygonAdaptor})AnnotationAdaptor < matlab.graphics.chart.interaction.DataAnnotatable & matlab.mixin.SetGet 
%AnnotationAdaptor  Abstract base class for adaptors that implement DataAnnotatable
%
%  The AnnotationAdaptor class is an absract class that subclasses from
%  DataAnnotatable and implements the storage of a separate target that
%  will be annotated.  It does not implement any of the templated methods
%  from the superclass.

%  Copyright 2011-2017 The MathWorks, Inc.

    properties(SetAccess = private, GetAccess = protected)
        AnnotationTarget;
    end
    
    properties(SetObservable, SetAccess = private, GetAccess = public, Dependent)
        Parent;
        Behavior;
    end
    
    properties(Access=private, Transient)
        TargetListener
    end
    
    methods
        function hObj = AnnotationAdaptor(hTarget)
            hObj.AnnotationTarget = hTarget;
        end
        
        function set.AnnotationTarget(hObj, hTarget)
            if ~ishghandle(hTarget)
                error(message('MATLAB:specgraph:chartMixin:dataannotatable:AnnotationAdaptor:InvalidTarget'));
            end

            % Add a listener to delete this object when the Image is
            % destroyed.
            hObj.TargetListener = ...
                event.listener(hTarget, 'ObjectBeingDestroyed',@(obj,evd)(delete(hObj))); 
            
            % Call a template method for subclasses to override
            hObj.doSetAnnotationTarget(hTarget);
            
            hObj.AnnotationTarget = hTarget; 
        end
            
        function val = get.Parent(hObj)
            val = hObj.AnnotationTarget.Parent;
        end

        function val = get.Behavior(hObj)
            val = hObj.AnnotationTarget.Behavior;
        end
    end   
    
        
    methods(Access=public)
        function hTarget = getAnnotationTarget(hObj)
        %getAnnotationTarget Return the underlying HG object being annotated
        %
        %   getAnnotationTarget(obj) returns the actual HG scene node that
        %   is being annotated.  AnnotationAdapter classes return the
        %   AnnotationTarget object.

            hTarget = hObj.AnnotationTarget;
        end
    end
    
    methods(Abstract, Access=protected)
        doSetAnnotationTarget(hObj, hTarget);    
    end
end
