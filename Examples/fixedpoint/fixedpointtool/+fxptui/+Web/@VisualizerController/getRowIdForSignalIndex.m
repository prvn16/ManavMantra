function rowId = getRowIdForSignalIndex(this, signalIdx)
%% GETROWIDFORSIGNALINDEX function gets the TableData row index for 
% Visualizer histogram column signal index

%   Copyright 2017 The MathWorks, Inc.
    
    % Visualizer Client renders histogram with a 0-based index. At any
    % point of time, Client has 20 signals with indices from 0-19
    % Visualizer Server stores information about them in a 1-based index
    % The Server side index of the first (of 20_ signals rendered in Client are 
    % stored in StartIndex property of VisualizerEngine. 
    
    % StartIndex + k gives the server side index of kth histogram in Client
    % Offseting this index by -1 gives the correct index in the Server side
    % data.
    tableRowIndex = this.VisualizerEngine.StartIndex + signalIdx - 1;
    rowId = this.VisualizerEngine.TableData.Row(tableRowIndex);
    rowId = rowId{1};
end