classdef CharArrayViewModel < internal.matlab.variableeditor.ArrayViewModel
    %CHARARRAYVIEWMODEL
    %   Char Array View Model

    % Copyright 2014-2017 The MathWorks, Inc.
 
    % Public Abstract Methods
    methods(Access='public')
        % Constructor
        function this = CharArrayViewModel(dataModel)
            this@internal.matlab.variableeditor.ArrayViewModel(dataModel);
        end

        % getRenderedData
        % returns a cell array of strings for the desired range of values
        function [renderedData, renderedDims] = getRenderedData(this,startRow,endRow,startColumn,endColumn)
            data = this.getData(startRow,endRow,startColumn,endColumn); %#ok<NASGU>
            
            % always 1x1 cell view
            renderedData = evalc('disp(data)');
            % ignore line feeds and carriage returns
            renderedData = strrep(renderedData, newline,'');
            renderedData = strrep(renderedData, sprintf('\r'),'');
            
            if length(renderedData) > internal.matlab.variableeditor.FormatDataUtils.MAX_TEXT_DISPLAY_LENGTH
                renderedData = [strjoin(split(num2str(size(renderedData))), this.TIMES_SYMBOL) ' char'];
            end

            % returns 'true' size
            renderedDims = size(renderedData);
        end
        
        % The view model's getSize should always return the values [1 1] 
        % since the view is always a 1x1 cell
        function s = getSize(~)
             % always 1x1 cell view
             s = [1 1];
        end
    end
end


