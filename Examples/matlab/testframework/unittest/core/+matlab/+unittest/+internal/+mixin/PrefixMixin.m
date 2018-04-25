classdef(Hidden, HandleCompatible) PrefixMixin < matlab.unittest.internal.mixin.NameValueMixin
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2016 The MathWorks, Inc.
    properties (SetAccess=private)
        % Prefix - A character vector to be used as a prefix.
        %
        %   When specified, the instance uses the specified character vector as a prefix.
        %
        %   The prefix can be specified during construction of the
        %   instance by utilizing the (..., 'Prefix', prefix) parameter
        %   value pair.
        Prefix char
    end
    
    methods (Hidden, Access=protected)
        function mixin = PrefixMixin(defaultPrefix)
            mixin.Prefix = defaultPrefix;
            mixin = mixin.addNameValue('Prefix', ...
                @setPrefix,...
                @prefixPreSet);
        end
    end
    
    methods(Access=private)
        function mixin = setPrefix(mixin,value)
            mixin.Prefix = value;
        end
        
        function [mixin,value] = prefixPreSet(mixin,value)
            validateattributes(value, {'char','string'}, {'scalartext'}, '', 'Prefix');
            value = char(value);
            
            % Prohibit filesep inside the prefix string.
            if contains(value,'/')
                error(message('MATLAB:unittest:PrefixSuffix:CharacterProhibited','Prefix','/'));
            elseif contains(value,'\')
                error(message('MATLAB:unittest:PrefixSuffix:CharacterProhibited','Prefix','\'));
            end
        end
    end
end