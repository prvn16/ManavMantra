classdef (StrictDefaults)hdlram < hdl.RAM
    % This function is deprecated. Please see help for hdl.RAM
    
    %   Copyright 2011-2013 The MathWorks, Inc.
    
%#codegen
%#ok<*EMCLS>
    
    
    methods
        function obj = hdlram(varargin)
            % RAMType and WriteOutputvalue can also be specified without
            % the pv-pair interface
            
            coder.internal.warning('MATLAB:system:throwObsoleteWarningNotRecommendedNewName', 'hdlram', '', 'hdl.RAM');
            
            setProperties(obj, nargin, varargin{:}, ...
                'RAMType', 'WriteOutputValue');
        end % hdlram
    end
    
end % hdlram
