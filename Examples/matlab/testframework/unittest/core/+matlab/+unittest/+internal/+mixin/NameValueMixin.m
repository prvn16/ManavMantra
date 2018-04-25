% This class is undocumented.

% The NameValueMixin class is a base class for use when creating a mixin
% class that adds input parameters to a class constructor. When mixin
% classes inherit from this class they can add input parameters to the one
% parser contained here so that these mixins can be easily utilized in the
% classes that contain the mixins. The process is:
%
%   1) mixin classes derive from this class and add their own input
%   parameters using the addNameValue method.
%   2) concrete classes derive from one or more mixin class and parse the
%   varargin of their constructor using the parse method.

%  Copyright 2010-2016 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) NameValueMixin
    
    properties (Access = private)
        ParameterMap;
    end
    
    methods (Hidden, Access = protected)
        function mixin = NameValueMixin
            % Must only do this once per instance; when multiply inherited
            % the constructor gets called multiple times potentially.
            if isempty(mixin.ParameterMap)
                mixin.ParameterMap = containers.Map;
            end
        end
        
        function mixin = addNameValue(mixin, paramName, setFunction, preSetFunction, postSetFunction)
            if nargin < 5
                postSetFunction = @noOp;
            end
            if nargin < 4
                preSetFunction = @noOp;
            end
            if isKey(mixin.ParameterMap, lower(paramName))
                error(message('MATLAB:unittest:NameValue:NameAlreadyExists', paramName));
            end
            
            mixin.ParameterMap(lower(paramName)) = struct(...
                'PreSetFunction',preSetFunction,...
                'SetFunction',setFunction,...
                'PostSetFunction',postSetFunction);
        end
        
        function mixin = parse(mixin, varargin)
            
            % Early exit if there is nothing to parse
            if isempty(varargin)
                return
            end
            
            % Arguments must be specified as name-value pairs
            if mod(numel(varargin), 2) ~= 0
                error(message('MATLAB:unittest:NameValue:NameMissingValue'));
            end
            
            paramNames = cellfun(@convertToCharIfString,varargin(1:2:end),...
                'UniformOutput',false);
            if ~iscellstr(paramNames)
                error(message('MATLAB:unittest:NameValue:NameMustBeChar'));
            end
            
            paramValues = varargin(2:2:end);
            for idx = 1:numel(paramNames)
                paramName = paramNames{idx};
                if ~isKey(mixin.ParameterMap, lower(paramName))
                    error(message('MATLAB:unittest:NameValue:UnmatchedName', paramName));
                end
                paramValue = paramValues{idx};
                
                s = mixin.ParameterMap(lower(paramName));
                
                [mixin, paramValue] = s.PreSetFunction(mixin, paramValue);
                mixin = s.SetFunction(mixin, paramValue);
                mixin = s.PostSetFunction(mixin);
            end
        end
    end
    
    methods (Access = ?matlab.unittest.internal.mixin.NameValueForwarderMixin)
        function bool = hasParameter(mixin, paramName)
            bool = isKey(mixin.ParameterMap, lower(paramName));
        end
        
        function setFunction = getSetFunctionForParameter(mixin, paramName)
            s = mixin.ParameterMap(lower(paramName));
            setFunction = s.SetFunction;
        end
    end
end

function varargout = noOp(varargin)
varargout = varargin;
end

function value = convertToCharIfString(value)
if isstring(value)
    value = char(value);
end
end