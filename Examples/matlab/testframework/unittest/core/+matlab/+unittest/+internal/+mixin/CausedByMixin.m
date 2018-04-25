% This class is undocumented.

% The CausedByMixin can be included as a part of any class that requires
% specifying causes of an action. See NameValueMixin.m for details on the
% process to utilize this mixin.

%  Copyright 2013-2017 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) CausedByMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (SetAccess = private)
        % RequiredCauses - Specifies the causes to look for
        %
        %   The RequiredCauses value can be cell array of Strings or an array
        %   of meta.class objects
        %
        %   This property is read only and can only be set through the constructor.
        RequiredCauses = cell(1,0);
    end
    
    properties(Hidden, Constant, Access=private)
        MetaClassCausedByParser = createParser('RequiredCauses',...
            @(classes) all(classes <= ?MException));
    end
    
    methods (Hidden, Access = protected)
        function mixin = CausedByMixin()
            % Add CausedBy parameter and its set function
            mixin = mixin.addNameValue('CausedBy',...
                @setRequiredCauses,...
                @causedByPreSet,...
                @causedByPostSet);
        end
        
        function [mixin,value] = causedByPreSet(mixin,value)
            import matlab.unittest.internal.mixin.CausedByMixin;
            if isa(value,'message')
                % Validate message objects by calling getString
                arrayfun(@getString, value, 'UniformOutput',false);
                value = reshape(value,1,[]);
                return;
            end
            
            validateattributes(value,{'cell','meta.class','string'},{},'','CausedBy');
            value = reshape(value,1,[]);

            if isa(value, 'meta.class')
                % Validate meta.class objects with constant property (for performance)
                CausedByMixin.MetaClassCausedByParser.parse(value);
                return;
            end
            
            if iscell(value) && ~iscellstr(value)
                error(message('MATLAB:unittest:StringInputValidation:InvalidCellstr'));
            elseif isstring(value) && any(ismissing(value))
                error(message('MATLAB:unittest:StringInputValidation:EachElementMustContainCharacters'));
            end
            
            value = cellstr(value);
        end
        
        function mixin = causedByPostSet(mixin)
            %This method allows subclasses to extend the behavior of causedBy
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = causedBy(mixin, value)
            [mixin,value] = mixin.causedByPreSet(value);
            mixin = mixin.setRequiredCauses(value);
            mixin = mixin.causedByPostSet();
        end
    end
    
    methods (Access = private)
        function mixin = setRequiredCauses(mixin, value)
            mixin.RequiredCauses = value;
        end
    end
end

function p = createParser(inpName,validationFunc)
p = inputParser();
p.addRequired(inpName,validationFunc);
end