classdef MLStructureArrayDataModel < internal.matlab.variableeditor.MLArrayDataModel & internal.matlab.variableeditor.StructureArrayDataModel
    %MLSTRUCTUREARRAYDATAMODEL
    %   MATLAB Structure Array Data Model

    % Copyright 2014-2015 The MathWorks, Inc.

    methods(Access='public')
        % Constructor
        function this = MLStructureArrayDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLArrayDataModel(name, workspace);
        end
    end 
    
    methods(Access='protected')
        function [I,J] = doCompare(this, newData)
            oldStructData = this.Data;
            newStructData = newData;
            oldFields = fields(this.Data);
            newFields = fields(newData);
            I = [];
            J = [];
            % if the struct dimensions are 1xm then transpose first and
            % then convert to cell
            if size(this.Data,1) == 1 && size(this.Data,2) > 1       
                oldStructData = (oldStructData)';
            end
            oldStructDataAsCell = (struct2cell(oldStructData))';
            if size(newData,1) == 1 && size(newData,2) > 1        
                newStructData = (newStructData)';
            end
            newStructDataAsCell = (struct2cell(newStructData))';
            % if oldStructData and newStructData are equal, then the number
            % of fields has changed
            % cellfun is used to compare only cells of the same dimensions
            if isequal(length(oldFields), length(newFields))
                [I,J] = find(cellfun(@(a,b) ~isequal(a,b),  oldStructDataAsCell, newStructDataAsCell));
            end         
        end
    end
    
    methods(Access='public')    
        function dims = getDataSize(~, data)
            % return the size as the number of rows and number of fields
            % this is necessary since the size method on structure array
            % does not reflect the change in the number of fields
            dims = [size(data,1) size(data,2) length(fields(data))];
        end
        
        function eq = equalityCheck(this, oldData, newData)
            eq = this.equalityCheck@internal.matlab.variableeditor.StructureArrayDataModel(oldData, newData);
        end
    end
end

