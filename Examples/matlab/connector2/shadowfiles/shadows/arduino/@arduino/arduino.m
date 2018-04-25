classdef (Sealed) arduino
%   Arduino is not supported on this platform.

%   Copyright 2017 The MathWorks, Inc.
    
    %% Constructor
    methods(Hidden, Access = public)
        function obj = arduino(varargin)
            nse = connector.internal.notSupportedError;
            nse.throwAsCaller;
        end
    end
end
