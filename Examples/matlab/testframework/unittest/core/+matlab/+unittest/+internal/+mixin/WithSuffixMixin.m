% This class is undocumented.

% The WithSuffixMixin can be included as a part of class that supports
% specifying a suffix. See NameValueMixin.m for details on the process
% to utilize this mixin.

%  Copyright 2013-2016 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) WithSuffixMixin < matlab.unittest.internal.mixin.NameValueMixin
    
    properties (SetAccess=private)
        % Suffix - A character vector to be used as a suffix.
        %
        %   When specified, the instance uses the specified character vector as a suffix.
        %
        %   The suffix can be specified during construction of the
        %   instance by utilizing the (..., 'WithSuffix', suffix) parameter
        %   value pair.
        Suffix = '';
    end
    
    methods (Hidden, Access=protected)
        function mixin = WithSuffixMixin()
            % Add WithSuffix parameter and its set function
            mixin = mixin.addNameValue('WithSuffix', ...
                @setSuffix,...
                @withSuffixPreSet);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = withSuffix(mixin, suffix)
            [mixin,suffix] = mixin.withSuffixPreSet(suffix);
            mixin.Suffix = suffix;
        end
    end
    
    methods(Access=private)
        function mixin = setSuffix(mixin,value)
            mixin.Suffix = value;
        end
        
        function [mixin,value] = withSuffixPreSet(mixin,value)
            validateattributes(value, {'char','string'}, {'scalartext'}, '', 'Suffix');
            value = char(value);
            
            % Prohibit filesep inside the suffix string.
            if contains(value,'/')
                error(message('MATLAB:unittest:PrefixSuffix:CharacterProhibited','Suffix','/'));
            elseif contains(value,'\')
                error(message('MATLAB:unittest:PrefixSuffix:CharacterProhibited','Suffix','\'));
            end
        end
    end
end