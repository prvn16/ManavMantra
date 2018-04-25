classdef NumericArrayViewModel < internal.matlab.variableeditor.ArrayViewModel
    %NUMERICARRAYVIEWMODEL
    %   Numeric Array View Model

    % Copyright 2013-2014 The MathWorks, Inc.

    % Public Abstract Methods
    methods(Access='public')
        % Constructor
        function this = NumericArrayViewModel(dataModel)
            this@internal.matlab.variableeditor.ArrayViewModel(dataModel);
        end

        % getRenderedData
        % returns a cell array of strings for the desired range of values
        function [renderedData, renderedDims] = getRenderedData(this,startRow,endRow,startColumn,endColumn)
            fullData = this.DataModel.Data;
            data = this.getData(startRow,endRow,startColumn,endColumn);
            scalingFactor = strings(0,0);                    
            if ~isempty(fullData)
                scalingFactor = internal.matlab.variableeditor.peer.PeerDataUtils.getScalingFactor(fullData);
            end            
            [renderedData, renderedDims] = internal.matlab.variableeditor.peer.PeerDataUtils.getFormattedNumericData(fullData, data, '', scalingFactor);
        end        
    end
end
