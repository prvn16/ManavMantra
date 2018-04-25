classdef WebControllerViewInterface < handle
    % WebControllerViewInterface
    % An abstract class defining interfaces used by MATLAB view 
    % classes (i.e. TableView) to communicate back to its controller.
    % 
    
    % Copyright 2014 The MathWorks, Inc.
    
    methods (Abstract=true)
        
        %%%%%%%%%%%%%%%% set model properties %%%%%%%%%%%%%%%%%%
        
        % signle cell edit
        setModelCellData(this, newValue, row, column);
        
        % set CellSelection event back to the model.
        setModelCellSelectionEvent(this, eventData);
        
        % update all view properties from model to the view
        updateViewProperties(this, varargin);
        
        % set ColumnName
        setModelColumnName(this, columnName);
        
        % set RowName
        setModelRowName(this, rowName);      
        
        
        
        %%%%%%%%%%%%%%%% get model information %%%%%%%%%%%%%%%%%%
        
        % get Data property
        data = getModelData(this);
        
        % get ColumnName property 
        name = getModelColumnName(this); 
        
        % get ColumnWidth
        width = getModelColumnWidth(this);
        
        % check if ColumnNameMode is auto
        isAuto = isColumnNameModeAuto(this);
        
        % check if RowNameMode is auto
        isAuto = isRowNameModeAuto(this); 
        
        % check if Model is deleted.
        isDeleted = isModelDeleted(this);
    end
end