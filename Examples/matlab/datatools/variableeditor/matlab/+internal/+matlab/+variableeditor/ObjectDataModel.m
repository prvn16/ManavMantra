classdef ObjectDataModel < internal.matlab.variableeditor.ArrayDataModel & ...
        internal.matlab.variableeditor.EditableVariable
    
    % ObjectDataModel 
    % Data Model for Objects in the Variable Editor

    % Copyright 2013-2014 The MathWorks, Inc.

    % Type
    properties (SetAccess = private)
        % Type Property
        Type = 'Object';
        
        % Will be set to the object name when data is set
        ClassType = 'object';       
    end %properties
    
    % Data
    properties (SetObservable = true)
        % Data Property
        Data = [];
    end
    
    methods
        function storedValue = get.Data(this)
            storedValue = this.Data;
        end
        
        function set.Data(this, newValue)
            if (~isobject(newValue) && ~ishandle(newValue)) || ...
                    length(size(newValue)) ~= 2 || ...
                    numel(newValue) ~= 1
                error(message('MATLAB:codetools:variableeditor:NotAnObject'));
            end
            
            % Assign the class type
            this.ClassType = class(newValue); %#ok<MCSUP>
            reallyDoCopy = ~isequal(this.Data, newValue);
            if reallyDoCopy
                this.Data = newValue;
            end
        end
    end

    methods (Access = public)
        % getSize
        function s = getSize(this)
            s = [length(properties(this.Data)) 4];
        end
        
        function rhs = getRHS(~, data)
            % Called to get the RHS for an assignment
            if isnumeric(data)
                % Avoiding loss of precision by formatting to a large
                % number of decimal places
                rhs = num2str(data, '%20.20f');
            else
                rhs = data;
            end
        end
    end %methods

    methods (Access = protected)
        function lhs = getLHS(this, varargin)
            % Called to get the LHS for an assignment
            props = properties(this.Data);
            prop = props{varargin{2}};
            
            % Will be '.<property>'
            lhs = sprintf('.%s', prop);
        end
    end
end