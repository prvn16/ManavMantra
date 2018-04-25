classdef ReturnEmptyDouble < matlab.mock.actions.MethodCallAction
    % This class is undocumented and may change in a future release.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    methods
        function varargout = callMethod(varargin)
            [varargout{1:max(nargout,1)}] = deal([]);
        end
    end
end

