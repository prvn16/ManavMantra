classdef(Hidden) NameValueForwarderMixin
    % This class is undocumented and may change in a future release.

    % The NameValueForwarderMixin adds to subclasses the method:
    %   * applyNameValueTo
    % and requires subclasses to implement
    %   * forwardNameValue
    % 
    % The forwardNameValue method should use applyNameValueTo on all of
    % the objects it wants to forwardNameValue pairs to.
    
    %  Copyright 2015-2017 The MathWorks, Inc.
    methods (Abstract, Hidden, Access = protected)
        mixin = forwardNameValue(mixin,paramName, paramValue)
    end
    
    methods (Hidden, Static, Access = protected)
        function obj = applyNameValueTo(obj, paramName, paramValue)
            
            %If obj can receive the parameter, then directly set it on obj
            if isa(obj,'matlab.unittest.internal.mixin.NameValueMixin') && ...
                    obj.hasParameter(paramName)
                setFunction = obj.getSetFunctionForParameter(paramName);
                obj = setFunction(obj,paramValue);
            end
            
            %If obj can forward the parameter, then have obj forward it
            if isa(obj,'matlab.unittest.internal.mixin.NameValueForwarderMixin')
                obj = obj.forwardNameValue(paramName, paramValue);
            end
        end
    end
end