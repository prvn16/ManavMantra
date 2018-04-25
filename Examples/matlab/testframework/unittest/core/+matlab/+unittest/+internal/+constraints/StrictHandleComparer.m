classdef(Hidden) StrictHandleComparer < handle
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2016 The MathWorks, Inc.
    methods(Static)
        function varargout = eq(varargin)
            [varargout{1:nargout}] = eq@handle(varargin{:});
        end
    end
end