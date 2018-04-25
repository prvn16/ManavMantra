function [numericData, textData, rawData] = xlsreadXLSX(file, sheet, range)
    % xlsreadXLSX is the Office OpenXML implementation of xlsread. 
    %   [NUM,TXT,RAW]=xlsreadXLSX(FILE,SHEET,RANGE) unzips and parses through
    %   XML to extract data.  It reads from the specified SHEET and RANGE.
    %
    %   See also XLSREAD, XLSWRITE, XLSFINFO.

    %   Copyright 1984-2014 The MathWorks, Inc.

    % Requires java to unzip xlsx files
    if ~usejava('jvm')
        error(message('MATLAB:xlsread:noJVM'))
    end;
    
    [sharedStrings, parsedSheetData, range] = getXLSXData(file, sheet, range);
    
    % Convert parsedSheetData structure into sheetDesc structure
    [sheetDesc.rowNumbers, sheetDesc.colNumbers] = rangeToSubscripts(char(parsedSheetData.ranges));
    
    % Types defined here: http://msdn.microsoft.com/en-us/library/documentformat.openxml.spreadsheet.cellvalues%28office.14%29.aspx    
    types = {parsedSheetData.types}';
    
    % Numerics (n) and empty type are both treated as numeric
    types = regexprep(types,'^t="(n)"','$1');
    types(cellfun('isempty', types)) = {'n'};

    % String (literals in the spreadsheet - aka NOT SharedStrings)
    types = regexprep(types,'^t="str"','i');

    % SharedStrings (s), Boolean (b), and Errors (e).  The latter are not used.
    types = regexprep(types,'^t="([sbe])"','$1');

    % XML preserved space
    % http://msdn.microsoft.com/en-us/library/ms256097.aspx
    valAttrib = regexprep({parsedSheetData.valAttrib},'.*xml:space="preserve".*','x', 'once');
    valAttrib = regexprep(valAttrib,'^[^x]*$','a','emptymatch');
    sheetDesc.types = [types{:}]';
    sheetDesc.types(strfind([valAttrib{:}],'x'))='x';
    
    
    % Gather up values, numeric values and their locations.
    sheetDesc.values = {parsedSheetData.values}';
    strMatrix = char(parsedSheetData.values);
    strMatrix(:,size(strMatrix,2)+1) = 0;
    sheetDesc.numericValues = matlab.iofun.internal.excel.xlsreadStr2Dbl(strMatrix);
    sheetDesc.numericValLocs = ~isnan(sheetDesc.numericValues);
    
    % Determine the bounding box for the cell array
    [topEdge, leftEdge, bottomEdge, rightEdge] = getRangeCorners(range);
    boundingBox.top = min(topEdge, bottomEdge);
    boundingBox.bottom = max(topEdge, bottomEdge);
    boundingBox.left = min(leftEdge, rightEdge);
    boundingBox.right = max(leftEdge, rightEdge);
    
    % Handle the range equivalent to the entire row or column.
    if boundingBox.top==0 && boundingBox.bottom == 0
        boundingBox.bottom = max(sheetDesc.rowNumbers);
        boundingBox.top = 1;
    end
    if boundingBox.left==0 && boundingBox.right == 0
        boundingBox.right = max(sheetDesc.colNumbers);
        boundingBox.left = 1;
    end
    
    % Define "BoundingBox" aka bb (the range containing actual data
    % Strip cell outside our bounding box and adjust row and columns reference to the "new" upper-left
    insideBoundingBox = (sheetDesc.rowNumbers >= boundingBox.top) & ...
        (sheetDesc.rowNumbers <= boundingBox.bottom) & ...
        (sheetDesc.colNumbers >= boundingBox.left) & ...
        (sheetDesc.colNumbers <= boundingBox.right);
    
    sheetDesc.rowNumbers     = sheetDesc.rowNumbers(insideBoundingBox) + 1 - boundingBox.top;
    sheetDesc.colNumbers     = sheetDesc.colNumbers(insideBoundingBox) + 1 - boundingBox.left;
    sheetDesc.types          = sheetDesc.types(insideBoundingBox);
    sheetDesc.values         = sheetDesc.values(insideBoundingBox);
    sheetDesc.numericValues  = sheetDesc.numericValues(insideBoundingBox);
    sheetDesc.numericValLocs = sheetDesc.numericValLocs(insideBoundingBox);
    
    % Populate final output cell called rawData by subsasgn (indexing) into
    % the cell array and assigning different values from "cells" struct.
    % Create the output cell array
    sizeRawData = [1 + boundingBox.bottom - boundingBox.top, 1 + boundingBox.right - boundingBox.left];
    rawData = cell(sizeRawData);
    rawData(:) = {nan};
    rawData = rawData(:);
    
    % These are numeric data
    subI = sheetDesc.types=='n' & sheetDesc.numericValLocs;
    rawDataI = sub2ind(sizeRawData, sheetDesc.rowNumbers(subI), sheetDesc.colNumbers(subI));
    rawData(rawDataI) = num2cell(sheetDesc.numericValues(subI)); % Cleanly extracted
    processed = subI;
    
    subI = sheetDesc.types=='b' & sheetDesc.numericValLocs;
    rawDataI = sub2ind(sizeRawData, sheetDesc.rowNumbers(subI), sheetDesc.colNumbers(subI));
    rawData(rawDataI) = num2cell(logical(sheetDesc.numericValues(subI))); % Cleanly extracted
    processed = processed | subI;
    
    % The rest is text data
    % Dereference all the shared strings - numericValLocs point to elements in
    % sharedStrings.
    subI = sheetDesc.types=='s' & sheetDesc.numericValLocs;
    rawDataI = sub2ind(sizeRawData, sheetDesc.rowNumbers(subI), sheetDesc.colNumbers(subI));
    rawData(rawDataI) = sharedStrings(sheetDesc.numericValues(subI)+1); % Cleanly extracted
    processed = processed | subI;
    
    % XML preserved space
    subI = sheetDesc.types=='x';
    rawDataI = sub2ind(sizeRawData, sheetDesc.rowNumbers(subI), sheetDesc.colNumbers(subI));
    rawData(rawDataI) = {' '};
    processed = processed | subI;
    
    % Everything else i.e. in-line strings and dates
    subI = ~processed;
    rawDataI = sub2ind(sizeRawData, sheetDesc.rowNumbers(subI), sheetDesc.colNumbers(subI));
    valueCell = sheetDesc.values(subI);
    valueCell = cellfun(@deblank, valueCell, 'UniformOutput', false);
    rawData(rawDataI) = valueCell;
    
    rawData = reshape(rawData, sizeRawData);
    
    rawData = unEscapeEscapedXMLTags(rawData);
    [numericData, textData] = xlsreadSplitNumericAndText(rawData);
end

%==============================================================================
function [sharedStrings, parsedSheetData, range] = getXLSXData(file, sheet, range)
    
    % Unzip the XLSX file (a ZIP file) to a temporary location
    baseDir = tempname;
    cleanupBaseDir = onCleanup(@()rmdir(baseDir,'s'));
    unzip(file, baseDir);
    
    sharedStrings = extractSharedStrings(baseDir);
    
    % Determine which worksheet file to open
    sheetIndex = sheetNameToIndex(baseDir, sheet);
    [range, sheet] = getNamedRange(baseDir, range, sheet, sheetIndex, file);

    % Read data from worksheets/sheet###.xml
    workSheetFile = fullfile(baseDir, 'xl', 'worksheets', sprintf('sheet%d.xml', sheet));
    try
        sheetData = fileread(workSheetFile);
    catch exception                                                            
        error(message('MATLAB:xlsread:WorksheetNotFound', num2str(sheet)));
    end
        
    [parsedSheetData, range] = extractDataAndRange(sheetData, range);
end

%==============================================================================
function sharedStrings = extractSharedStrings(baseDir)
    
    fid  = fopen(fullfile(baseDir, 'xl', 'sharedStrings.xml'), 'r', 'n', 'UTF-8');
    sharedStrings = '';
    if fid ~= -1
        sharedStrings = fread(fid, 'char=>char')';
        fclose(fid);
        
        % Rich text is captured across multiple "<t>" nodes (so the number of <t> nodes may outnumber
        % the number of <si> (the real number of strings), we need to concatenate multiple <t>'s
        % into single <si>'s.
        stringItemElements = regexp(sharedStrings,'<si>(.*?)</si>','tokens');
        
        sharedStrings = {};
        if ~isempty(stringItemElements)
            groupedTextElements = regexp([stringItemElements{:}],'<t.*?>(?<textElements>.*?)</t>','names');
            for i=length(groupedTextElements):-1:1
                if isempty(groupedTextElements{i})
                    sharedStrings{i} = '';
                else
                    sharedStrings{i} = [groupedTextElements{i}.textElements];
                end
            end
        end
    end
end

%==============================================================================
function [parsedSheetData, range] = extractDataAndRange(sheetData, range)
    
    % Use regexp to extract Data from XML tags.
    % CELL class in OpenXML format
    % http://msdn.microsoft.com/en-us/library/documentformat.openxml.spreadsheet.cell.aspx
    parsedSheetData = regexp(sheetData, ...
        ['<c' ...                                            % Begin of cell node
        '\s+r="(?<ranges>[A-Z]+\d+)"' ...                    % "Cell reference" aka range (required)
        '\s*(?:s="\d+")?' ...                          % Style - may contain date format (optional, unused)
        '\s*(?<types>t="(\w+)")?\s*>' ...                    % Cell data type - (optional) http://msdn.microsoft.com/en-us/library/documentformat.openxml.spreadsheet.cellvalues%28office.14%29.aspx
        '\s*(?:<f.*?(>.*?</f>|/>))?' ...            % Formula (optional)
        '\s*<v(?<valAttrib>.*?)(?#4)(/)?>(?<values>(?(4)|.*?))(?(4)|</v>)' ... % Values and value_attributes (required) % 4 is the token number for '/'
        '\s*</c>' ], ...                                     % End of cell node
        'names');
    
    % Determine range of entire sheet (if not passed in by caller)
    if isempty(range)
        span = regexp(sheetData, '<dimension[^>]+ref="(?<start>[A-Z]+\d+)(?<end>:[A-Z]+\d+)?"[^>]*>', 'names', 'once');
        if isempty(span.end)
            span.end = [':' span.start];
        end
        range = [span.start span.end];
    end
    
end

%==============================================================================
function sheetIndex = sheetNameToIndex(baseDir, sheetName)
    
    % Look up a worksheet by name (string)
    workbook_xml_rels = fileread(fullfile(baseDir, 'xl', '_rels', 'workbook.xml.rels'));
    workbook_xml = fileread(fullfile(baseDir, 'xl', 'workbook.xml')); 
    sheetNames = getSheetNames(workbook_xml_rels, workbook_xml);
    if ~ischar(sheetName)
        sheetIndex = sheetName;
    else
        sheetIndex = find(strcmp(sheetNames,sheetName));
    end
    if isempty(sheetIndex)
        error(message('MATLAB:xlsread:WorksheetNotFound', sheetName));
    end
    
end

%==============================================================================
function [rowNumber, colNumber] = rangeToSubscripts(range)
    
    range = upper(range);
    rowNumber=zeros(size(range,1),1);
    colNumber=zeros(size(range,1),1);
    
    for i = 1:size(range,2);
        columnOfRange = range(:,i);
        
        alphaMatch = isletter(columnOfRange);
        colNumber = alphaMatch .* (colNumber*26 + 1 + columnOfRange-'A') + colNumber .* ~alphaMatch;
        
        numberMatch = columnOfRange>= '0' & columnOfRange <= '9';
        rowNumber = numberMatch .* (rowNumber*10 + columnOfRange-'0') + rowNumber .* ~numberMatch;
    end
end

%==============================================================================
function rawData = unEscapeEscapedXMLTags(rawData)
    if iscell(rawData)
        % Unescape characters already escaped in XML
        strIndicies = cellfun('isclass',rawData,'char');
        xmlRsvd = { '&quot;', '&amp;', '&apos;', '&lt;', '&gt;'};
        xmlSubs = { '"',      '&',     '''',     '<',    '>'};
        for i = 1:length(xmlRsvd)
            rawData(strIndicies) = strrep(rawData(strIndicies), xmlRsvd{i}, xmlSubs{i});
        end
        rawData(strIndicies) = regexprep(rawData(strIndicies), '\r\n', '\n');
    end
end

%==============================================================================
function validateRangeSegment(rangeSegment)
    % Make sure that the rangeSegment is a valid A1 Excel range. 
    if isempty(regexpi(rangeSegment,'^[A-Z]*\d*$', 'once','emptymatch'));
        error(message('MATLAB:xlsread:RangeSelection', rangeSegment));
    end
end

%==============================================================================
function [rowNumber, columnNumber] = validateAndParseRangeSegment(rangeSegment)
    % validateRangeSegment, then call rangeToSubscripts to parse the segment
    % into a row/column number.
    validateRangeSegment(rangeSegment);
    [rowNumber, columnNumber] = rangeToSubscripts(rangeSegment);
end

%==============================================================================
function [topEdge, leftEdge, bottomEdge, rightEdge] = getRangeCorners(range)
    rangeSegments = regexp(range,':', 'split', 'once');
    [topEdge, leftEdge] = validateAndParseRangeSegment(rangeSegments{1});
    
    if length(rangeSegments) > 1
        [bottomEdge, rightEdge] = validateAndParseRangeSegment(rangeSegments{2});
        if xor(topEdge, bottomEdge) || xor(leftEdge, rightEdge) 
            % Each rangeSegment must specify both a column (letter) and a row
            % (number) or EITHER a column or a row.  If it's the later two, the
            % other rangeSegment must specify ONLY the same vector (either a row or a
            % column).  For example, C1:C will be caught.
            error(message('MATLAB:xlsread:RangeSelection', rangeSegments{2}));
        end
    elseif topEdge && leftEdge
        % If there isn't a second segment, then the first segment must specify
        % both a row and a column.  In that case the range is a scalar, so make the
        % bottom right corner equal the top left.
        bottomEdge = topEdge;
        rightEdge = leftEdge;
    else
        error(message('MATLAB:xlsread:RangeSelection', range));        
    end
end

%==============================================================================
function [range, sheetNum] = getNamedRange(baseDir, range, sheet, sheetIndexFromSheetArgument, file)
    % getNamedRange resolve named ranges to its value of sheet number and range.
    sheetNum = sheetIndexFromSheetArgument;
    
    % Parse the XML to find if "range" is a defined named range, and if so what
    % its scope is.
    [scopeAndRange, prefixFromInput] = parseWorkbookForScopeAndRange(range, baseDir);
     
    % If range is not a named range return from this function. 
    if isempty(scopeAndRange)
        return;
    end
    
    % Resolve named range to appropriate sheet and scope.  Results in a range
    % in the format of (Sheet#!A1:B2).
    rangeCandidate = getRangeCandidate(scopeAndRange, prefixFromInput, file, baseDir, ...
                                       sheetIndexFromSheetArgument, range, sheet);    
    
    % Note rangeCandidates.range ALWAYS have a sheet name before an !-mark. Always.
    sheetNameAndRangeInRangeCandidate = regexp(rangeCandidate,'!','split', 'once');
    sheetNameInRangeCandidate = sheetNameAndRangeInRangeCandidate{1};
    range = sheetNameAndRangeInRangeCandidate{2};

    % If sheet is numeric, then the only way to compare it to
    % sheetNameInRangeCandidate it to convert sheetNameInRangeCandidate to a
    % number.
    if isnumeric(sheet) || ~strcmp(sheetNameInRangeCandidate, sheet)
        try
            % Overwrite sheetNum with new value.
            sheetNum = sheetNameToIndex(baseDir, sheetNameInRangeCandidate);
        catch exception
            % If sheetNameInRangeCandidate did not resolve to a valid sheet name then
            % the named range is not valid.
            error(message('MATLAB:xlsread:NamedRangeNotSupported', range, rangeCandidate));
        end
    end
       
    range = strrep(range, '$', '');
end


%==============================================================================
function [scopeAndRange, prefixFromInput] = parseWorkbookForScopeAndRange(range, baseDir)
    % Parse the XML to find if "range" is a defined named range, and if so what
    % its scope is.
    
    % Break up range to prefix and namedRange.
    parts = regexp(range, '!', 'split', 'once');
    if isscalar(parts)
        prefixFromInput = '';
        namedRange = parts{1};
    else
        prefixFromInput = parts{1};
        namedRange = parts{2};
    end
    
    % Read and parse XML.
    workbookData = fileread(fullfile(baseDir, 'xl', 'workbook.xml'));
    scopeAndRange = regexp(workbookData,...
        ['<definedName\s+name="' regexptranslate('escape',namedRange) '"'...
         '(?<dummy>\s+localSheetId=")?'...
         '(?<scopeSheetNumber>(?(dummy)\d+))(?(dummy)")>'...
         '(?<range>.*?)</definedName>'],...
         'names');
end

%==============================================================================
function rangeCandidate = getRangeCandidate(scopeAndRange, prefixFromInput, file, baseDir, ...
                                            sheetIndexFromSheetArgument, range, sheet)
    % Named range resolution will follow the following presedence:
    % 1) Sheet prefix from RANGE argument
    % 2) Sheet from SHEET argument
    % 3) Global, only used if the name is unique in spreadsheet and not scoped.
    scopeAndRangeMatchIndex = [];
    listOfSheetNumberScopes = str2double({scopeAndRange.scopeSheetNumber})+1;
    prefixFromInputFound = ~isempty(prefixFromInput);
    % Check prefix for filename specifying global scope.
    [~, filename, fileext] = fileparts(file);
    prefixIsFilenameMeaningGlobalScope = strcmp(prefixFromInput, [filename fileext]);
    
    % Resolve name and find scope
    if ~prefixIsFilenameMeaningGlobalScope
        if prefixFromInputFound
            sheetNumberOfPrefixSheet = sheetNameToIndex(baseDir, prefixFromInput);
            scopeAndRangeMatchIndex = listOfSheetNumberScopes == sheetNumberOfPrefixSheet;
        elseif length(scopeAndRange) > 1
            scopeAndRangeMatchIndex = listOfSheetNumberScopes == sheetIndexFromSheetArgument;
        elseif ~isempty(scopeAndRange.scopeSheetNumber)
            scopeAndRangeMatchIndex = 1;
        end
    end
    
    % If scopeAndRangeMatchIndex is all false, then the named range is global.
    if ~any(scopeAndRangeMatchIndex) || prefixIsFilenameMeaningGlobalScope
        scopeAndRangeMatchIndex = cellfun('isempty', {scopeAndRange.scopeSheetNumber});
    elseif ~prefixFromInputFound
        % This is the case that scopeAndRange.scopeSheetNumber specifies the scope
        % (not the prefix, or either of the global cases
        % (scopeAndRange.scopeSheetNumber == '', and prefix is filename)).
        sheetNumberFromScopeInXML = listOfSheetNumberScopes(scopeAndRangeMatchIndex);
        if sheetNumberFromScopeInXML~=sheetIndexFromSheetArgument  
            error(message('MATLAB:xlsread:NamedRangeNotInScope', range, sheetNumberFromScopeInXML, sheet));
        end
    end
    
    rangeCandidate = scopeAndRange(scopeAndRangeMatchIndex).range;
end
