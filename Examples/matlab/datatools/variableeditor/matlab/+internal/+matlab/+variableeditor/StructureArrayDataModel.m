classdef StructureArrayDataModel < internal.matlab.variableeditor.ArrayDataModel
    %STRUCTUREARRAYDATAMODEL 
    %   Structure Array Data Model

    % Copyright 2015 The MathWorks, Inc.

    % Type
    properties (Constant)
        % Type Property
        Type = 'StructureArray';
        
        ClassType = 'struct';
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
            if ~isa(newValue,'struct') || length(size(newValue))~=2
                error(message('MATLAB:codetools:variableeditor:NotAnMxNCellArray'));
            end
             reallyDoCopy = ~(this.equalityCheck(this.Data, newValue));
             if reallyDoCopy
                this.Data = newValue;
             end
        end
    end
    
    methods(Access='protected')
        function lhs=getLHS(this,idx)
            dims = sscanf(idx,'%d,%d');
            columns = fields(this.Data);
            selectedColumnName = columns{dims(2)};
            lhs = sprintf('(%d).%s',dims(1),selectedColumnName);
        end
    end
    
    methods(Access='public')
        function rhs=getRHS(~,data)
            if (size(data,1)==1)
                rhs = data;
            else
                rhs = '{';
                for i=1:size(data,2)
                    if i>1
                        rhs = [rhs ';'];
                    end
                    for j=1:size(data,1)
                        if j>1
                            rhs = [rhs ','];
                        end
                        rhs = [rhs mat2str(data(i,j))];
                    end
                end
                rhs = [rhs '}'];
            end
        end
        
        function eq = equalityCheck(~, oldData, newData)
            fOld = [];
            fNew = [];
            eq = false;            
            if ~isempty(oldData) && ~isempty(newData)
                % check if data is equal
                eq = isequaln(oldData,newData);
                if (eq)
                    % check if fieldnames are equal
                    fOld = fields(oldData);
                    fNew = fields(newData);
                    eq = isequaln(fOld, fNew);
                    if (eq)
                        % check if data types are equal
                        oldData = struct2cell(oldData);
                        newData = struct2cell(newData);
                        eq = all(cellfun(@(old,new)strcmp(class(old),class(new)),oldData(:),newData(:)));
                    end
                end
            end           
        end
    end
end



