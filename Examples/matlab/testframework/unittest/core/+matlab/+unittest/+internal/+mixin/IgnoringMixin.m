% This class is undocumented.

% The IgnoringMixin can be included as a part of class that supports
% specifying entities to ignore. See NameValueMixin.m for details on the
% process to utilize this mixin.

%  Copyright 2015-2017 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) IgnoringMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (SetAccess=private)
        % Ignore - Values to ignore.
        %
        %   When specified, the instance ignores these values.
        %
        %   The Ignore property is empty by default, but can be specified during
        %   construction of the instance by utilizing the (..., 'Ignoring', value)
        %   parameter value pair.
        Ignore = cell(1,0);
    end
    
    methods (Hidden, Access=protected)
        function mixin = IgnoringMixin
            % Add Ignoring parameter and its set function
            mixin = mixin.addNameValue('Ignoring', ...
                @setIgnore,...
                @ignoringPreSet,...
                @ignoringPostSet);
        end
        
        function [mixin,value] = ignoringPreSet(mixin,value)
            validateattributes(value,{'cell','string'},{},'','Ignore');
            value = reshape(value,1,[]);
            
            if iscell(value) && ~iscellstr(value)
                error(message('MATLAB:unittest:StringInputValidation:InvalidCellstr'));
            elseif ~all(strlength(value)>0) % also catches missing elements since NaN>0 is false
                error(message('MATLAB:unittest:StringInputValidation:EachElementMustContainCharacters'));
            end
            
            %condition the input
            value = unique(cellstr(value),'stable');
        end
        
        function mixin = ignoringPostSet(mixin)
            % Overridable template method.
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = ignoring(mixin, value)
            [mixin,value] = mixin.ignoringPreSet(value);
            mixin = mixin.setIgnore(value);
            mixin = mixin.ignoringPostSet();
        end
    end
    
    methods(Access=private)
        function mixin = setIgnore(mixin,value)
            mixin.Ignore = value;
        end
    end
end

% LocalWords:  Overridable
