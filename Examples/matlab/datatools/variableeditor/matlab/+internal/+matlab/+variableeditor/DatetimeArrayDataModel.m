classdef DatetimeArrayDataModel < internal.matlab.variableeditor.ArrayDataModel
    %DATETIMEARRAYDATAMODEL 
    %   Datatime Array Data Model

    % Copyright 2013-2014 The MathWorks, Inc.

    % Type
    properties (Constant)
        % Type Property
        Type = 'DatetimeArray';
        
        % Class Type Property
        ClassType = 'datetime';
    end %properties

    % Data
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=false, Hidden=false)
        % Data Property
        Data;
        
    end %properties
    methods
        function storedValue = get.Data(this)
            storedValue = this.Data;
        end
        
        % Sets the data
        % Data must be a two dimensional datetime array
        function set.Data(this, newValue)
            if ~isdatetime(newValue) || numel(size(newValue))~=2
                error(message('MATLAB:codetools:variableeditor:NotAnMxNDatetimeArray'));
            end
            this.Data = newValue;
        end        
        
        
        % Returns the right hand side of a formatted assignment string
        function rhs = getRHS(~, newValue)
            rhs = newValue;            
        end        
    end

    methods(Access='protected')
        % Returns the left hand side of an assigntment operation
        function lhs=getLHS(~,idx)
            lhs = sprintf('(%s)',idx);
        end
    end
end

