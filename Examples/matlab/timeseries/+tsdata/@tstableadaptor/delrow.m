function delrow(h)

% Copyright 2005-2017 The MathWorks, Inc.

%% Delete the row at the currently selected position.

%% Build a block of select times to be processed in a single transaction
%% (performance)

%% Get the current row. If its the current editing row jump out of edit
%% mode
selrow = h.Table.getSelectedRows;
if ~isempty(selrow)
    % Remove editing row and re-adjust selected rows
    ind = find(selrow==h.TableModel.getEditRowNumber);
    if ~isempty(ind)
        selrow(ind) = [];
        selrow(selrow>h.TableModel.getEditRowNumber) = ...
            selrow(selrow>h.TableModel.getEditRowNumber)-1;
    end
    
    % Clear the edit
    h.TableModel.resetEdit;
    
    % Get the deleted time series row numbers
    startRow = h.TableModel.getCache.getStartRow;
    tsrownum = h.TableModel.getCache.getTimeseriesRowNumbers(selrow-startRow);
    
    % Delete the rows from the time series. The datachange event should
    % update the table
    if ~isempty(tsrownum)
        if isa(h.Timeseries,'tsdata.tscollection')
            h.Timeseries.delsamplefromcollection('Index',tsrownum(tsrownum>=0));
        else
            h.Timeseries.delsample('Index',tsrownum(tsrownum>=0));
        end
    else
        % If we are deleting an invalid edit row, force the table to refresh
        h.Timeseries.fireDataChangeEvent;
    end
end