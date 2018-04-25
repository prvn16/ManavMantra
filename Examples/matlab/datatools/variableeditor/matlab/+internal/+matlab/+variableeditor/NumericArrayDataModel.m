classdef NumericArrayDataModel < internal.matlab.variableeditor.ArrayDataModel
    %NUMERICARRAYDATAMODEL 
    %   Numeric Array Data Model

    % Copyright 2013-2014 The MathWorks, Inc.

    % Type
    properties (Constant)
        NumericTypes = { 'double', 'uint8', 'uint16', 'uint32', 'uint64', ...
            'int8', 'int16', 'int32', 'int64', 'single'};
    end
    
    properties (SetObservable=false, SetAccess='private', GetAccess='public', Dependent=false, Hidden=false)
        % Type Property
        Type = 'NumericArray';
        
        % Class Type Property
        ClassType = internal.matlab.variableeditor.NumericArrayDataModel.NumericTypes;
    end %properties

    % Data
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=false, Hidden=false)
        % Data Property
        Data
    end %properties
    methods
        function storedValue = get.Data(this)
            storedValue = this.Data;
        end
        
        % Sets the data
        % Data must be a two dimensional numeric array
        function set.Data(this, newValue)
            if ~isnumeric(newValue) || length(size(newValue))~=2
                error(message('MATLAB:codetools:variableeditor:NotAnMxNNumericArray'));
            end
            reallyDoCopy = ~isequal(this.Data, newValue);
            if reallyDoCopy
                this.Data = newValue;
            end
        end
    end

    methods(Access='protected')
        % Returns the left hand side of an assigntment operation
        function lhs=getLHS(~,idx)
            lhs = sprintf('(%s)',idx);
        end
    end
end

