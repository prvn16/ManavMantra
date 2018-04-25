%DisplayInfo Structure holding information required to display a tall array
%   Also includes underlying implementations of display methods.

% Copyright 2016-2017 The MathWorks, Inc.
classdef DisplayInfo
    properties (SetAccess = immutable, GetAccess = private)
        % Function to emit a blank line if necessary (tied to 'format loose')
        BlankLineFcn
    end
    properties (SetAccess = immutable)
        % Does the destination support hyperlinks
        IsHot
        % Do we have preview data
        IsPreviewAvailable
        % Name of the array we're displaying
        Name
        % Structure returned by getArrayInfo
        ArrayInfo
    end
    
    methods (Access = private)
        function [arrayType, isEmpty] = calculateArrayType(~, dataClass, dataNDims, dataSize)
        % Calculate a word to describe the array. Same logic also works out whether the
        % size needs to be shown.
            
            arrayType = 'Array';
            isEmpty   = any(dataSize == 0);
            isScalar  = isequal(dataSize, [1 1]);
            % (time)tables never show any "array" or "matrix" information.
            isTabular = any(strcmp(dataClass, {'table', 'timetable'}));
            % cell arrays *always* show "array" and size
            isCell    = strcmp(dataClass, 'cell');
            
            % Only numeric matrices can use the 'row vector' type descriptions.
            canUseShapeDescription = dataNDims == 2 && ismember(dataClass, iNumericClasses());
            
            if isScalar && ~isCell
                % Note that this isn't a "normal" array type; rather, it's an indication that
                % the size should not be shown. (Takes precedence over 'Tabular')
                arrayType = 'Scalar';
            elseif isTabular
                % Size should be shown (if non-scalar), but never "array"/"matrix" etc.
                arrayType = 'Tabular';
            elseif canUseShapeDescription
                if all(dataSize ~= 1)
                    arrayType = 'Matrix';
                elseif dataSize(1) == 1
                    arrayType = 'RowVector';
                else
                    arrayType = 'ColumnVector';
                end
            end
        end
        
        function szStr = calculateSizeStr(~, dataNDims, dataSize)
        % Calculate a MxNx... or similar size string.
            
            strArr = matlab.bigdata.internal.util.getArraySizeAsString(dataNDims, dataSize);
            
            % Join together dimensions using the TIMES character.
            szStr = strjoin(cellstr(strArr), getTimesCharacter());
        end
        
        function printXEqualsLine(obj, dataClass, dataNDims, dataSize)
        % Print the "x = " line and also the array type/size line as appropriate.
            
            [arrayType, isEmpty] = calculateArrayType(obj, dataClass, dataNDims, dataSize);
            sizeStr = calculateSizeStr(obj, dataNDims, dataSize);
            
            obj.blankLine();
            fprintf('%s =\n', obj.Name);
            obj.blankLine();

            % Compute the message describing size and type etc.
            arrayInfoStr = iComputeMessage(obj.IsHot, arrayType, sizeStr, isEmpty, dataClass);
            
            fprintf('  %s\n', arrayInfoStr);
            obj.blankLine();
        end
        
        function displayPreviewData(obj, previewData, isTruncated)
        % Print out the preview data, adding the continuation characters as required.

            if isempty(previewData)
                return
            end
            
            % Start with the builtin DISP version - except for scalar
            % string objects so long as they are not <missing>
            % (g1434459); and also char data (g1459387)
            if isstring(previewData) && isscalar(previewData) && ~ismissing(previewData)
                previewText = iIndentScalarStringText(previewData);
            elseif ischar(previewData)
                previewText = iIndentCharText(previewData);
            elseif iscell(previewData)
                previewText = matlab.internal.display.getCellDisplayOutput(previewData);
            else
                previewText = evalc('disp(previewData)');
            end

            % Keep from the first to the last non-empty lines
            previewLines  = strsplit(previewText, newline, ...
                'CollapseDelimiters', false);
            nonEmptyLines = ~cellfun(@isempty, previewLines);
            previewLines  = previewLines(find(nonEmptyLines, 1, 'first'):find(nonEmptyLines, 1, 'last'));
           
            % Remove any <strong></strong> tags from the display 
            if ~obj.IsHot
                previewLines = regexprep(previewLines, '</?strong>', '');
            end
            
            if ~ismatrix(previewData)
                % For >2D data, prepend the variable name to the lines like "x(:,:,1) =". Also
                % note that some data type displays (e.g. datetime) miss pieces
                % out, and string adds extra whitespace.
                previewLines = regexprep(previewLines, '^(\(.*\))( =)?( *)$', [obj.Name, '$1$2$3']);
            end

            if isTruncated
                if istable(previewData) || istimetable(previewData)
                    % Table display never wraps, so we can do something relatively simple here.
                    iDisplayTablePreviewLinesWithContinuation(previewLines);
                else
                    iDisplayTruncatedPreviewLines(obj.Name, previewData, previewLines);
                end
            else
                fprintf('%s\n', previewLines{:});
            end
            obj.blankLine();
        end
        
        function displayQueries(obj, dataNDims, dataSize)
        % Print a matrix of ? characters to indicate we don't know what's going on.
            maxQueriesToDisplay = matlab.bigdata.internal.util.defaultHeadTailRows();
            if isnan(dataNDims) || dataNDims > 2 || all(isnan(dataSize)) || ...
                    all(dataSize > maxQueriesToDisplay)
                % Print a matrix of ? for cases:
                % 1. NDims unknown
                % 2. NDims > 2
                % 3. NDims known, but all sizes unknown
                % 4. All dims > 3
                txt = [repmat(sprintf('    ?    ?    ?    ...\n'), 1, 3), ...
                       repmat(sprintf('    :    :    :\n'), 1, 2)];
                fprintf('%s', txt);
            else
                % Try and make the shape of the matrix reflect the known dimensions. Here, we
                % can assume 2-D. Treat unknown sizes as 3, and then clamp to the value
                % matlab.bigdata.internal.util.defaultHeadTailRows()
                
                extend = isnan(dataSize) | dataSize > maxQueriesToDisplay;
                dataSize(isnan(dataSize)) = 3;
                numQueries = min(maxQueriesToDisplay, dataSize);
                
                normalRow = repmat('    ?', 1, numQueries(2));
                if extend(2)
                    normalRow = [normalRow, '   ...'];
                end
                textRows = repmat({normalRow}, numQueries(1), 1);
                fprintf('%s\n', textRows{:});
                if extend(1)
                    extendRow = repmat('    :', 1, numQueries(2));
                    fprintf('%s\n%s\n', extendRow, extendRow);
                end
            end
            obj.blankLine();
        end
        
        function displayHint(obj)
            if obj.IsHot
                % Only display the hint in 'hot' mode where the hyperlink can function.
                fprintf('%s\n', getString(message('MATLAB:bigdata:array:UnevaluatedArrayDisplayFooter')));
                obj.blankLine();
            end
        end
    end
    
    methods
        function obj = DisplayInfo(name, arrayInfo)
            obj.Name = name;
            formatSpacing = get(0,'FormatSpacing');
            obj.IsHot = matlab.internal.display.isHot;
            if isequal(formatSpacing,'compact')
                obj.BlankLineFcn = @()[];
            else
                obj.BlankLineFcn = @() fprintf('\n');
            end
            obj.IsPreviewAvailable = arrayInfo.IsPreviewAvailable;
            obj.ArrayInfo = arrayInfo;
        end
        function blankLine(obj)
            feval(obj.BlankLineFcn);
        end
        function doDisplay(obj)
            printXEqualsLine(obj, obj.ArrayInfo.Class, obj.ArrayInfo.Ndims, obj.ArrayInfo.Size);
            if obj.IsPreviewAvailable
                displayPreviewData(obj, obj.ArrayInfo.PreviewData, obj.ArrayInfo.IsPreviewTruncated);
            else
                displayQueries(obj, obj.ArrayInfo.Ndims, obj.ArrayInfo.Size);
                displayHint(obj);
            end
        end
        function doDisplayWithFabricatedPreview(obj, fabricatedPreview, previewClass, dataNDims, dataSize)
        % Call this to apply a fabricated preview array. The fabricated preview is
        % presumed to be truncated.
            printXEqualsLine(obj, previewClass, dataNDims, dataSize);
            isPreviewTruncated = isnan(dataNDims) || size(fabricatedPreview, 1) ~= dataSize(1);
            displayPreviewData(obj, fabricatedPreview, isPreviewTruncated);
            displayHint(obj);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vals = iNumericClasses()
    integerTypeNames = strsplit(strtrim(sprintf('int%d uint%d ', ...
                                                repmat([8, 16, 32, 64], 2, 1))));
    vals  = ['single', 'double', integerTypeNames];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Given a line of display content, generate a line of continuation
