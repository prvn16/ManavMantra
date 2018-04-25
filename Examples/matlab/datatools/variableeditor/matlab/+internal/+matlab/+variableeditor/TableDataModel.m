classdef TableDataModel < internal.matlab.variableeditor.ArrayDataModel
    %TABLEDATAMODEL 
    %   Table Data Model

    % Copyright 2013-2014 The MathWorks, Inc.

    % Type
    properties (Constant)
        % Type Property
        Type = 'Table';
        
        ClassType = 'table';
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
        
        function set.Data(this, newValue)
            if ~matlab.internal.datatypes.istabular(newValue) || length(size(newValue))~=2
                error(message('MATLAB:codetools:variableeditor:NotATable'));
            end
            % Commenting out the isequal check for tables because it does
            % not work if there is a type change.
            reallyDoCopy = true; %~isequal(this.Data, newValue);
            if reallyDoCopy
                this.Data = newValue;
            end
        end
    end

    methods(Access='protected')
        function lhs=getLHS(this,idx,columnIndex)
            if nargin<3
                columnIndex = 1;
            end
            row = sscanf(idx,'%d');
            varName = eval(sprintf('this.Data(%s).Properties.VariableNames{1}',idx));
            classType = eval(sprintf('class(this.Data.%s)',varName));
            if strcmpi(classType,'cell')
                lhs = sprintf('.%s{%d,%d}',varName,row,columnIndex);
            else
               lhs = sprintf('.%s(%d,%d)',varName,row,columnIndex);
            end
        end
    end
    
    methods(Access='public')
        function lhs=getLHSGrouped(this,idx,columnIndex)
            lhs = this.getLHS(idx,columnIndex);
        end
        
        function rhs=getRHS(this,data)
            if (size(data,1)==1)
                rhs = data;
            else
                rhs = '(';
                for i=1:size(data,1)
                    if i > 1
                        rhs = [rhs ';'];
                    end
                    for j=1:size(data,2)
                        rhs = [rhs mat2str(data(i,j)) ' '];
                    end
                    %rhs = [rhs ';'];
                end
                rhs = [rhs ')'];
            end
        end
    end
end

