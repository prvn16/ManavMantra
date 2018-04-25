classdef DataManager < handle
    % DATAMANAGER Manages the data to be sent to the client. It works with the
    % ViewDataset to identify the requested data to send.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = private, GetAccess = private)
        ResultDatabase
        SpreadsheetProperties = {'id','Class','Name','Run','objectClass','CompiledDT','SpecifiedDT','ProposedDT',...
            'DTGroup','Accept','SimMin_S','SimMax_S','DerivedMin_S','DerivedMax_S','DesignMin_S','DesignMax_S', ...
            'ProposedMin_S','ProposedMax_S', 'OverflowSaturation',...
            'OverflowWrap', 'hasProposedDT', 'hasDTGroup', 'hasOverflows', 'hiliteRowsWithIssues',...
            'IsReadOnly'};
        VisualizerProperties = {'HistogramVisualizationInfo'};
        NumericalProperties = {'SimMin','SimMax','DerivedMin','DerivedMax','DesignMin','DesignMax','ProposedMin','ProposedMax'};
        OtherProperties = {'hasInterestingInformation', 'runHasSimRange', 'runHasDeriveRange',...
            'runHasProposals'};
        TableProperties = {};
        SortProperty = 'Name';
        SortDirection = 'ascend';
        LastSortIndices = [];
        LastScopedTable = [];
    end
    
    methods
        function this = DataManager
            this.TableProperties = [this.SpreadsheetProperties this.NumericalProperties this.OtherProperties this.VisualizerProperties];
            initData = double.empty(0, length(this.TableProperties));
            this.ResultDatabase = array2table(initData, 'VariableNames',this.TableProperties);
        end
        
        addResultsToTable(this, results);
        data = getData(this, query, subsystemIds);
        data = getDataForVisualizer(this, query, runName);
        removeRunFromTable(this, runName);
        clearTable(this);
    end
    
    % For testing purposes only.
    methods (Hidden)
        % Get the table object. This is a test API.
        table = getTable(this);
        
        % Get the index of the rowId given the last known sort order
        idx = getIndexOfRowId(this, rowId);
    end
    
end
