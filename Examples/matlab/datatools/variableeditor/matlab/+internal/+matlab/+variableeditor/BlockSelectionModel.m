classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, ConstructOnLoad=true) BlockSelectionModel <  internal.matlab.variableeditor.SelectionModel 
    % An abstract class defining the methods for a Variable Selection Model
    % 
    
    % Copyright 2013-2014 The MathWorks, Inc.

    properties (Abstract=true, SetObservable=true, SetAccess='protected', GetAccess='public') 
        DataModel
    end
    
    methods (Abstract)
        objSize = getSize(this);
    end
    
    % Public Abstract Methods
    methods(Access='public')
        % getSelection
        function varargout = getSelection(this,varargin)
            Selection{1} = this.SelectedRowIntervals;
            Selection{2} = this.SelectedColumnIntervals;
            
            varargout{1} = Selection;
        end

        % setSelection
        function varargout = setSelection(this,varargin)
            
            this.SelectedRowIntervals = varargin{1};
            this.SelectedColumnIntervals = varargin{2};
            Selection{1} = this.SelectedRowIntervals;
            Selection{2} = this.SelectedColumnIntervals;

            varargout{1} = Selection;
             
            this.fireSelectionChanged();

        end

        function varargout = getFormattedSelection(this)
        selectionString = '';
        data = this.DataModel.Data;
		% for char arrays the data can be empty. Also holds for infinite grids.
        if ~isempty(data)
            dataSize = this.getSize;
            % case when only some cells are selected
            if ~isempty(this.SelectedRowIntervals) || ~isempty(this.SelectedColumnIntervals)
                selectionString = this.DataModel.Name;
                selectionString = [selectionString '('];
            end
            
            selectedRows = this.SelectedRowIntervals;
            selectedColumns = this.SelectedColumnIntervals;
            
            selectionString = this.getSelectionString(selectionString, dataSize(1,1), selectedRows);
            if ~isempty(selectedColumns)
                selectionString = [selectionString ','];
            end
            selectionString = this.getSelectionString(selectionString, dataSize(1,2), selectedColumns);            

            if ~isempty(this.SelectedRowIntervals) || ~isempty(this.SelectedColumnIntervals)
                selectionString = [selectionString ')'];
            end

            if isempty(this.SelectedRowIntervals) || isempty(this.SelectedColumnIntervals) 
                selectionString = '';
            end
        end
        
        varargout{1} = selectionString;
        end

        function varargout = getDataType(this,varargin)
            varargout{1} = this.DataModel.ClassType; 
        end        
    
        function selectionString = getSelectionString(~, selectionString, dataSize, selectedEntries)
            if ~isempty(selectedEntries)
                if size(selectedEntries,1) > 1
                    selectionString = [selectionString '['];
                end
                for i=1:size(selectedEntries,1)
                    if i>1
                        selectionString = [selectionString ',']; %#ok<AGROW>
                    end
                    % case when a single row/col is selected
                    selectionString = [selectionString internal.matlab.variableeditor.BlockSelectionModel.localCreateSubindex(selectedEntries(i,:),dataSize)]; %#ok<AGROW>
                end
                if size(selectedEntries,1) > 1
                    selectionString = [selectionString ']'];
                end
            end
        end
    end
    
    methods(Static=true)
       function subindexString = localCreateSubindex(selectedInterval,count)
            if selectedInterval(1)==selectedInterval(2) % Since row/column selection
                if selectedInterval(2)<count
                    subindexString = num2str(selectedInterval(2));
                else
                    subindexString = 'end'; % Since row/column selection at the end
                end
            elseif selectedInterval(1)==1 && selectedInterval(2)==count % All rows/columns
                subindexString = ':';
            elseif selectedInterval(2)==count % rows/columns up to the end
                subindexString = sprintf('%d:end',selectedInterval(1));
            else
                subindexString = sprintf('%d:%d',selectedInterval(1),selectedInterval(2));
            end
        end
    end
    
    properties
        SelectedRowIntervals;
        SelectedColumnIntervals;
    end

end %classdef