% indicators. We look for groups of non-space characters, and place a single
% ":" in the middle of each group.
function contLine = iGetContinuationLineFromContentLine(txtLine)
    % Find extents of non-whitespace characters
    nonSpaceGroups = regexp(txtLine, '(\S*)', 'tokenExtents');
    if isempty(nonSpaceGroups)
        % Get here if txtLine is completely empty (don't think that can happen) or
        % contains only whitespace (can happen for char display). Either way,
        % treat first column as non-whitespace.
        contLine = ':';
    else
        % Find the middle of the non-whitespace groups
        contPosns = floor(cellfun(@mean, nonSpaceGroups));
        % Make a string that has ':' at the middle of each group.
        contLine  = repmat(' ', 1, max(contPosns));
        contLine(contPosns) = ':';
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iDisplayTablePreviewLinesWithContinuation(previewLines)
% We're looking for the table display '___' lines, here
% we always need to remove the <strong> tags first
    previewLinesNoEmph = regexprep(previewLines, '</?strong>', '');
    linesMatch         = regexp(previewLinesNoEmph, '^(_|\s)+$');
    lineIdx            = find(~cellfun(@isempty, linesMatch), 1, 'first');
    txtLine            = previewLinesNoEmph{lineIdx};
    contLine           = iGetContinuationLineFromContentLine(txtLine);
    fprintf('%s\n', previewLines{:}, contLine, contLine);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For display purposes, this divides a cell array of lines into chunks delimited
% by the supplied regular expression. Because of the way the display stuff
% works, the first chunk returned contains all lines preceding the first
% occurence of the regular expression, at most one instance of that regular
% expression, and then a bunch of lines up to but not including the next
% instance of the regular expression. For example, given output like this:
%
% 1
% 1 Columns 1 through 3
% 1
% 1   0.7742    0.4527    0.8970
% 1   0.0822    0.1448    0.4540
% 1   0.7278    0.0879    0.8887
% 1
% 2 Column 4
% 2
% 2   0.4053
% 2   0.5513
% 2   0.0864
% 2
%
% The preceding digits indicate which chunk the line would count as, presuming a
% delimiter of '^\s*(Columns \d+ through \d+|Column \d+)$'.
function chunks = iDivideLinesIntoChunksByRegexp(allLines, delimiterRegexp)
    matchingLines = find(~cellfun(@isempty, regexp(allLines, delimiterRegexp)));
    if numel(matchingLines) < 1
        % Either zero or one delimiters - return all output as a single chunk.
        chunks = {allLines};
    else
        chunks = cell(1, numel(matchingLines));
        startIdx = [1, matchingLines(2:end)];
        endIdx = [matchingLines(2:end) - 1, numel(allLines)];
        for idx = 1:numel(matchingLines)
            chunks{idx} = allLines(startIdx(idx):endIdx(idx));
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iDisplayTruncatedPreviewLinesOneSetOfColumns(linesOneSetOfColumns)
    nonEmptyLines = ~cellfun(@isempty, linesOneSetOfColumns);
    firstNonBlank = find(nonEmptyLines, 1, 'first');
    lastNonBlank  = find(nonEmptyLines, 1, 'last');
    linesOneSetOfColumnsTrimmed  = linesOneSetOfColumns(firstNonBlank:lastNonBlank);
    contLine = iGetContinuationLineFromContentLine(linesOneSetOfColumnsTrimmed{end});
    fprintf('%s\n', linesOneSetOfColumnsTrimmed{:}, contLine, contLine, ...
            linesOneSetOfColumns{lastNonBlank+1:end});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function expression = iGetColumnDelimiterRegexp()
    str1 = getString(message('MATLAB:services:printmat:Columns',999,999));
    str2 = getString(message('MATLAB:services:printmat:Column',999));
    expression = ['^\s*(', strrep(str1, '999', '\d+'), '|', ...
                  strrep(str2, '999', '\d+'), ')$'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iDisplayTruncatedPreviewLinesOnePage(linesOnePage)
% On this page, find the last non-blank line and use that to generate
% continuations.
    
    columnDelimiterRegexp = iGetColumnDelimiterRegexp();
    columnChunks = iDivideLinesIntoChunksByRegexp(linesOnePage, columnDelimiterRegexp);
    cellfun(@iDisplayTruncatedPreviewLinesOneSetOfColumns, columnChunks);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iDisplayTruncatedPreviewLines(varName, ~, previewLines)
% First, split into pages
    pageDelimiterRegexp = ['^', varName, '\([^\)]+\)( =)? *$'];
    pageChunks = iDivideLinesIntoChunksByRegexp(previewLines,pageDelimiterRegexp);
    cellfun(@iDisplayTruncatedPreviewLinesOnePage, pageChunks);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add leading spaces to each line for a scalar string. Non-scalar strings work
% fine using the "disp" version of the data.
function indentedText = iIndentScalarStringText(stringText)
    % First, convert \r\n to \n
    stringText = strrep(stringText, compose("\r\n"), compose("\n"));
    % Finally, indent lines correctly by replacing either \r or \n to indentation
    stringText = strrep(stringText, compose("\n"), compose("\n     "));
    stringText = strrep(stringText, compose("\r"), compose("\r     "));
    indentedText = sprintf("    ""%s""", stringText);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Indent char data for display. "disp" output is no use here.
function indentedText = iIndentCharText(charText)
    if isrow(charText)
        % A single char vector - in this case, we simply need to indent the text and add
        % quotes.
        indentedText = sprintf('    ''%s''', ...
                               strrep(charText, newline, sprintf('\n     ')));
    else
        % Start by converting the char array into a string array, using NUM2CELL to
        % reduce each row into a cell.
        stringRows   = string(num2cell(charText, 2)); %#ok<NASGU> used in EVALC

        % Here we are relying on string/disp to do the right thing in terms of adding
        % linefeed and arrow characters.
        indentedText = evalc('disp(stringRows)');
        
        % Fix up quotes - change " to '.
        indentedText = regexprep(indentedText, '^(\s+)"', '$1''', 'lineanchors');
        indentedText = regexprep(indentedText, '"$', '''', 'lineanchors');
        
        % Fix up whitespace added by string display to match what should be emitted by
        % char display.
        indentedText = regexprep(indentedText, '= $', '=', 'lineanchors');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construct the "2x3 tall double column vector" from the available information.
function str = iComputeMessage(isHot, arrayType, sizeStr, isEmpty, dataClass)

    % Get the "tall double" piece, with hyperlink if appropriate.
    if isHot
        if isempty(dataClass)
            tallAndClassDescr = getString(message(...
                'MATLAB:bigdata:array:TallClassDescHotNoClass'));
        else            
            tallAndClassDescr = getString(message(...
                'MATLAB:bigdata:array:TallClassDescHot', dataClass));
        end
    else
        if isempty(dataClass)
            tallAndClassDescr = getString(message(...
                'MATLAB:bigdata:array:TallClassDescNoClass'));
        else
            tallAndClassDescr = getString(message(...
                'MATLAB:bigdata:array:TallClassDesc', dataClass));
        end
    end
    
    if strcmp(arrayType, 'Scalar')
        % Scalars (including tables) just get 'tall double' piece.
        str = tallAndClassDescr;
    elseif strcmp(arrayType, 'Tabular')
        % Tables never get the array/matrix piece.
        str = [sizeStr ' ' tallAndClassDescr];
    else
        % All other cases use messages from MATLAB:services:printmat.
        if isEmpty
            id = ['MATLAB:services:printmat:Empty', arrayType];    
        else
            id = ['MATLAB:services:printmat:', arrayType];
        end
        str = getString(message(id, sizeStr, tallAndClassDescr));
    end
end
