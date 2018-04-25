% This class is undocumented.

%  Copyright 2016 The MathWorks, Inc.
classdef (Hidden) IncludingSelfMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (Hidden, SetAccess=private)
        IncludeSelf (1,1) = false;
    end
    
    properties(Dependent, SetAccess=private)
        % Recursive - Boolean indicating whether the instance operates recursively
        %
        %   The Recursive property is false by default, but can be specified to be
        %   true during construction of the instance by utilizing the (...,
        %   'Recursively', true) parameter value pair.
        Recursive (1,1)
    end
    
    methods
        function value = get.Recursive(mixin)
            value = mixin.IncludeSelf;
        end
        
        function mixin = set.Recursive(mixin, value)
            mixin.IncludeSelf = value;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = IncludingSelfMixin()
            mixin = mixin.addNameValue('IncludingSelf',...
                @setIncludeSelf,@validateIncludeSelf);
            
            mixin = mixin.addNameValue('Recursively',...
                @setRecursive,@validateRecursive);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = includingSelf(mixin)
            mixin.IncludeSelf = true;
        end
        
        function mixin = recursively(mixin)
            mixin.Recursive = true;
        end
    end
end

function mixin = setIncludeSelf(mixin, value)
mixin.IncludeSelf = value;
end

function mixin = setRecursive(mixin, value)
mixin.Recursive = value;
end

function [mixin,value] = validateIncludeSelf(mixin, value)
validateattributes(value,{'logical'},{},'','IncludingSelf');
end

function [mixin,value] = validateRecursive(mixin, value)
validateattributes(value,{'logical'},{},'','Recursively');
end

