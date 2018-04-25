%StatefulFunction
% A helper class that wraps a single function handle with the ability to
% store state.
%
% Any function handle wrapped in this object will be called with the
% syntax:
% [state, varargout] = fcn(state, varargin)
%
% Where:
%  - state is the persistent state. This will be initialized to empty, but
%  will persist values between calls of this function handle within each
%  partition.
%  - varargout and varargin are the actual inputs/outputs of the function.

%   Copyright 2016 The MathWorks, Inc.

classdef StatefulFunction < handle & matlab.mixin.Copyable
    properties (GetAccess = private, SetAccess = immutable)
        % The underlying function handle.
        FunctionHandle;
    end
    
    properties (Access = private)
        % Storage for state held between calls of the function handle.
        State = [];
    end
    
    methods
        function obj = StatefulFunction(functionHandle, initialState)
            obj.FunctionHandle = functionHandle;
            if nargin >= 2
                obj.State = initialState;
            end
        end
        
        function [varargout] = feval(obj, varargin)
            % Call the function handle, passing both the persisted state
            % and the actual inputs/outputs to the underlying function
            % handle.
            [obj.State, varargout{1:nargout}] = feval(obj.FunctionHandle, obj.State, varargin{:});
        end
    end
    
    methods (Access = protected)
        function obj = copyElement(obj)
            % Copy an StatefunFunction, ensuring the underlying handle is
            % copied if it is copyable.
            fh = obj.FunctionHandle;
            if isa(fh, 'matlab.mixin.Copyable')
                fh = copy(fh);
            end
            obj = matlab.bigdata.internal.util.StatefulFunction(fh, obj.State);
        end
    end
end
