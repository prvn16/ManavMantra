%%% Copyright 2011-2017 The MathWorks, Inc.

%   This class is unsupported and might change or be removed without
%   notice in a future version.

classdef TextFileImporter < handle & JavaVisible
    properties(SetAccess = protected)
        FileName;
        RowCount = 0;
        EmptyRowCount = 0;
        ColumnCount = 0;
        FilePointer;
        RowData = {};
        CacheData;
        Delimiters = {' '};
        FixedWidth = false;
        FixedWidthColumnPositions = [];
        MultipleDelimsAsOne = true;
        RowBlockSize = ceil((double(com.mathworks.mlwidgets.importtool.TextFileTableModel.NONWINDOWED_TEXTSIZE(1)))/2);
        ByteCount = 0;
        DecimalSeparator = '.'; % Use for guessing default parsing rules
        SampleData; % Data cache used for inferring defaults
        DefaultHeaderRow = 1;
        NullCharsExist = false;
        IsCJK = com.mathworks.util.LanguageUtils.isCJK();
        HalfWidthCharsExist = false;
        FullWidthCharsExist = false;
        ContainsQuotes = false;
        TextscanTextFormat = 's';
        FileEncoding = '';
        EncodingBOMLength = 0;
        FileEncodingForFOpen = '';
    end
    
    properties (Constant)     
        SampleLines = 20;
        
        % These are the number of lines scanned to detect default column
        % types
        SampleLinesForParseRules = 100;
        
        % These are the number of lines used for categorical detection.
        % This value cannot be larger than the block_size defined below.
        SampleLinesForCategoricalDetection = 1000;
        
        FixedWidthSampleLines = 100;
        RowBufferSize = 1e6;
		block_size = 1000;
        SuggestedDelimMaxLength = 20;
    end
    
    properties(SetAccess = protected, GetAccess = public)
        DstWorkspace = 'caller';
    end
    
    % Cache data struct fields
    % RowData
    % StartRow
    % RowPosition
    % EndRow
    methods
        function this = TextFileImporter(fileNamePath,varargin)
            %TEXTFILEIMPORTER Construct a TextFileImporter object
            %
            %    obj = TextFileImporter(fileNamePath,[DstWorkspace])
            %
            %    Inputs:
            %       fileNamePath - string with fully qualified file name of
            %                      the file to import
            %       DstWorkspace - optional argument specifying the
            %                      workspace the data is imported to, if
            %                      omitted the default 'caller' workspace
            %                      is used
            %
            
            fid = fopen(char(fileNamePath));
            if (fid<0)
                error(message('MATLAB:codetools:TextFileInvalid'));
            end
            this.FileName = fileNamePath;
            this.FilePointer = fid;
            if nargin > 1
                this.DstWorkspace = varargin{1};
            else
                this.DstWorkspace = 'caller';
            end
        end 
 
        % Infer the default delimiter from the sample data using the
        % heuristic that if the sample data contains a tab, comma,
        % semi-colon or space then that character is the default delimiter.
        function delimiter = getDefaultDelimiter(this)
            frewind(this.FilePointer);
            sampleData = this.getSampleData;
            defaultDecimalSeparator = getDefaultDecimalSeparator(this);
            if strcmp(',',defaultDecimalSeparator)
                defaultDelimiters = {sprintf('\t'),';',' '};
            else
                defaultDelimiters = {sprintf('\t'),',',';',' '};
            end
            for k=1:length(defaultDelimiters)
                delimiter = defaultDelimiters{k};
                if sum(count(sampleData, delimiter)) > 0
                    return
                end
            end
            delimiter = '';        
        end
        
        function [headerRow,numericStartRow,startColumn] = getDefaultHeaderRow(this,defaultDelimiter,defaultFixedWidthColumnPositions)
            headerRow = 1;
            foundHeaderRow = false;
            numericStartRow = 1;
            startColumn = 1;
            if this.isCacheDirty
                this.initCache;
            end

            % Read in the initial sample data
            if nargin<3
                defaultFixedWidthColumnPositions = [];
            end
            rowArray = readInSampleLines(this,defaultDelimiter,0,defaultFixedWidthColumnPositions);
            if isempty(rowArray)
                return;
            end
            
            % The default variable name header is the first complete row
            % which contains only cells which begin with letters.
            columnCount = max(cellfun(@length, rowArray));
            for row=1:length(rowArray)
                s = rowArray{row};
                validHeader = regexp(s, '^[ ]*[a-zA-Z]+.*','once');
                if ~iscell(validHeader)
                    validHeader = {validHeader};
                end
                if length(s)==columnCount && all(cellfun(@(x) ~isempty(x), validHeader)) %~isempty(regexp(s,'^[ ]*[a-zA-Z]+.*','once')) % all(cellfun(@(x) ~isempty(x), regexp(rowArray{row},'^[ ]*[a-zA-Z]+.*','once')))
                    headerRow = row;
                    foundHeaderRow = true;
                    break
                end
            end
            this.DefaultHeaderRow = headerRow;

            % Read in sample data after the header row
            if foundHeaderRow
                rowArray = readInSampleLines(this,defaultDelimiter,headerRow,defaultFixedWidthColumnPositions);
            end

            % Find the top left cell for numeric data
            numericStartRowFound = false;
            for row=1:length(rowArray)
                if numericStartRowFound
                    break;
                end
                for col=1:length(rowArray{row})
                    if numericStartRowFound
                        break;
                    end
                    
                    % The numeric start row is a row which contains a pure
                    % number (i.e. no suffix or prefix). The numeric start
                    % columns is a column with non-empty content.
                    [parsedNumber, prefix, suffix] = findNumbersLogical(rowArray{row}(col));
                    thisCellContainesNumber = parsedNumber && ...
                        (strlength(prefix) == 0) && (strlength(suffix) == 0);
                    if ~numericStartRowFound && thisCellContainesNumber
                        numericStartRow = row;
                        
                        % Offset the sample row by the header row
                        if foundHeaderRow
                            numericStartRow = row+headerRow;
                        end
                        numericStartRowFound = true;
                    end
                end
            end
            nonEmptyStartColumns = cellfun(@(x) find(~isempty(x), 1, 'first'), rowArray, 'UniformOutput', false);
            startColumn =  min(cell2mat(nonEmptyStartColumns(~cellfun('isempty',nonEmptyStartColumns))));
            if isempty(startColumn)
                startColumn = 1;
            end
        end
        
        function rowArray = readInSampleLines(this,defaultDelimiter,offsetCount,defaultFixedWidthColumnPositions)
            frewind(this.FilePointer);
            if (offsetCount > 0)
                textscan(this.FilePointer,'%[^\n\r]',offsetCount, 'TextType', 'string');
            end
            if ischar(defaultDelimiter)
                % Read the first this.SampleLines lines as single string
                lineBlock = textscan(this.FilePointer,'%[^\n\r]',this.SampleLines,'WhiteSpace','', 'TextType', 'string');
                sampleData = lineBlock{1};
                
                % Break up each line into delimited cells
                rowArray = cell(length(sampleData),1);
                formatSpec = ['%' this.TextscanTextFormat];
                for row=1:length(sampleData)
                    rowCell = textscan(sampleData{row},formatSpec,'delimiter',defaultDelimiter,...
                        'MultipleDelimsAsOne',strcmp(' ',defaultDelimiter), 'TextType', 'string');
                    rowArray{row} = rowCell{1};
                end
                
                
            elseif ~isempty(defaultFixedWidthColumnPositions)
                sampleData = textscan(this.FilePointer,localcreatefixedwidthformat(diff([0 defaultFixedWidthColumnPositions(:)'])),...
                    this.SampleLines,'Delimiter','','Whitespace','', 'TextType', 'string');
                
                % Create a cell array of row data strings
                nrows = max(cellfun(@length, sampleData));
                sampleDataStrs = horzcat(sampleData{1,:});
                rowArray = cell(nrows, 1);
                for row = 1:nrows
                    rowArray{row, 1} = sampleDataStrs(row, :);
                end
            else
                rowArray = [];
                return
            end
        end
            
        function decimalSeparator = getDefaultDecimalSeparator(this)
            
            % In English locales, just assume a period decimal separator.
            
            % Added the additional condition to check if it is a .csv file
            % to address g862727
            [~,~,fileExtension] = fileparts(this.FileName);
            if strcmp('.',internal.matlab.importtool.TextFileImporter.getSystemDecimalSeparator) || strcmp('.csv',fileExtension)
              decimalSeparator = '.';
              return
            end
            
            % 50% of the characters in the sample lines comprise comma 
            % decimal number separated by whitespace or end-of-line
            frewind(this.FilePointer);
            sampleData = this.getSampleData;
            % regexp is either:
            % Optional number followed by required comma followed by 1 or
            % more numbers followed by optional exponent followed by
            % optional numbers followed by a single delimiter character
            % -or-
            % Required number followed by optional thousands separators (.)
            % followed by optional numbers followed by required comma 
            % followed by optional exponent followed by optional numbers
            % followed by a single delimiter character
            
            % modified the regular expression to make it more specific 
            % change : '[\.]{0,1}[0-9]{3}'
            % This enhances the previous expression by ensuring that in 
            % case of ->[Eg: 10..200..000,5;6,5],where . is not separated by blocks of 3 digits the system assumes an
            % English locale where . is a decimal separator and not a thousands separator.  
            expr = '[ ]*([-\+]{0,1}[0-9]*[,]{1}[0-9]+[eEdD]{0,1}[0-9]*(.+|$)|[0-9]+[\.]{0,1}[0-9]{3}[,]{1}[0-9]*[eEdD]{0,1}[0-9]*(.+|$))+';

            [matchStart, matchEnd] = regexp(sampleData,expr);
            if isscalar(matchStart) && ~iscell(matchStart)
                matchStart = {matchStart};
            end
            if isscalar(matchEnd) && ~iscell(matchEnd)
                matchEnd = {matchEnd};
            end

            numericSequenceLength = 0;
            for k=1:length(matchStart)
                if ~isempty(matchStart{k})
                     numericSequenceLength = numericSequenceLength+sum(matchEnd{k}-matchStart{k}+1);
                end
            end
            relativeNumericBlockCachacters =  numericSequenceLength/...
                sum(strlength(sampleData));
            if relativeNumericBlockCachacters>0.5
                decimalSeparator = ',';
            else
                decimalSeparator = '.';
            end
            
        end
        
        function columnNames = getDefaultColumnNames(this,row,avoidShadow)
            if this.isCacheDirty
                this.initCache;
            end
            data = this.Read(row,row,1,this.getColumnCount);           
            columnNames = internal.matlab.importtool.ImportUtils.getDefaultColumnNames(evalin('caller','who'),data,this.getColumnCount,avoidShadow);
            % Convert to cellstr for JMI
            columnNames = cellstr(columnNames);
        end

        function characterCounts = getCharacterCounts(this)
            if this.isCacheDirty
                this.initCache;
            end
            data = this.Read(1,min(this.FixedWidthSampleLines,this.getRowCount),1,this.getColumnCount);
            characterCounts = max(strlength(data), [], 1);
        end        
            
        % Find all the potential delimiters in the file by analyzing the
        % sample data
        function [delimiters, count] = findDelimiters(this)
            frewind(this.FilePointer);
            sampleData = this.getSampleData;
            % Regular expression defines:
            % Any char one or more times (lazy) followed by a delimiter 
            % (non-alphanumeric/quote) one or more times, followed by any 
            % char one or more times (lazy),followed by the same delimiter, 
            % followed by any character one or more times (lazy), followed 
            % by the same delimiter
            tokens = regexp(sampleData,'.+?([^a-zA-Z0-9''"]+).+?\1.+?\1.*?','tokens');
            delimiters = {};
            for k=1:length(tokens)
                if iscell(tokens{k})
                    delimiters = [delimiters cellfun(@(x) x{:},tokens{k},'UniformOutput',false)]; %#ok<AGROW>
                end
            end  
            [delimiters,~,I] = unique(delimiters,'legacy');
            
            % Limit the delimiters to reasonably sized ones (longer ones
            % are more than likely not valid choices)
            largeDelimiters = cellfun('length', delimiters) > this.SuggestedDelimMaxLength;
            delimiters(largeDelimiters) = [];
            
            count = diff([0 find(diff([sort(I) max(I)+1]))]);
            count(largeDelimiters) = [];
        end
        
        function [state,fixedWidths] = isDefaultFixedWidth(this)
            state = false;
            if ~this.isInitialized
                this.init;
            end
            fixedWidths = [];
            frewind(this.FilePointer);
            testBlock = textscan(this.FilePointer,'%1000s',...
                this.FixedWidthSampleLines, 'Delimiter','','WhiteSpace','', 'TextType', 'string');
            if isempty(testBlock) || ~iscell(testBlock)
                return
            end
            testBlock = testBlock{1};
            
            % 75% of the line lengths must be the same to infer fixed width
            lineLengths = strlength(testBlock);
            [~,F] = mode(lineLengths);
            if F<0.75*length(lineLengths)
                return
            end
            
            % getDefaultFixedWidths must identify at least one fixed width
            % column boundary for fixed width
            fixedWidths = this.getDefaultFixedWidths;
            state = size(fixedWidths,2)>1;
        end
         
        function colCount = getColumnCount(this)
            if this.isCacheDirty
                this.initCache;
            end 
            colCount = this.ColumnCount;
        end
        
        function decimalSeparator = getDecimalSeparator(this)
            decimalSeparator = this.DecimalSeparator;
        end

        function setDecimalSeparator(this,decimalSeparator)
            this.DecimalSeparator = decimalSeparator;
        end
        
        function setMultipleDelimsAsOne(this,state)           
            if ~isequal(this.MultipleDelimsAsOne,state)
                this.reset;
                this.MultipleDelimsAsOne = state;
            end
        end
        
        function state = isMultipleDelimsAsOne(this)
            state = this.MultipleDelimsAsOne;
        end
        
        function halfWidthCharsExist = getHalfWidthCharsExist(this)
            halfWidthCharsExist = this.HalfWidthCharsExist;
        end
 	 
        function fullWidthCharsExist = getFullWidthCharsExist(this)
            fullWidthCharsExist = this.FullWidthCharsExist;
        end
        
        % Use fread (for fast execution) to move the file position forward 
        % by lineShift lines from the beginning of the current line with
        % file position lineFilePosition
        function blockShift(this,lineFilePosition,lineShift)
            % If this is the beginning of the file, and the file has a BOM,
            % skip over it.
            if lineFilePosition <= 0 && ...
                ~isempty(this.FileEncoding) && ...
                this.EncodingBOMLength > 0
                fseek(this.FilePointer, this.EncodingBOMLength, 'bof');
            end

            if lineShift<=0
                return
            end
            
            % Move the file position forward by approximately lineShift
            % lines using fread. The number of bytes is calculated by 
            % using the average bytes per line of the entire file.
            bytesPerLine = round(0.8*this.ByteCount/this.RowCount);
            chunksize = bytesPerLine*lineShift;
            ch = fread(this.FilePointer, chunksize, '*uchar');
            if length(ch)>=3
                Ilf = (ch == newline);
                Icr = (ch == sprintf('\r'));
                lfcount = sum(Ilf);
                crcount = sum(Icr);
                % Empty rows (after the first) contain a newline character
                % preceded by a newline character \n\n or \r\r or \n\r
                emptyrows = sum(Icr(2:end) & Ilf(1:end-1))+sum(Icr(2:end) & Icr(1:end-1))+...
                    sum(Ilf(2:end) & Ilf(1:end-1));            
                % The first row is also blank if the first character is a
                % newline
                if Icr(1) || Ilf(1)
                    emptyrows = emptyrows+1;
                end
                numlines = max(crcount,lfcount)-emptyrows;
            else
                numlines = 1;
            end
                     
            % If a the next 1-2 characters comprise a line break, the line
            % will be ignored by textscan. In this case move the file
            % position past the line break and increment numlines.
            if localskiplinebreak(this.FilePointer)
                % But only increment the line if we've seen a line feed but
                % no carriage return, or if we've hit neither.
                if (Ilf(end) && ~Icr(end)) || (~Ilf(end) && ~Icr(end))
                    numlines=numlines+1;
                end
            end
            
            % Use textscan to advance the file position by the remaining
            % lineShift-numlines
            if numlines>=lineShift % Went to far, use textscan to advance from initial file position
                fseek(this.FilePointer,lineFilePosition,'bof');
                textscan(this.FilePointer,'%[^\n\r]',lineShift,'delimiter','',...
                    'WhiteSpace','', 'TextType', 'string');
            else
                textscan(this.FilePointer,'%[^\n\r]',lineShift-numlines,...
                    'WhiteSpace','','delimiter','', 'TextType', 'string');                
            end
            
            % textscan will leave the file position at a newline character,
            % which will prevent ftell from reporting the file position of
            % the beginning of the next line. In this case, advance the file
            % position by 1.
            localskiplinebreak(this.FilePointer);
        end
                  
        function rowCount = getRowCount(this)
            if ~this.isInitialized
                this.init;
            end
            rowCount = this.RowCount;
        end
        
        function emptyRowCount = getEmptyRowCount(this)
            if ~this.isInitialized
                this.init;
            end
            emptyRowCount = this.EmptyRowCount;
        end
        
        function fileEncoding = getFileEncoding(this)
            if ~this.isInitialized
                this.init;
            end
            fileEncoding = this.FileEncoding;
        end
        
        function fileEncoding = getFileEncodingForFopen(this)
            if ~this.isInitialized
                this.init;
            end
            fileEncoding = this.FileEncodingForFOpen;
        end
        
        function bomLength = getEncodingBOMLength(this)
            if ~this.isInitialized
                this.init;
            end
            bomLength = this.EncodingBOMLength;
        end

        function fixedWidths = getDefaultFixedWidths(this)
            frewind(this.FilePointer);
            testBlock = textscan(this.FilePointer,'%[^\r\n]',...
                    this.FixedWidthSampleLines,'Delimiter','','WhiteSpace','', 'TextType', 'string');            
            if isempty(testBlock) || ~iscell(testBlock)
                fixedWidths = [];
                return
            end
            testBlock = testBlock{1};
            
            % Find the transitions from non-space to space
            I = false([size(testBlock,1) max(strlength(testBlock))]);
            for row=1:size(I,1)
                spaceTransitionvector = (diff(testBlock{row}==' ')>0);
                I(row,spaceTransitionvector) = true;
            end
            
            % If 25% of the transitions occur in the same column there
            % is a default fixed width separator in that column
            fixedWidths = [];
            for col=1:size(I,2)
                if sum(I(:,col))>=0.25*size(I,1)
                    fixedWidths = [fixedWidths col]; %#ok<AGROW>
                end
            end
        end
        
        function state = isFixedWidth(this)
            state = this.FixedWidth;
        end
        
        
        function setRowBlockSize(this,rowBlockSize)
            if ~isequal(this.RowBlockSize,rowBlockSize)
                this.reset;
            end
            this.RowBlockSize = rowBlockSize;
        end
        
        function rowBlockSize = getRowBlockSize(this)
            rowBlockSize = this.RowBlockSize;
        end
        
        function ind = ReadRows(this,startRow,endRow)
            % Loop through the CacheData structs. If one of them contains
            % the row interval then use it

            ind = [];
            if ~isempty(this.CacheData)
                ind = find([this.CacheData.StartRow]<=startRow & ...
                       [this.CacheData.EndRow]>=endRow,1,'first');
                % The requested row block is already cached, so quick
                % return
                if ~isempty(ind)
                     return;
                end
                ind = find([this.CacheData.StartRow]<=startRow,1,'last');
            end
           
            
            % If a previous cached row block exists, move the file position
            % startRow-this.CacheData(ind).StartRow rows forward.
            % Otherwise, move the file position to (startRow,1) from the
            % beginning of the file.
            if ~isempty(ind)
                fseek(this.FilePointer,this.CacheData(ind).RowPosition,'bof');
                blockShift(this,this.CacheData(ind).RowPosition,startRow-this.CacheData(ind).StartRow);
            else
                frewind(this.FilePointer);
                blockShift(this,0,startRow-1);
            end
            
            % Create a CacheData struct and read a line block from startRow
            cacheData = struct('RowData',{{}},'StartRow',startRow,'RowPosition',ftell(this.FilePointer)); 
            if this.FixedWidth % Fixed width parsing
                formatString = localcreatefixedwidthformat(this.getFixedWidthsForColumns);
                lineBlock = textscan(this.FilePointer,formatString,...
                      this.RowBlockSize,'Delimiter','','Whitespace','', 'TextType', 'string');

                if isempty(lineBlock) || ~iscell(lineBlock) 
                    return
                end
                
                % If the last row of data does not contain the same number
                % of columns as the first row of data we need to adjust
                % this to match the number of columns in the other lines.
                % This usually happens when the file does not end with a
                % line break (i.e. \r or \n).
                if ~all(cellfun('length',lineBlock)==length(lineBlock{1}))
                    for i=length(lineBlock):-1:2
                        if length(lineBlock{i})<length(lineBlock{1})
                            lineBlock{i}(length(lineBlock{i})+1:length(lineBlock{1})) = {''};
                        end
                    end
                end
                
                % Strip the last column which contains only empty or newlines
                lineBlock = lineBlock(1:end-1);
               
                % If the file contains null characters, replace them by a
                % space so that when the strings get passed to java they
                % are not terminated at the null character.
                if this.NullCharsExist
                    for col=1:length(lineBlock)            
                        charData = cellfun('isclass',lineBlock{col},'char');
                        lineBlock{col}(charData) = cellfun(@(x) strrep(x,char(0),' '),lineBlock{col}(charData),'UniformOutput',false);
                    end
                end
                
                cacheData.RowData = [lineBlock{:}];
                cacheData.EndRow = length(lineBlock{1})-1+startRow; 
                numCols = length(lineBlock);
                if numCols>this.ColumnCount
                   this.ColumnCount = numCols;
                end
            else % Delimited parsing
                lineBlock = textscan(this.FilePointer,'%[^\n\r]',...
                    this.RowBlockSize,'delimiter','','WhiteSpace','', 'TextType', 'string');
                if isempty(lineBlock) || ~iscell(lineBlock) 
                    return
                end
                cacheData.EndRow = length(lineBlock{1})-1+startRow;

                % Assign the RowData field of the CacheData struct
                formatSpec = ['%' this.TextscanTextFormat];
                for row=1:length(lineBlock{1})
                   try
                      % If the file contains null characters, replace them by a
                      % space so that when the strings get passed to java they
                      % are not terminated at the null character.
                      if this.NullCharsExist
                          lineBlock{1}{row}(lineBlock{1}{row}==0)= ' ';
                      end
                      % TODO - convert to char for call to textscan until
                      % string supported
                      rowArray = textscan(lineBlock{1}{row},formatSpec,'delimiter',...
                          this.Delimiters,'MultipleDelimsAsOne',this.MultipleDelimsAsOne, 'TextType', 'string');
                      
                      if ~this.ContainsQuotes
                          quoteIdx = strfind(strjoin(rowArray{1}), '"');
                          if ~isempty(quoteIdx) && mod(length(quoteIdx), 2) == 0
                              % The file contains quotes, so switch to using
                              % '%q' for calls to textscan.  Reread the current
                              % line using '%q'.  Note that textscan only
                              % supports double-quotes, so that's all we'll
                              % check for here as well.  Also note that the
                              % change to use %q will only happen if the lines
                              % contain an even number of quotes -- if not use
                              % %s as this will give better results.  If the
                              % file has a mix of even/odd number quotes, use %q
                              % and the odd number quote lines will be treated
                              % as invalid by the parsing later on.
                              this.ContainsQuotes = true;
                              this.TextscanTextFormat = 'q';
                              formatSpec = ['%' this.TextscanTextFormat];
                              rowArray = textscan(lineBlock{1}{row},formatSpec,'delimiter',...
                                  this.Delimiters,'MultipleDelimsAsOne',this.MultipleDelimsAsOne, 'TextType', 'string');
                          end
                      end
                   catch me
                      if strcmp('MATLAB:textscan:NotAString',me.identifier)
                         rowArray = textscan(lineBlock{1}{row},'%s','delimiter',...
                            this.Delimiters,'MultipleDelimsAsOne',this.MultipleDelimsAsOne, 'TextType', 'string');
                      end
                   end
                   numCols = length(rowArray{1});
                   if isempty(cacheData.RowData)
                       cacheData.RowData = rowArray{1}';
                   else
                       cacheData.RowData(row,1:numCols) = rowArray{1}';
                   end
                   if numCols>this.ColumnCount
                       this.ColumnCount = numCols;
                   end
                end    
            end
  
            
            % Add the new CachedData line block to the end in sorted
            % StartRow order
            if ~isempty(this.CacheData)     
                I = find([this.CacheData.StartRow]<cacheData.StartRow,1,'last');
                if ~isempty(I)
                    this.CacheData = [this.CacheData(1:I) cacheData this.CacheData(I+1:end)];
                    ind = I+1;
                else
                    this.CacheData = [cacheData this.CacheData];
                    ind = 1;
                end
            else
                ind = 1;
                this.CacheData = cacheData;
            end
            
        end
        
        function init(this)
            % Refresh the RowCount and other fixed file parameters (which 
            % do not depend on UI settings like delimiters and fixed width
            % positions)    
            frewind(this.FilePointer);

            % First read a few characters from the file to see if it contains
            % a Byte Order Mark (BOM).  If this exists, its an indication as to
            % the encoding of the file.
            this.FileEncoding = '';
            ch = fread(this.FilePointer, 10, '*uchar');
            [this.FileEncoding, this.EncodingBOMLength, this.FileEncodingForFOpen] = ...
                this.checkFileEncoding(ch);
            if isempty(this.FileEncodingForFOpen)
                frewind(this.FilePointer);
            else
                % Reopen the file with the encoding determined from the BOM.
                fclose(this.FilePointer);
                this.FilePointer = fopen(char(this.FileName), 'r', 'n', ...
                    this.FileEncodingForFOpen);
            end

            chunksize = 1e6; % read chunks of 1MB at a time
            byteCount = 0;
            
            numlfs = 0;
            numcrs = 0;
            numdupcrs = 0;
            numduplfs = 0;
            numcrlfs = 0;
            windowsLineBreaks = false;
            macLineBreaks = false;
            linuxLineBreaks = false;
            lastChar = ' ';
            while ~feof(this.FilePointer)
                ch = fread(this.FilePointer, chunksize, '*uchar');
                if isempty(ch)
                    break
                end
                
                unicodeCh = [];
                if this.IsCJK
                    unicodeCh = native2unicode(ch); %#ok<N2UNI>
                end
                
                if macLineBreaks
                    Icr = (ch == newline);
                    numcrs = numcrs + sum(Icr);
                elseif linuxLineBreaks
                    Ilf = (ch == sprintf('\r'));
                    numlfs = numlfs + sum(Ilf);
                elseif windowsLineBreaks
                    Icr = (ch == newline);
                    Ilf = (ch == sprintf('\r'));
                    numcrs = numcrs + sum(Icr);
                else
                    Icr = (ch == newline);
                    Ilf = (ch == sprintf('\r'));
                    numcrs = numcrs + sum(Icr);
                    numlfs = numlfs + sum(Ilf);
                end

                % Detect the presence of null characters so that they can
                % be replaced by spaces (as they are in the command
                % window). This prevents java interpreting null chars as
                % line breaks.
                if ~this.NullCharsExist && any(ch == 0)
                    this.NullCharsExist = true;
                end
                
                % Detect the presense of half-width characters
                % (0x0021 <= c && c <= 0x00FF) ||
                % (0xFF61 <= c && c <= 0xFFDC) ||
                % (0xFFE8 <= c && c <= 0xFFEE);
                if this.IsCJK && ~this.HalfWidthCharsExist && ...
                    any((21 <= unicodeCh & unicodeCh <= 255) | (65377 <= unicodeCh & unicodeCh <= 65500) | (65512 <= unicodeCh & unicodeCh <= 65518))
                    this.HalfWidthCharsExist = true;
                end

                % Detect the presense of full-width characters
                if this.IsCJK && ~this.FullWidthCharsExist && ...
                    any((255 < unicodeCh & unicodeCh < 65377) | (65500 < unicodeCh & unicodeCh < 65512) | (65518 < unicodeCh))
                    this.FullWidthCharsExist = true;
                end
                
                if ~windowsLineBreaks && ~linuxLineBreaks && ~macLineBreaks
                    if numcrs>=2 && numlfs==0
                        macLineBreaks = true;
                    elseif numcrs==0 && numlfs>=2
                        linuxLineBreaks = true;
                    elseif numcrs>=2
                        windowsLineBreaks = true;
                    end
                end
                   
                % If the platform type is undefined there can only have
                % been at most 1 lf or cr, so there are no
                % repetitions.
                if macLineBreaks 
                    numdupcrs = numdupcrs + sum(Icr(2:end) & Icr(1:end-1));
                    if lastChar==ch(end) && ch(1)==newline && lastChar==newline
                        numdupcrs = numdupcrs+1;
                    end
                elseif linuxLineBreaks
                    numduplfs = numduplfs + sum(Ilf(2:end) & Ilf(1:end-1));
                    if lastChar==ch(end) && ch(1)==sprintf('\r') && lastChar==sprintf('\r')
                        numduplfs = numduplfs+1;
                    end
                elseif windowsLineBreaks
                    numcrlfs = numcrlfs + sum(Ilf(2:end) & Icr(1:end-1));
                    if lastChar==newline && ch(1)==sprintf('\r')
                        numcrlfs = numcrlfs+1;
                    end
                end
                lastChar = ch(end);
                byteCount = byteCount+length(ch);
            end
            
            if macLineBreaks
                % If the last char is not a new line there is an additional row
                numlines = numcrs + (~Icr(end));
                emptylines = numdupcrs;
            elseif linuxLineBreaks
                % If the last char is not a lf there is an additional row
                numlines = numlfs + (~Ilf(end));
                emptylines = numduplfs;
            elseif windowsLineBreaks
                % If the last char is not a new line there is an additional row
                numlines = numcrs + (~Icr(end));
                emptylines = numcrlfs;
            else
                numlines = max(numcrs+(~Icr(end)),numlfs+(~Ilf(end)));
                emptylines = 0;
            end
            
            frewind(this.FilePointer);
            this.EmptyRowCount = emptylines;
            this.ByteCount = byteCount;
            this.RowCount = numlines-emptylines;
            this.ReadRows(1,this.RowBlockSize);
        end
        
        function initCache(this)
            if ~this.isInitialized
                this.init;
            end
            this.ReadRows(1,this.RowBlockSize);
        end
        
        function [data,nrows,ncols] = Read(this,startRow,endRow,startColumn,endColumn)
            if this.isCacheDirty
                this.initCache;
            end
            
            % Find the page numbers of the start and end row. Note that
            % since the difference between the startRow and endRow must be
            % less than this.RowBlockSize, the requested interval can span
            % at most 2 pages.
            page1 = floor((startRow-1)/this.RowBlockSize)+1;
            page2 = floor((endRow-1)/this.RowBlockSize)+1;
            if ~isempty(this.CacheData)                
                if page1==page2
                    % Find a CacheData block which is aligned to the first
                    % page. If there are none, create one.
                    ind = find([this.CacheData.StartRow]==(page1-1)*this.RowBlockSize+1,1,'first');
                    if isempty(ind)
                        ind = this.ReadRows((page1-1)*this.RowBlockSize+1,page1*this.RowBlockSize);
                    end
                else
                    % Find a CacheData blocks which are aligned to the
                    % pages. If either is not present, create it.
                    ind1 = find([this.CacheData.StartRow]==(page1-1)*this.RowBlockSize+1,1,'first');
                    if isempty(ind1)
                        ind1 = this.ReadRows((page1-1)*this.RowBlockSize+1,page1*this.RowBlockSize);
                    end                        
                    ind2 = find([this.CacheData.StartRow]==(page2-1)*this.RowBlockSize+1,1,'first');
                    if isempty(ind2)
                        ind2 = this.ReadRows((page2-1)*this.RowBlockSize+1,page2*this.RowBlockSize);
                    end  
                    ind = [ind1;ind2];
                end                    
            else
                % If there are no cached data blocks, create them for the 
                % required pages.
                if page1==page2
                    this.ReadRows((page1-1)*this.RowBlockSize+1,page1*this.RowBlockSize+1);
                    ind = 1;
                else
                    this.ReadRows((page1-1)*this.RowBlockSize+1,page1*this.RowBlockSize);
                    this.ReadRows((page2-1)*this.RowBlockSize+1,page2*this.RowBlockSize);
                    ind = [1;2];
                end
            end 
           
            % If the requested interval comprises 2 pages, combine them
            % into a single cacheData block.
            cacheDataBlock = this.CacheData(ind(1));
            if length(ind)==2                       
                % Note that this.CacheData and this.CacheData(ind(2))
                % may have different numbers of columns.
                nrows1 = size(cacheDataBlock.RowData,1);
                nrows2 = size(this.CacheData(ind(2)).RowData,1);
                ncols1 = size(cacheDataBlock.RowData,2);
                ncols2 = size(this.CacheData(ind(2)).RowData,2);
                
                combinedStr = string;
                combinedStr(1:nrows1,1:ncols1) = cacheDataBlock.RowData;
                combinedStr(nrows1+1:nrows1+nrows2,1:ncols2) = this.CacheData(ind(2)).RowData;
                
                cacheDataBlock.RowData = combinedStr;
                cacheDataBlock.EndRow = this.CacheData(ind(2)).EndRow;
            end 
                     
            % Subsref the specified data from the CacheData blocks
            if endRow+1>cacheDataBlock.EndRow+1
                if endColumn>size(cacheDataBlock.RowData,2)
                    data = cacheDataBlock.RowData(startRow-cacheDataBlock.StartRow+1:end,...
                     startColumn:end);
                else
                     data = cacheDataBlock.RowData(startRow-cacheDataBlock.StartRow+1:end,...
                         startColumn:endColumn);
                end
            else
               if endColumn>size(cacheDataBlock.RowData,2)
                   data = cacheDataBlock.RowData(startRow-cacheDataBlock.StartRow+1:endRow-cacheDataBlock.StartRow+1,...
                        startColumn:end);
               else
                   data = cacheDataBlock.RowData(startRow-cacheDataBlock.StartRow+1:endRow-cacheDataBlock.StartRow+1,...
                      startColumn:endColumn);
               end
            end
            nrows = size(data,1);
            ncols = size(data,2);
            
            % If there are more than 10 CachedData line blocks, remove the
            % furthest from the startRow
            if length(this.CacheData)>10
                [~,I] = max(abs([this.CacheData.StartRow]-startRow));
                this.CacheData(I(1)) = [];
            end
        end
        
        function [data, nrows, ncols] = ReadFromJava(this, startRow, endRow, startColumn, endColumn)
            [data, nrows, ncols] = this.Read(startRow, endRow, startColumn, endColumn);

            % For java, need to return cellstr
            data(ismissing(data)) = '';
            data = cellstr(data);
        end
            
        function delete(this)
            % Guard against an invalid file pointer when the destructor is
            % called
            if this.FilePointer > 2 && ~isempty(fopen(this.FilePointer))
                fclose(this.FilePointer);
            end
        end
        
        function setDelimiters(this,delimiters)
            if ~isequal(this.Delimiters,delimiters)
                if any(strcmp(delimiters,'\'))
                    delimiters = strrep(delimiters,'\','\\');
                end
                % Work around a bug in textscan where multiple delimiters
                % must be in descending length order
                if iscell(delimiters)
                    [~,I] = sort(-cellfun('prodofsize',delimiters));
                    delimiters = delimiters(I);
                end
                this.reset;
                this.Delimiters = delimiters;
            end
        end
        
        function delimiters = getDelimiters(this)
            delimiters = this.Delimiters;
            if any(strcmp(this.Delimiters,'\\'))
                delimiters = strrep(delimiters,'\\','\');
            end        
        end
        
		% Function to find text using Find Dialog
        function [absoluteSearchResultRowNum,absoluteSearchResultColumnNum] = find(this,word,matchCase,entireCell,wrapAround,searchOnlySelection,focusedRow,focusedCol,selRowsIntervalArray,selCols,direction)
            
             % INPUTS :
             % searchOnlySelection : boolean which indicates if the search
             % should be restricted to the selected areas only
         
             % focusedCol,focusedRow : the most recently found cell or the last anchor cell in the table. This is where the
             % search should be started
              
             % selRowsIntervalArray : denotes an array containing the row intervals which
             % have been selected.
             % Eg: selRowsIntervalArray(1) = first row of the first block of selection
             %     selRowsIntervalArray(2) = last row of the first block of selection and
             %     so on for subsequent blocks
             
             % selCols : denotes an array of all the selected columns in the
             % table, e.g. [1 2 5 6 7 ...]
             
             % direction : true for 'Find next', false for 'Find
             % previous'
            
            h = []; % handle to waitbar
            setProgressBar = false;
            
            % boolean to indicate the success or failure of search %
            searchSuccessful = false;
            searchFailed = false;
            
            % row and column with the found text. Initially they have a
            % value -1. If the search is successful, they are updated
            absoluteSearchResultRowNum = -1;
            absoluteSearchResultColumnNum = -1;
            
            % array containing all the rows as individual elements
            expandedRowArray = []; %#ok<NASGU>
            
            abortSearch = false;
            
            % boolean to indicate when the end of file or end of selection
            % is reached
            reachedEndOfSelection = false;
            
            next = 1;
            blockSize = this.block_size;
            
            % defining scope of search 
            [selectionMode, firstRowToBeSearched,lastRowToBeSearched,firstColumnToBeSearched,lastColumnToBeSearched] = localGetSearchScope(this.RowCount,this.ColumnCount,selRowsIntervalArray, selCols,searchOnlySelection);
             
            % Find previous case
            if ~direction
                [firstRowToBeSearched,lastRowToBeSearched] = localSwap(firstRowToBeSearched,lastRowToBeSearched);
                [firstColumnToBeSearched,lastColumnToBeSearched] = localSwap(firstColumnToBeSearched,lastColumnToBeSearched);
                next = -1;
                blockSize = -this.block_size;
            end
                
			% absoluteStartRow keeps track of the absolute starting row
            % number of each block brought in for scanning
            if selectionMode == 0
                if direction
                    absoluteStartRow = 1;
                else
                    absoluteStartRow = this.RowCount;
                end
            else
                absoluteStartRow = focusedRow;
            end

            % expand the selRowsIntervalArray array to include all the selected
            % rows as individual elements
            expandedRowArray = localGetExpandedRowArray(selRowsIntervalArray);
                       
            % set the starting point (row and column) of the search using
            % the raster pattern
            absoluteCurrentRowNum = focusedRow;
            if selectionMode == 0			%no cell selected
                if direction
                    absoluteCurrentColumnNum = 1;
                    absoluteCurrentRowNum = 1;
                else
                    absoluteCurrentColumnNum = this.ColumnCount;
                    absoluteCurrentRowNum = this.RowCount;
                end
            elseif (focusedCol == lastColumnToBeSearched && focusedRow == lastRowToBeSearched) 
                % focused cell is the last cell of the selection
                if wrapAround                       % if wrap Around is enabled, the start row is reset to the first row
                    absoluteStartRow = firstRowToBeSearched;
                    absoluteCurrentColumnNum = firstColumnToBeSearched;
                    absoluteCurrentRowNum = firstRowToBeSearched;
                else                                % else the variable reachedEndOfSelection is set to true 
                    reachedEndOfSelection = true;
                end
            elseif focusedCol == lastColumnToBeSearched
                % focused cell is the last cell of a selected row, then the row is incremented to the next one and the column is reset to the first column of the next row   
                absoluteCurrentColumnNum = firstColumnToBeSearched;
                absoluteCurrentRowNum = focusedRow + next;
            else
                absoluteCurrentColumnNum = focusedCol + next;
            end
            
            % looping within MATLAB. Blocks of fixed size are brought into
            % the memory, one at a time till the desired text is found
            while (absoluteSearchResultRowNum == -1 && absoluteSearchResultColumnNum == -1)
                
                % Defining the absolute row boundaries of the block to be brought in.It is represented by absoluteStartRow, absoluteEndRow 
                % Column boundaries are always represented by the variables, firstColumnToBeSearched
                % and the lastColumnToBeSearched. 
                %
                % when selection range extends beyond the current block size 
                if (direction && absoluteStartRow + blockSize <= lastRowToBeSearched) || (~direction && absoluteStartRow + blockSize >= lastRowToBeSearched)
                    absoluteEndRow = absoluteStartRow + blockSize - next;
                else
                    absoluteEndRow = lastRowToBeSearched;
                end
                
                % getting the relative row,column values for searching within a block 
                relativeCurrentRowNum = 1 + abs(absoluteCurrentRowNum - absoluteStartRow);
                relativeCurrentColumnNum = abs(absoluteCurrentColumnNum - firstColumnToBeSearched) + 1;
                
                % if it is search previous then the absoluteEndRow is
                % always less than the absoluteStartRow, hence we swap the
                % values here to maintain the same code in both cases
                if ~direction
                    [absoluteStartRow,absoluteEndRow] = localSwap(absoluteStartRow,absoluteEndRow);
                end
                
                % read the block using textscan
                if direction
                    data = this.Read(absoluteStartRow,absoluteEndRow,firstColumnToBeSearched,lastColumnToBeSearched);
                else
                    data = this.Read(absoluteStartRow,absoluteEndRow,lastColumnToBeSearched,firstColumnToBeSearched);
                end
               
                % set the number of rows(rowCount) and the number of columns (columnCount) to be searched
                rowCount = (absoluteEndRow - absoluteStartRow) + 1;
                columnCount = abs((lastColumnToBeSearched-firstColumnToBeSearched))+1;
                
                for row = relativeCurrentRowNum : rowCount
                    
                    % find previous
                    if ~direction
                        rowIterator = rowCount - row + 1;
                    % find next
                    else
                        rowIterator = row;
                    end
                    
                    % action when the search in progress is cancelled
                    if setProgressBar 
                        if getappdata(h,'cancelled')
                            abortSearch = true;
                            delete(h);
                            break;
                        end
                        
                        % Find next
                         if direction
                            percent = localCalculateNextPercent(this.RowCount,selectionMode, absoluteEndRow,focusedRow,lastRowToBeSearched,firstRowToBeSearched);
                        % Find previous
                        else
                            percent = localCalculatePrevPercent(this.RowCount,selectionMode,absoluteStartRow,focusedRow,lastRowToBeSearched,firstRowToBeSearched);
                        end
                        waitbar(percent,h,sprintf('%d%s',round(percent*100),'%'))
                    end

                    for column = relativeCurrentColumnNum : columnCount
                        
                        % find previous
                        if ~direction
                            colIterator = columnCount - column + 1;
                        % find next
                        else
                            colIterator = column;
                        end
                        
                        % If 'Wrap Around' is enabled and the desired text
                        % does not exist in the file, the search should be
                        % cancelled after one complete scan of the file. The
                        % boolean variable 'searchFailed' is given a value '1' to
                        % indicate this case.
                        if rowIterator + absoluteStartRow - 1 == focusedRow && ((direction && colIterator + firstColumnToBeSearched - 1  == focusedCol) ||... 
                             (~direction && colIterator + lastColumnToBeSearched - 1  == focusedCol)) &&... 
                            selectionMode ~= 0 
                            searchFailed = true;
                            break;
                        end 
                            
                        % if the desired text is found then set the
                        % absoluteSearchResultRowNum and
                        % absoluteSearchResultColumnNum variables with the
                        % cell value
                        if selectionMode == 2
                            % skip the cell if it is not selected
                            if ~(ismember(rowIterator + absoluteStartRow - 1,expandedRowArray) && ( (direction && ismember(colIterator + firstColumnToBeSearched - 1,selCols)) ||...
                                (~direction && ismember(colIterator + lastColumnToBeSearched - 1,selCols))))
                                continue;
                            end
                        end
                            
                        % check if the cell matches the desired text
                        if ~ismissing(data(rowIterator,colIterator))
                            if ( (~matchCase && contains(lower(data{rowIterator,colIterator}),lower(word)))) || (matchCase && ~isempty(strfind(data{rowIterator,colIterator},word)))
                                if ( (entireCell && (~matchCase && regexp(data{rowIterator,colIterator},strcat(word,'\s'))) || (matchCase && regexpi(data{rowIterator,colIterator},strcat(word,'\s')))) || ~entireCell)
                                    searchSuccessful = true;
                                    absoluteSearchResultRowNum = rowIterator + absoluteStartRow - 1;
                                    if direction
                                        absoluteSearchResultColumnNum = colIterator + firstColumnToBeSearched - 1;
                                    else
                                        absoluteSearchResultColumnNum = colIterator + lastColumnToBeSearched - 1;
                                    end
                                    break;
                                end
                            end
                        end
                        
                        % boolean variable 'searchSuccessful' is used to indicate the
                        % success or failure of a search. If it is a
                        % success, this value is '1' and the search is
                        % aborted
                        if searchSuccessful 
                            if setProgressBar == true
                                delete(h);
                                setProgressBar = false;
                            end
                            break;
                        end
                    end
                    
                    if searchSuccessful || searchFailed 
                        if setProgressBar == true
                            delete(h);
                            setProgressBar = false;
                        end
                        break;
                    end
                    
                    % A boolean 'reachedEndOfSelection' is used
                    % to indicate that the search reached the end of selection. If its true and 'Wrap Around'
                    % is enabled then the row and column values are reset to the beginning of the file
                    if ( (rowIterator + absoluteStartRow - 1 == lastRowToBeSearched) && ((selectionMode == 1 || selectionMode == 0 && colIterator  == lastColumnToBeSearched) ||...
                        (selectionMode == 2 && ((direction && colIterator + firstColumnToBeSearched - 1  == lastColumnToBeSearched) ||...
                        (~direction && colIterator + lastColumnToBeSearched - 1  == lastColumnToBeSearched)))))  
                         reachedEndOfSelection = true;
                    end
                    
                    % continue the search from the first column of the next
                    % row 
                    if column == columnCount
                        relativeCurrentColumnNum = 1;
                    end
                end
                
                % code to get the next block into the memory if the desired text was not
                % found in the previous block
                if ~searchSuccessful
                    
                    % case when the end of selection is reached in single
                    % block or multi block selection case and 'wrap around'
                    % is enabled, startRow is reset to the start of
                    % selection
                    if reachedEndOfSelection && wrapAround 
                        absoluteStartRow = firstRowToBeSearched;    
                    end
                    
                    % case when end of selection is reached and no cell is
                    % selected or wrap around is disabled
                    % OR search fails after one complete scan of the file
                    % OR search in progress is cancelled by the user, then
                    % progress bar is deleted and search is aborted
                    if (reachedEndOfSelection && (selectionMode == 0 || ~wrapAround )) || searchFailed || abortSearch 
                        if setProgressBar 
                            delete(h);
                        end
                        break;
                    end
                    
                    % if there are more blocks to be searched, start row is
                    % updated to the first row of the next block
                    if ~reachedEndOfSelection %&& absoluteStartRow < lastRowToBeSearched
                        if ~setProgressBar 
                            setProgressBar = true;
                            searchStr = getString(message('MATLAB:codetools:Searching'));
                            h = waitbar(0, searchStr, 'Name', searchStr, 'CreateCancelBtn', @localCreateCancelBtn);
                        end
                        if direction
                            absoluteStartRow = absoluteStartRow + blockSize;
                        else
                            absoluteStartRow = absoluteStartRow + next;
                        end
                    end
                    
                    % reset the absolute values of current row and column
                    % to be searched in the new block
                    absoluteCurrentRowNum = absoluteStartRow;
                    absoluteCurrentColumnNum = firstColumnToBeSearched;
                    reachedEndOfSelection = false;
                else
                    break;
                end
            end
        end
        function setFixedWidth(this,fixedWidthState)
            if ~isequal(this.FixedWidth,fixedWidthState)
                this.reset;
                this.FixedWidth = fixedWidthState;
            end
        end
        
        function setFixedWidthColumnPositions(this,fixedWidthColumnPositions)
            fixedWidthColumnPositions = sort(fixedWidthColumnPositions);
            if ~isequal(this.FixedWidthColumnPositions,fixedWidthColumnPositions)
                this.reset;
                this.FixedWidthColumnPositions = fixedWidthColumnPositions;
            end
        end

        function fixedWidthColumnPositions = getFixedWidthColumnPositions(this)
            fixedWidthColumnPositions = this.FixedWidthColumnPositions;
        end
        
        function state = isCacheDirty(this)
            % If there is no CacheData the ColumnCount and RowCount are 
            % not valid.
            state = isempty(this.CacheData);
        end
        
        function state = isInitialized(this)
            state = this.RowCount>0;
        end
        
        % Convert the FixedWidthColumnPositions to fixed width column
        % lengths for use generating format strings.
        function fixedWidthColumnLengths = getFixedWidthsForColumns(this)
             fixedWidthColumnLengths = diff([0 this.FixedWidthColumnPositions(:)']);
             % The last column has indeterminate length
             fixedWidthColumnLengths(end+1) = inf;
        end
        
        function [rules, dateParseRules, defaultNumericRule, defaultTimeRule] = findDefaultParseRules(this,maxCount)
            % Create an array of default parse rules for each column and a
            % matrix of dateParseRules where each column contains a list of
            % potential dateParseRules with the top value inferred from the
            % sample data.
            if this.isCacheDirty
                this.initCache;
            end
            
            % Read in a large amount of rows ('read' - but this is cached
            % by now).  But then only use the smaller amount of rows for
            % most processing. (And an even smaller amount for datetime,
            % because this is very intensive)
            fullRawData = this.Read(this.DefaultHeaderRow, this.SampleLinesForCategoricalDetection, 1, this.ColumnCount);
            numRows = min(size(fullRawData, 1), this.SampleLinesForParseRules);
            numRowsForDT = min(size(fullRawData, 1), this.SampleLines);
            numCols = min(size(fullRawData, 2), maxCount);
            rawData = fullRawData(1:numRows, 1:min(this.ColumnCount, numCols));
            
            % The number of currently parsed columns is different than the
            % maximum number of columns found in the file
            if numCols < min(this.ColumnCount, maxCount)
                numCols = min(this.ColumnCount, maxCount);
                while size(rawData,2)<numCols
                    rawData(end,end+1) = ''; %#ok<AGROW>
                    fullRawData(end, end+1) = ''; %#ok<AGROW>
                end
            end
            
            rules = cell(1,numCols);
            dateParseRules = cell(3,numCols);
            defaultNumericRule = com.mathworks.mlwidgets.importtool.NumericParsingRule;
            defaultNumericRule.setDecimalSeparator(this.DecimalSeparator);
            defaultTimeRule = com.mathworks.mlwidgets.importtool.TimeParsingRule;
            defaultTimeRule.setDecimalSeparator(this.DecimalSeparator);
            
            formatstr = internal.matlab.importtool.ImportUtils.getAllDateFormats;
            currentLocale = char(java.util.Locale.getDefault.toString);
            englishLocale = any(strfind(currentLocale, 'en') == 1);

            for col=1:numCols
                
                if iscell(rawData)
                    numNonEmptyRows = numRows - ...
                        (sum(cellfun(@isempty, rawData(:,col))));
                    numNonEmptyRowsForDT = numRowsForDT - ...
                        (sum(cellfun(@isempty, rawData(1:numRowsForDT,col))));
                else
                    numNonEmptyRows = numRows - ...
                        sum(rawData(:,col) == '' | ismissing(rawData(:,col)));
                    numNonEmptyRowsForDT = numRowsForDT - ...
                        sum(rawData(1:numRowsForDT,col) == '' | ismissing(rawData(1:numRowsForDT,col)));
                end
                
                % Construct a DateParsingRule if 50% of cells are the same
                % dateformat
                dateFormatIndices = zeros(numRowsForDT,1);
                for row=1:numRowsForDT
                    if ~ismissing(rawData(row,col)) && ~(strlength(rawData(row,col)) == 0)
                        cellValue = rawData(row,col);
                        [~,dateFormatIndices(row)] = ...
                            internal.matlab.importtool.ImportUtils.getDateFormatWithLocale(cellValue, formatstr, englishLocale);
                    end
                end
                
                allDateFormats = internal.matlab.importtool.ImportUtils.getAllDateFormats;
                if numNonEmptyRowsForDT > 0 && sum(dateFormatIndices>=1)>=numNonEmptyRowsForDT/2
                    dateFormatIndices = dateFormatIndices(dateFormatIndices>=1);
                    [defaultDateFormatIndex,modeCount] = mode(dateFormatIndices);
                    if modeCount>=numNonEmptyRowsForDT/2 
                        rules{col} = com.mathworks.mlwidgets.importtool.DateParsingRule(allDateFormats{defaultDateFormatIndex});
                        allDateFormats = allDateFormats([defaultDateFormatIndex 1:(defaultDateFormatIndex-1) defaultDateFormatIndex+1:end]);  
                    end
                end
                for k=1:length(allDateFormats)
                    dateParseRules{k,col} = com.mathworks.mlwidgets.importtool.DateParsingRule(allDateFormats{k});
                end
  
                if isempty(rules{col})
                    % Construct a NumericParsingRule if 50% of cells are
                    % numbers with common prefixes and suffixes
                    [Inumeric, prefixes, suffixes] = findNumbersLogical(rawData(:,col), this.DecimalSeparator);
                    isNumericCol = localIsNumericColData(numNonEmptyRows, Inumeric, prefixes, suffixes);
                    if (isNumericCol)
                        rules{col} = defaultNumericRule;
                    elseif any(Inumeric) && length(Inumeric) > 1
                        % There are some numbers, but still unsure if this
                        % column should be treated as numeric. Try again,
                        % but only with unique values.  This handles the
                        % case where there are some numbers, and a lot of a
                        % single text value.  Something like:
                        % 1,NA,NA,NA,NA,2,NA,NA,NA,3,NA,...
                        c = unique(rawData(:,col));
                        [Inumeric, prefixes, suffixes] = findNumbersLogical(c, this.DecimalSeparator);
                        isNumericCol = localIsNumericColData(length(c), Inumeric, prefixes, suffixes);
                        if (isNumericCol)
                            rules{col} = defaultNumericRule;
                        end
                    end
                end
            end

            % Note that size(rawData,2) may less than this.ColumnCount
            % if the number of columns increases beyond the sample
            % rows. Make sure the dateParseRules, rules reflect the full 
            % width
            extraColumnStartPos = min(size(rawData,2), maxCount);
            if extraColumnStartPos==0
                return
            end
            for col=extraColumnStartPos+1:numCols %this.ColumnCount
                dateParseRules(:,col) = dateParseRules(:,extraColumnStartPos);
                rules(1,col)= rules(1,extraColumnStartPos);
            end
            
            % Check text columns (up to maxCount) to see if they may be
            % categorical
            for col = 1:numCols
                if isempty(rules{col})
                    colData = fullRawData(:,col);
                    [~, ia, ~] = unique(colData);
                    if length(ia)/length(colData(colData ~= '')) < 0.7
                        rules{col} = com.mathworks.mlwidgets.importtool.CategoricalParsingRule;
                    end
                end
            end
        end

        % Create a format string for textscan for the specified columns
        function format = generateFormatString(this,cols,parseRules)          
            if this.FixedWidth
                if nargin>=3 % Fast path import will have the parseRules set
                    parsedColumns = ~cellfun('isempty',parseRules);
                else
                    % slow path import (read file in as strings and convert
                    % afterwards), 
                    parsedColumns = [];
                end
                
                % Create formats for skipping all strings, and then replace
                % this with the proper format for the columns which are
                % being imported.
                formats = repmat({'%*s'},cols(end)-cols(1)+1,1);
                for k=1:length(cols)
                    if ~isempty(parsedColumns) && parsedColumns(cols(k))
                        formats{cols(k)-cols(1)+1} = char(parseRules{cols(k)}.getTextscanFormat());
                    else
                        formats{cols(k)-cols(1)+1} = '%s'; % Text rule
                    end
                end
                
                % Create fixed width format string using FixedWidthColumnPositions 
                fixedWidthColumnLengths = this.getFixedWidthsForColumns;
                
                % Prepend format string with string skipping format %*Ns 
                % (where N is the column before the start column)  
                if cols(1)>1                                   
                    format = sprintf('%%*%ds%s',this.FixedWidthColumnPositions(cols(1)-1),...
                       localcreatefixedwidthformat(fixedWidthColumnLengths(cols(1):cols(end)),formats));
                else
                    format = localcreatefixedwidthformat(fixedWidthColumnLengths(cols(1):cols(end)),formats);
                end
            elseif nargin>=3 % Numeric format, non-fixed width  
                % Create format string
                format = repmat(['%*' this.TextscanTextFormat],[1,cols(1)-1]);
                
                parsedColumns = ~cellfun('isempty',parseRules);
                I = false(cols(end)-cols(1)+1,1);
                I(cols) = true;
                for col=cols(1):cols(end)
                    if I(col)
                         if parsedColumns(col)
                             format = sprintf('%s%s',format,char(parseRules{col}.getTextscanFormat()));
                         else
                             format = sprintf(['%s%%' this.TextscanTextFormat],format);
                         end
                    else
                        format = sprintf(['%s%%*' this.TextscanTextFormat],format);
                    end 
                end  
                for col=cols(end)+1:this.ColumnCount
                    format = sprintf('%s%%*s',format);
                end
                format = sprintf('%s%%[^\\n\\r]',format);
            else % String format, non-fixed width
                if length(cols)==cols(end)-cols(1)+1
                    format = [repmat(['%*' this.TextscanTextFormat],[1,cols(1)-1]) repmat(['%' this.TextscanTextFormat],[1,cols(end)-cols(1)+1]) '%[^\n\r]'];
                else
                    format = sprintf(['%s%%' this.TextscanTextFormat], ...
                        repmat(['%*' this.TextscanTextFormat], [1,cols(1)-1]));
                    for k=2:length(cols)
                        if cols(k)-cols(k-1)==1
                            format = sprintf('%s%%%s', format, this.TextscanTextFormat);
                        else
                            format = sprintf(['%s%s%%' this.TextscanTextFormat], format, ...
                                repmat(['%*' this.TextscanTextFormat], [1,cols(k)-cols(k-1)-1])); 
                        end 
                    end
                    format = sprintf('%s%%[^\\n\\r]',format);
                end
            end
        end
      
        % Test a contiguous block of rows to determine if it can be imported 
        % using fast-path code.  This method is used by code generation to 
        % simplify code
        function state = UseFastPathDataBlock(this,rows,cols,parseRules,emptyReplacementNumber)
            % Move the file position to the start row
            frewind(this.FilePointer);
            this.blockShift(0,rows(1)-1);            
 
            try
                dataArray = this.fastPathScan(rows,cols,parseRules,emptyReplacementNumber);
                localFastPathParseNonNumericColumns(dataArray,cols,parseRules,emptyReplacementNumber,[],[],this.FixedWidth,this.getDecimalSeparator);
                sizes = cellfun(@length, dataArray, 'UniformOutput', false);
                state = isequal(sizes{:});
            catch me %#ok<NASGU>
                state = false;
            end
        end
        
        % Test the selected range to determine if it can be imported using fast-path code. 
        % This method is used by code generation to simplify code        
        function state = UseFastPath(this,range,parseRules,rules)
           
            % If there is a single WorksheetReplacementRule, extract the 
            % replacement number so that it can be used directly in
            % textscan to optimize fast path execution.
            emptyReplacementNumber = double(com.mathworks.mlwidgets.importtool.WorksheetReplacementRule.getSingleReplacementValueFromRules(rules));
            
            state = false;
            [rows,cols] = internal.matlab.importtool.AbstractSpreadsheet.excelRangeToMatlab(range{1}{1});
            blockstate  = this.UseFastPathDataBlock(rows,cols,parseRules,emptyReplacementNumber);
            if ~blockstate
                return;
            end
            for colBlock = 2:length(range{1})
                [rows,cols] = internal.matlab.importtool.AbstractSpreadsheet.excelRangeToMatlab(range{1}{colBlock});
                blockstate  = this.UseFastPathDataBlock(rows,cols,parseRules,emptyReplacementNumber);
                if ~blockstate
                    return;
                end
                
                for rowBlock = 2:length(range)
                    [rows,cols] = internal.matlab.importtool.AbstractSpreadsheet.excelRangeToMatlab(range{rowBlock}{1});
                    blockstate  = this.UseFastPathDataBlock(rows,cols,parseRules,emptyReplacementNumber);
                    if ~blockstate
                        return;
                    end
                end
            end
            state = true;
        end
        
        function [data, dates, raw] = ImportDataBlock(this,rows,cols,parseRules,emptyReplacementNumber,progressInterval,wb)
                      
            % Move the file position to the start row
            frewind(this.FilePointer);
            this.blockShift(0,rows(1)-1);  
            
            % Show waitbar at the initial position for this block with the
            % text 'Scanning File.'
            if localUpdateWaitBar(wb,progressInterval(1),...
                    getString(message('MATLAB:codetools:TextFileScanningFile')))  
                error(message('MATLAB:codetools:TextImportWaitBarCancel'));
            end
            
            if length(rows) > this.RowBlockSize
                % Import may not have scanned all of the rows already, so
                % be safe and use '%q' for text, in case any quoted strings
                % appear in content that hasn't been scanned yet.
                this.ContainsQuotes = true;
                this.TextscanTextFormat = 'q';
            end
            
            % Create a cell array of numeric vectors (dataArray) with NaNs
            % in un-parsable positions and a cell array of cell arrays of raw
            % data (rawArray) with the actual raw data in un-parsable positions 
            % and the parsed data in parsable positions.
            try % Fast path processing
                
                dataArray = this.fastPathScan(rows,cols,parseRules,emptyReplacementNumber);
                
                % Show waitbar at the initial position for this block with the
                % text 'Scanned File.'
                if localUpdateWaitBar(wb,progressInterval(1),...
                        getString(message('MATLAB:codetools:TextFileScannedFile')))  
                   error(message('MATLAB:codetools:TextImportWaitBarCancel'));
                end
                
                % Use the parseRules to parse any columns that are not
                % numeric vectors. This is essentially date strings that
                % were read as strings and need to be converted with the
                % datenum function.
                [dataArray,rawArray] = localFastPathParseNonNumericColumns(dataArray,cols,parseRules,emptyReplacementNumber,progressInterval,wb,this.FixedWidth,this.getDecimalSeparator);
                
                if localUpdateWaitBar(wb,progressInterval(2),...
                        getString(message('MATLAB:codetools:TextFileParsedData')))
                   error(message('MATLAB:codetools:TextImportWaitBarCancel'));
                end
            catch me 
                % Slow path processing.  All of the textscan:AllNat* and
                % textscan:UnableToGuessFormat are datetime related errors
                if strcmp(me.identifier,'MATLAB:textscan:handleErrorAndShowInfo') || ...
                      strcmp(me.identifier,'MATLAB:codetools:TextImportFastPathError') || ...
                      strcmp(me.identifier,'MATLAB:UnableToConvert') || ...
                      strcmp(me.identifier,'MATLAB:textscan:AllNatSuggestLocale') || ... 
                      strcmp(me.identifier,'MATLAB:textscan:AllNatSuggestFormat') || ...
                      strcmp(me.identifier,'MATLAB:textscan:AllNatSuggestOther') || ...
                      strcmp(me.identifier,'MATLAB:textscan:UnableToGuessFormat')
                  
                    % Read everything in as strings and parse each column
                    % of strings using the parseRules.
                    
                    % Move the file position to the start row
                    frewind(this.FilePointer);
                    blockShift(this,0,rows(1)-1); 
                    
                    slowPathFormat = this.generateFormatString(cols);
                    if this.FixedWidth 
                        dataArray = textscan(this.FilePointer,slowPathFormat,rows(end)-rows(1)+1,'delimiter',...
                          '','WhiteSpace','', 'TextType', 'string'); 
                    else
                        dataArray = textscan(this.FilePointer,slowPathFormat,rows(end)-rows(1)+1,'delimiter',...
                          this.Delimiters,'MultipleDelimsAsOne', ...
                          this.MultipleDelimsAsOne, 'TextType', 'string'); 
                    end
                    rawArray = dataArray;
                    
                    % Show waitbar at the initial position for this block with the
                    % text 'Scanned File.'
                    if localUpdateWaitBar(wb,progressInterval(1),...
                            getString(message('MATLAB:codetools:TextFileScannedFile')))  
                       error(message('MATLAB:codetools:TextImportWaitBarCancel'));
                    end
                    
                    for col=cols(1):cols(end)                       
                        progress1 = (col-cols(1))/(cols(end)-cols(1)+1);
                        progress2 = (col-cols(1)+1)/(cols(end)-cols(1)+1);
                        if ~isempty(parseRules{col})
                            [dataArray,rawArray] = localParseColumn(dataArray,...
                                rawArray,parseRules,col,cols,...
                                   [progressInterval(2)*progress1+progressInterval(1)*(1-progress1),...
                                   progressInterval(2)*progress2+progressInterval(1)*(1-progress2)],...
                                   wb,this.getDecimalSeparator);
                        else
                            if this.FixedWidth
                                rawArray{col-cols(1)+1} = strtrim(dataArray{col-cols(1)+1});
                            else
                                rawArray{col-cols(1)+1} = dataArray{col-cols(1)+1};
                            end
                            dataArray{col-cols(1)+1} = NaN(size(rawArray{col-cols(1)+1}));
                        end
                                               
                        
                        % Show waitbar at a pro-rated position for this block with the
                        % text 'Parsing Data *%.'
                        progress = progressInterval(2)*progress2+progressInterval(1)*(1-progress2);
                        if localUpdateWaitBar(wb,progress,...
                                getString(message('MATLAB:codetools:TextFileParsingData',sprintf('%2.0f%%',100*progress))))
                            error(message('MATLAB:codetools:TextImportWaitBarCancel'));
                        end
                    end

                    % Show waitbar at the end position for this block with the
                    % text 'Data Parsed.'
                    if localUpdateWaitBar(wb,progressInterval(2),...
                            getString(message('MATLAB:codetools:TextFileParsedData')))                     
                        error(message('MATLAB:codetools:TextImportWaitBarCancel'));
                    end
                else
                    rethrow(me); % Pass MATLAB:codetools:TextImportWaitBarCancel errors back to the caller
                end
            end
            
            % Remove trailing cells due to %[^\n\r]
            dataArray = dataArray(1:cols(end)-cols(1)+1);
            rawArray = rawArray(1:cols(end)-cols(1)+1);
            
            % The last line may not end in a newline, with the result that
            % trailing columns of dataArray may be short, since
            % intermediate '%s' formats are not read. Pad them with empty
            % in this case, NaN for numeric and '' for cell array.
            arrayLengths = cellfun(@(x) size(x,1), dataArray);
            shortArrays = find(arrayLengths~=rows(end)-rows(1)+1);
            lastRow = rows(end)-rows(1)+1;
            for k=1:length(shortArrays)
                idx = shortArrays(k);
                indicesToFillIn = length(dataArray{idx})+1:lastRow;
                if isdatetime(dataArray{idx})
                    dataArray{idx}(indicesToFillIn) = NaT;
                elseif iscategorical(dataArray{idx})
                    dataArray{idx}(indicesToFillIn) = '<undefined>';
                else
                    dataArray{idx}(indicesToFillIn) = NaN;
                end
                
                rawIndicesToFillIn = length(rawArray{idx})+1:lastRow;
                if iscategorical(rawArray{idx})
                    rawArray{idx}(rawIndicesToFillIn) = '<undefined>';
                else
                    if length(rawArray{idx}) == 1
                        % Need to transpose result to create a column
                        % vector
                        [rawArray{idx}{rawIndicesToFillIn}] = deal('');
                        rawArray{idx} = (rawArray{idx})';
                    else
                        [rawArray{idx}{rawIndicesToFillIn}] = deal('');
                    end
                end
            end
                                
            % Create a numeric matrix (data) with NaNs in non-numeric
            % positions and a cell array (raw) with all data, and a dates 
            % array with the datetimes.
            raw = cell(length(dataArray{1}),length(dataArray));
            data = NaN(length(dataArray{1}),length(dataArray));
            dates = cell(1,length(dataArray));
            for col=1:length(dataArray)
                if isa(dataArray{col}, 'datetime')
                    dates{col} = dataArray{col};
                else
                    data(:,col) = dataArray{col};
                end
                
                % special case for string
                if isstring(rawArray{col}) || isdatetime(rawArray{col}) || iscategorical(rawArray{col})
                    raw{1,col} = rawArray{col};
                else
                    raw(:,col) = rawArray{col};
                end
            end
        end
           
       function [varNames,varSizes] = ImportData(obj, varNames, columnVarNames, allocationFcn,...
               range, numCells, parseRules, rules, columnTargetTypes)
            import com.mathworks.mlwidgets.importtool.*;
            
            % If there is a single WorksheetReplacementRule, extract the 
            % replacement number so that it can be used directly in
            % textscan to optimize fast path execution.
            emptyReplacementNumber = double(com.mathworks.mlwidgets.importtool.WorksheetReplacementRule.getSingleReplacementValueFromRules(rules));
            
            % Show the waitbar when importing more than 1e4 cells
            if numCells>1e4                    
                wb = waitbar(0,'','Name',getString(message('MATLAB:codetools:ImportingData')),...
                    'CreateCancelBtn',@localCreateCancelBtn,'interruptible','on','WindowStyle','modal');
            else
                wb = [];
            end

            columnTargetTypes = [columnTargetTypes{1}{:}]; %Column selection is the same for all row selections

            try
                % Loop through each contiguous block in the range 
                % cell array building up the combined arrays "data" and "raw"
                [rows,cols] = internal.matlab.importtool.AbstractSpreadsheet.excelRangeToMatlab(range{1}{1});
                progressInterval = [0 (1+rows(end)-rows(1))*(cols(end)-cols(1)+1)/numCells];
                [blockData, blockDates, blockRaw]  = ImportDataBlock(obj,rows,cols,parseRules,...
                    emptyReplacementNumber,progressInterval,wb);
                blockParseRules = parseRules(cols);

                % Accumulate blocks column-wise
                for colBlock = 2:length(range{1})
                     [rows,cols] = internal.matlab.importtool.AbstractSpreadsheet.excelRangeToMatlab(range{1}{colBlock});
                     progressInterval = progressInterval(2)+[0 (1+rows(end)-rows(1))*(cols(end)-cols(1)+1)/numCells];
                     [blockData_, blockDates_, blockRaw_] = ImportDataBlock(obj,rows,cols,parseRules,...
                         emptyReplacementNumber,progressInterval,wb);
                     blockParseRules_ = parseRules(cols);
                     blockData = [blockData blockData_]; %#ok<AGROW>
                     blockRaw = [blockRaw blockRaw_]; %#ok<AGROW>
                     blockDates = [blockDates blockDates_]; %#ok<AGROW>
                     blockParseRules = [blockParseRules blockParseRules_]; %#ok<AGROW>
                end
                data = blockData;
                raw = blockRaw;  
                dates = blockDates;

                % Accumulate blocks row-wise
                for rowBlock = 2:length(range)
                    [rows,cols] = internal.matlab.importtool.AbstractSpreadsheet.excelRangeToMatlab(range{rowBlock}{1});
                    progressInterval = progressInterval(2)+[0 (1+rows(end)-rows(1))*(cols(end)-cols(1)+1)/numCells];
                    [blockData, blockDates, blockRaw]  = ImportDataBlock(obj,rows,cols,parseRules,emptyReplacementNumber,progressInterval,wb);
                    for colBlock = 2:length(range{1})
                         [rows,cols] = internal.matlab.importtool.AbstractSpreadsheet.excelRangeToMatlab(range{rowBlock}{colBlock});
                         progressInterval = progressInterval(2)+[0 (1+rows(end)-rows(1))*(cols(end)-cols(1)+1)/numCells];
                         [blockData_,blockDates_,blockRaw_]  = ImportDataBlock(obj,rows,cols,parseRules,...
                             emptyReplacementNumber,progressInterval,wb);
                         blockData = [blockData blockData_]; %#ok<AGROW>
                         blockRaw = [blockRaw blockRaw_]; %#ok<AGROW>
                         blockDates = [blockDates blockDates_]; %#ok<AGROW>
                    end
                    data = [data;blockData]; %#ok<AGROW>
                    raw = [raw;blockRaw]; %#ok<AGROW>
                    
                    % combine the dates array so that the datetimes are
                    % together in a single datetime array
                    dates = cellfun(@(x,y) [x; y], dates, blockDates, 'UniformOutput', false);
                end

                % Clip the parseRules to the column in the imported data for
                % later sub-reference.
                parseRules = blockParseRules;

                % combine strings into a single string array
                strOrCatColIndices = cellfun(@(x) isempty(x) || isa(x, 'com.mathworks.mlwidgets.importtool.CategoricalParsingRule'), parseRules);
                
                if any(strOrCatColIndices) %&& ~allEmpty
                    cols = find(strOrCatColIndices);
                    for n = cols %1:length(cols)
                        empties = cellfun('isempty', raw(:, n));
                        raw{1, n} = vertcat(raw{~empties, n});
                        raw(2:end, n) = {[]};
                    end
                end
                
                nanDates = false(size(dates));
                for idx=1:length(dates)
                    if ~isempty(dates{idx})
                        if any(isnat(dates{idx}))
                            nanDates(idx) = true;
                        end
                    end
                end

                if any(any(isnan(data)) | nanDates)
                    numericallyTargetedColumnsIndex = find(...
                        ~cellfun(@(x) isempty(x) || isa(x, 'com.mathworks.mlwidgets.importtool.CategoricalParsingRule'), parseRules));
                    
                    if length(varNames)>1 % Column vector import
                        numericallyTargetedVarNames = varNames(:,numericallyTargetedColumnsIndex);
                    else % Matrix and cell array import
                        numericallyTargetedVarNames = varNames;
                    end
                    % Need to pass date information in as well
                    [ruleProcessedRaw,~,excludedRows,excludedColumns] = ...
                        internal.matlab.importtool.AbstractSpreadsheet.applyRules(rules,...
                        raw(:,numericallyTargetedColumnsIndex), ...
                        data(:,numericallyTargetedColumnsIndex),...
                        dates(:,numericallyTargetedColumnsIndex),...
                        numericallyTargetedVarNames);
                    
                    % Remove excluded rows and columns
                    columnTargetTypes(numericallyTargetedColumnsIndex(excludedColumns)) = [];
                    if ~isempty(columnVarNames)
                        % won't be set for numeric matrix or cell array
                        columnVarNames(numericallyTargetedColumnsIndex(excludedColumns)) = [];
                    end
                    
                    % Process the excludedRows on the string/categorical arrays as well
                    %strOrCatColIndices = (cellfun(@(x) isstring(x) || iscategorical(x), {raw{1,:}}))';
                    if any(excludedRows)
                        if any(strOrCatColIndices)
                            cols = find(strOrCatColIndices);
                            for n = cols
                                raw{1,n}(excludedRows) = [];
                            end
                        end
                        
                        % Need to process row exclusions such that the
                        % excluded rows are essentially removed
                        tmpRaw = raw(:, ~strOrCatColIndices);
                        % process the excluded rows
                        tmpRaw(excludedRows,:) = [];
                        sz = size(tmpRaw, 1);
                        
                        % grow the cell array with empties for the
                        % assignment, and assign back to raw
                        tmpRaw{size(raw,1), 1} = [];
                        raw(:, ~strOrCatColIndices) = tmpRaw;
                        
                        % now remove the empty rows entirely
                        raw(sz+1:end, :) = [];
                    end
                    
                    % Check on this functionality:
                    raw(:,numericallyTargetedColumnsIndex(~excludedColumns)) = ruleProcessedRaw;
                    
                    raw(:,numericallyTargetedColumnsIndex(excludedColumns)) = []; 
                    data(excludedRows,:) = [];
                    data(:,numericallyTargetedColumnsIndex(excludedColumns)) = [];  
                    if length(varNames)>1 % Column vector import
                         varNames(:,numericallyTargetedColumnsIndex(excludedColumns)) = [];
                    end
                    
                    % process excluded rows/columns for dates
                    for i=1:length(dates)
                        if ~isempty(dates{i})
                            dates{i}(excludedRows,:) = [];
                        end
                    end
                    dates(numericallyTargetedColumnsIndex(excludedColumns)) = [];

                end

                % Allocate the data to variables of the requested type
                if ischar(allocationFcn)
                    allocationFcn = str2func(allocationFcn);
                end
                outputVars = feval(allocationFcn, raw, dates, data, ...
                    columnTargetTypes, columnVarNames);

                %Assign the imported data to workspace variables
                varSizes = cell(length(varNames),1);
                for k=1:length(varNames)
                    assignin(obj.DstWorkspace,varNames{k},outputVars{k});
                    varSizes{k,1} = size(outputVars{k});
                end
                
            catch me
                % In case of any errors, close the progress dialog
                delete(wb);

                % User hit waitbar cancel
                if strcmp(me.identifier,'MATLAB:codetools:TextImportWaitBarCancel')
                    varNames = {};
                    varSizes = {};
                    return
                else
                    internal.matlab.importtool.AbstractSpreadsheet.manageImportErrors(me)
                end
            end
            
            delete(wb);
        end
    end
    
    methods (Access=private)
        function sampleData = getSampleData(this)
            if ~isempty(this.SampleData)
                sampleData = this.SampleData;
                return
            end
            if this.isCacheDirty
                this.initCache;
            end
            frewind(this.FilePointer);
            testBlock = textscan(this.FilePointer,'%1000s',this.SampleLines, ...
                'Delimiter','','WhiteSpace','', 'TextType', 'string');
            sampleData = [];
            if ~isempty(testBlock)
               sampleData = testBlock{1};
            end
            this.SampleData = sampleData;
        end
        
        function reset(this)
            this.ColumnCount = 1;
            this.CacheData = [];
        end
        
        % Call textscan using the fast path syntax using the format defined
        % by the specified columns
        function dataArray = fastPathScan(this,rows,cols,parseRules,emptyReplacementNumber)

            % If the post-processing rules do not comprise a single
            % numeric replacement rule (i.e., emptyReplacementNumber is
            % empty), just specify NaN as the default textscan value
            % for the 'EmptyValue' name
            if isempty(emptyReplacementNumber)
                emptyReplacementNumber = NaN;
            end
            
            % Create format string
            format = this.generateFormatString(cols, parseRules);
            
            if this.FixedWidth
                dataArray = textscan(this.FilePointer,format,rows(end)-rows(1)+1,'delimiter',...
                    '','WhiteSpace','','ReturnOnError',false,...
                    'EmptyValue',emptyReplacementNumber, 'TextType', 'string');
                
                % Detect if the numeric formatted textscan is out of
                % alignment with the column boundary. The result can be
                % that multiple numbers are read from the same fixed width
                % column or data is misallocated after a column containing
                % blank. There are 2 criteria for detection:
                %
                % 1. If the strings collected by the end of line element
                % '%[^\n\r]' have different lengths in the string and
                % numeric call to textscan on any line, then the numeric
                % textscan may have skipped characters.
                % 2. If there are any NaNs in the numeric data due to
                % either numeric fields having been skipped or unpopulated
                % numeric columns
                if ~all(cellfun('isempty',parseRules(cols)))
                    frewind(this.FilePointer);
                    this.blockShift(0,rows(1)-1);  
                    allStringFormat = this.generateFormatString(cols,repmat({[]},1,length(parseRules)));
                    textArray = textscan(this.FilePointer,allStringFormat,rows(end)-rows(1)+1,'delimiter',...
                        '','WhiteSpace','','ReturnOnError',false,...
                        'EmptyValue',emptyReplacementNumber, 'TextType', 'string');
                    if ~isequal(length(dataArray{end}), length(textArray{end})) || ...
                            any(cellfun(@(x) isnumeric(x) && any(isnan(x)), dataArray))
                        error(message('MATLAB:codetools:TextImportFastPathError'));
                    end
                end                                
            else
                dataArray = textscan(this.FilePointer,format,rows(end)-rows(1)+1,'delimiter',...
                    this.Delimiters,'WhiteSpace','','MultipleDelimsAsOne', ...
                    this.MultipleDelimsAsOne,'ReturnOnError',false,...
                    'EmptyValue',emptyReplacementNumber, 'TextType', 'string');
                
                % The strings collected by the end of line element '%[^\n\r]'
                % should be empty. If this is not the case, a string which
                % begins with a number (e.g. '12x') was parsed as a number
                % and the following characters (e.g. 'x') were carried over 
                % into the next string.  For example, when a file comprising a
                % single line '1 2x A' is read using the format
                % '%*s%f%*s%[^\n\r]', the string '2x' is read as the number 2
                % which is invalid.
                %if ~all(cellfun('isempty', strtrim(dataArray{end})))
                if ~all(strtrim(dataArray{end}) == '')
                    error(message('MATLAB:codetools:TextImportFastPathError'));
                end
                
                % All the dataArray elements except the last should be the
                % same length, or a missing newline character has 
                columnLengths = cellfun(@(x) length(x),dataArray(1:end-1));
                if ~all(columnLengths==columnLengths(1))
                    error(message('MATLAB:codetools:TextImportFastPathError'));
                end
            end
        end
        
        
    end
        
    methods (Static)
        % parseStringFcn applyFcn. WorksheetRule of RuleType
        % CONVERT must return a double array (replaceArray)
        % containing converted content and a boolean array (replaceIndexes)
        % identifying the location of converted content. Both these arrays
        % must be the same size as the data input. replaceArray may also
        % contain non-replaced content, which will be ignored.
        function [convertArray,convertIndexes] = parseStringFcn(rule,~,rawData)
            numArray = NaN(size(rawData));
            if iscell(rawData)
                convertIndexes = cellfun('isclass',rawData,'char');
                empties = cellfun('isempty', rawData);
                rawData(empties) = {''};
                rawData = string(rawData);
            else
                convertIndexes = true(size(rawData));
            end
            ind = find(convertIndexes);
            for k=1:length(ind)
                try
                    parsedNumber = findNumbers(rawData(ind(k)),char(rule.getDecimalSeparator()));
                catch me %#ok<NASGU>
                    parsedNumber = [];
                end
                if isscalar(parsedNumber)
                    numArray(ind(k)) = parsedNumber;
                end
            end
            convertIndexes = ~isnan(numArray);
            convertArray(convertIndexes) = numArray(convertIndexes);
            convertArray = convertArray(:);
        end
        
        % parseDateFcn applyFcn.
        function [convertArray,convertIndexes] = parseDateFcn(h,~,rawData)
            dateFormat =  char(h.getFormat);
            numArray = NaN(size(rawData));
           
            if iscell(rawData)
                convertIndexes = cellfun('isclass',rawData,'char');
            else
                convertIndexes = true(size(rawData));
            end
            ind = find(convertIndexes);
            for k=1:length(ind)             
                try
                    parsedNumber = datenum(rawData{ind(k)},dateFormat);
                catch me %#ok<NASGU>
                    parsedNumber = [];
                end
                if isscalar(parsedNumber)
                    numArray(ind(k)) = parsedNumber;
                end
            end
            convertIndexes = ~isnan(numArray);
            convertArray(convertIndexes) = numArray(convertIndexes);
            convertArray = convertArray(:);
        end
        
        function [datetimeArray, success] = convertToDatetime(rawData, dateFormat, locale)
            try
                % Try converting the text all at once.
                if isempty(locale)
                    datetimeArray = datetime(rawData(:), 'Format', dateFormat, ...
                        'InputFormat', dateFormat);
                else
                    datetimeArray = datetime(rawData(:), 'Format', dateFormat, ...
                        'InputFormat', dateFormat, 'locale', locale);
                end
                success = true;
            catch
                success = false;
                datetimeArray = [];
            end
        end
        
        % Parses the rawData cell array as a column of datetimes.  Format
        % is set in the UI. convertArray is an array of datetime.
        function [convertArray, convertIndexes] = parseDatetimeFcn(h, ~, rawData)
            dateFormat =  char(h.getFormat);
            
            if ~isa(rawData, 'datetime')
                try
                    [datetimeArray, success] = internal.matlab.importtool.TextFileImporter.convertToDatetime(rawData, dateFormat, []);
                    
                    if ~success
                        currentLocale = char(java.util.Locale.getDefault.toString);
                        englishLocale = any(strfind(currentLocale, 'en') == 1);
                        if ~englishLocale
                            % Try the conversion to datetime again, this time
                            % with English locale
                            [datetimeArray, success] = internal.matlab.importtool.TextFileImporter.convertToDatetime(rawData, dateFormat, currentLocale);
                            if success
                                h.setDatetimeLocale(currentLocale);
                            else
                                [datetimeArray, success] = internal.matlab.importtool.TextFileImporter.convertToDatetime(rawData, dateFormat, 'en_US');
                                if success
                                    h.setDatetimeLocale('en_US');
                                end
                            end
                        end
                    end
                    
                    if ~success
                        % textscan automatically removes quotes during
                        % conversion, so check if one of the dates has quotes
                        % around it, and if it does, remove them and try to
                        % convert to datetime again to match textscan behavior.
                        sampleAmount = min(20, length(rawData));
                        quotes = strfind(rawData(1:sampleAmount), '"');
                        quotes = cell2mat(reshape(quotes, sampleAmount, 1));
                        if ~isempty(quotes) ...
                                && size(quotes, 1) == sampleAmount ...
                                && size(quotes, 2) == 2 ...
                                && any(quotes(:,1)) == 1
                            rawData = cellfun(@(x) x(2:end-1), rawData, 'UniformOutput', false);
                            [datetimeArray, success] = internal.matlab.importtool.TextFileImporter.convertToDatetime(rawData, dateFormat, []);
                            if ~success && ~englishLocale
                                % Try the conversion to datetime again, this time
                                % with English locale
                                [datetimeArray, success] = internal.matlab.importtool.TextFileImporter.convertToDatetime(rawData, dateFormat, currentLocale);
                                if success
                                    h.setDatetimeLocale(currentLocale);
                                else
                                    [datetimeArray, success] = internal.matlab.importtool.TextFileImporter.convertToDatetime(rawData, dateFormat, 'en_US');
                                    if success
                                        h.setDatetimeLocale('en_US');
                                    end
                                end
                            end
                        end
                    end
                    
                catch
                    success = false;
                end
                
                if ~success
                    datetimeArray = repmat(datetime([NaN, NaN, NaN]), ...
                        size(rawData));
                end
            else
                datetimeArray = rawData;
            end
            datetimeArray.Format = dateFormat;
            
            convertArray = datetimeArray;
            if isdatetime(datetimeArray)
                convertIndexes = ~isnat(datetimeArray);
            else
                % Handle the error condition
                convertIndexes = false(size(rawData(:)));
            end
        end
        
        % Parses the rawData cell array as a column of datetimes.  Format
        % is set in the UI. convertArray is an array of strings of the
        % datetimes.
        function [convertArray, convertIndexes] = parseDatetimeFcnStrings(h, ~, rawData)
            % Replace any empty values with empty strings so the datetime
            % constructor can handle it
            [rawData{cellfun(@isempty, rawData)}] = deal('');
            
            [datetimeArray, convertIndexes] = internal.matlab.importtool.TextFileImporter.parseDatetimeFcn(h, [], rawData);
        
            % Convert resulting datetimes to strings and place in cell array
            convertArray = cell(1, length(convertIndexes));
            if isdatetime(datetimeArray)
                convertArray(convertIndexes) = cellstr(datetimeArray(convertIndexes));
                convertArray = convertArray(:);
            end
        end

        % rawData may be a categorical (for fast path import), or a string
        % array (for slow path).
        function [convertArray, convertIndexes] = parseCategoricalFcn(~, ~, rawData)
            if iscategorical(rawData)
                convertArray = rawData;
            else
                % Replace any strings with "<undefined>" with empties
                % before converting to categorical, so they will properly
                % convert to <undefined> categoricals
                idx = (rawData == "<undefined>");
                rawData(idx) = "";
                convertArray = categorical(rawData);
            end
            convertIndexes = true(size(convertArray));
        end

        % rawData is a cellstr.  Assume all content will convert to
        % categorical.
        function [convertArray, convertIndexes] = parseCategoricalFcnStrings(~, ~, rawData)
            [rawData{cellfun(@isempty, rawData)}] = deal('');

            convertArray = rawData';
            convertIndexes = true(size(convertArray));
        end

        function separator = getSystemDecimalSeparator
            customSeparator = localCustomDecimalSeparator;
            if isempty(customSeparator)
                dfs = java.text.DecimalFormatSymbols;
                separator = char(dfs.getDecimalSeparator);
            else
                separator = customSeparator;
            end 
        end
        
        function setSystemDecimalSeparator(customSeparator)
            localCustomDecimalSeparator(customSeparator);
        end
        
        function isMemoryAvailable  = MemoryTest(numCells)
            if ispc
                [mem,sys] = memory;
                % Test whether the imported data will fit in the system memory.
                % Take a worst-case view that each cell will be represented
                % by a cell array value occupying 200 bytes and that no more
                % than 10% of a available system memory should be used to avoid
                % an unworkable slow down.
                isMemoryAvailable = min(sys.PhysicalMemory.Available/10,...
                    mem.MaxPossibleArrayBytes)>numCells*200;
            else
                isMemoryAvailable = true;
            end
        end
       
        function [fileEncoding, encodingLength, encodingForFopen] = ...
                checkFileEncoding(ch)
            fileEncoding = [];
            encodingForFopen = [];
            encodingLength = 0;
            
            % Check for the existence of a Byte Order Mark (BOM) at the
            % beginning of the file.  If it is defined, it will indicate
            % the file encoding to be used for this file.
            utf8BOM = hex2dec({'EF'; 'BB'; 'BF'});
            utf16LEBOM = hex2dec({'FF'; 'FE'});
            utf16BEBOM = flipud(utf16LEBOM);
            utf32LEBOM = hex2dec({'FF'; 'FE'; '00'; '00'});
            utf32BEBOM = flipud(utf32LEBOM);

            % Check for BOM.  Note that the order of the checks is
            % important once other encoding supported is added (utf-16 BOM
            % is a subset of utf-32 BOM).  For now, just read in using
            % UTF-8 encoding for best results we can achieve.
            bom = {utf8BOM, utf32LEBOM, utf32BEBOM, ...
                utf16LEBOM, utf16BEBOM};
            encodings = {'UTF-8', 'UTF32-LE', 'UTF32-BE', ...
                'UTF16-LE', 'UTF16-BE'};
            supportedEncodings = repmat({'UTF-8'}, 1, length(encodings));
            for i=1:length(bom)
                if length(ch) >= length(bom{i}) && ...
                        isequal(ch(1:length(bom{i})), bom{i})
                    fileEncoding = encodings{i};
                    encodingLength = length(bom{i});
                    encodingForFopen = supportedEncodings{i};
                    break;
                end
            end
        end
    end
end

function isNumericCol = localIsNumericColData(numNonEmptyRows, Inumeric, prefixes, suffixes)
    isNumericCol = false;
    if numNonEmptyRows > 0 && sum(Inumeric) >= numNonEmptyRows/2
        [~, ~, Iprefixes] = unique(prefixes);
        [~, modeCount] = mode(Iprefixes);
        if modeCount >= numNonEmptyRows/2
            [~ ,~ ,Isuffixes] = unique(suffixes);
            [~, modeCount] = mode(Isuffixes);
            if modeCount >= numNonEmptyRows/2
                isNumericCol = true;
            end
        end
    end
end

function separator = localCustomDecimalSeparator(customSeparator)
persistent pcustomDecimalSeparator;
% If there are a no inputs this operation is a read
if nargin==0
    separator = pcustomDecimalSeparator;
% If there are  inputs this operation is a write, intended
% primarily for testing
else
    pcustomDecimalSeparator = customSeparator;
    separator = customSeparator;
end
end

function [numbers, prefix, suffix] = findNumbers(numberString, decimalSeparator)
    if ~ismissing(numberString) && ~strcmp(numberString, '')
        if nargin < 2
            decimalSeparator = '.';
        end
        if nargin < 3
            if decimalSeparator == '.'
                thousandsSeparator = ',';
            elseif decimalSeparator == ','
                thousandsSeparator = '.';
            else
                thousandsSeparator = '';
            end
        end
        
        % Parse '.123'
        regexstr = ['(?<prefix>.*?)(?<numbers>([ ]*[-\+]{0,1}([0-9]+[\' thousandsSeparator ']*)+[\' decimalSeparator ']{0,1}[0-9]*[eEdD]{0,1}[-+]*[0-9]*[i]{0,1})|([-]*([0-9]+[\' thousandsSeparator ']*)*[\' decimalSeparator ']{1,1}[0-9]+[eEdD]{0,1}[-+]*[0-9]*[i]{0,1}))(?<suffix>.*)'];                                                                                    
        try
            result = regexp(numberString, regexstr, 'names');
            numbers = result.numbers;
            invalidThousandsSeparator = false;
            if numbers.contains(thousandsSeparator)
                thousandsRegExp = ['^[0-9]+?(\' thousandsSeparator  '[0-9]{3})*\' decimalSeparator '{0,1}[0-9]*$'];
                if isempty(regexp(numbers,thousandsRegExp,'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            
            if ~invalidThousandsSeparator
                numbers = strrep(numbers, thousandsSeparator, '');
                numbers = strrep(numbers, decimalSeparator, '.');
                
                %
                % FIX - asked about string input to textscan, for now convert
                %
                numbers = textscan(char(numbers),'%f');
                numbers = numbers{1};
                if isempty(numbers) || ~isscalar(numbers)
                    numbers = NaN;
                end
            end
        catch me %#ok<NASGU>
            numbers = NaN;
        end
    else
        % Input was empty, so there are no numbers, and no need to check for
        % prefix or suffix.
        numbers = NaN;
        prefix = "";
        suffix = "";
        return
    end
    try
        prefix = result.prefix;
    catch me %#ok<NASGU>
        prefix = '';
    end
    
    try
        suffix = strtrim(result.suffix);
        if any(regexp(suffix, '[0-9]'))
            numbers = NaN;
        end
    catch me %#ok<NASGU>
        suffix = '';
    end
end

function [numbers, prefix, suffix] = findNumbersLogical(numberCol, decimalSeparator)
    numberCol(ismissing(numberCol)) = '';
    numbers = false(size(numberCol));
    if nargin < 2
        decimalSeparator = '.';
    end
    if nargin < 3
        if decimalSeparator == '.'
            thousandsSeparator = ',';
        elseif decimalSeparator == ','
            thousandsSeparator = '.';
        else
            thousandsSeparator = '';
        end
    end
    
    % Parse '.123'
    regexstr = ['(?<prefix>.*?)(?<numbers>([ ]*[-\+]{0,1}([0-9]+[\' thousandsSeparator ']*)+[\' decimalSeparator ']{0,1}[0-9]*[eEdD]{0,1}[-+]*[0-9]*[i]{0,1})|([-]*([0-9]+[\' thousandsSeparator ']*)*[\' decimalSeparator ']{1,1}[0-9]+[eEdD]{0,1}[-+]*[0-9]*[i]{0,1}))(?<suffix>.*)'];
    try
        result = regexp(numberCol, regexstr, 'names');
        % result is a cell arrays of structures... not very useful.
        % Convert to a structure array.
        if iscell(result)
            st = [result{:}];
        else
            st = result;
        end
        
        numbersStr = [st.numbers]';
        invalidThousandsSeparator = false(size(numberCol));
        if any(numbersStr.contains(thousandsSeparator))
            thousandsRegExp = ['^[0-9]+?(\' thousandsSeparator  '[0-9]{3})*\' decimalSeparator '{0,1}[0-9]*$'];
            res = regexp(numbersStr, thousandsRegExp, 'once');
            invalidThousandsSeparator = cellfun(@isempty, res);
            numbersStr(invalidThousandsSeparator) = '';
        end
        
        numbersStr = strrep(numbersStr, thousandsSeparator, '');
        numbersStr = strrep(numbersStr, decimalSeparator, '.');
        
        % FIX - asked about string input to textscan, for now convert
        for i = 1:size(numbersStr, 1)
            if ~invalidThousandsSeparator(i)
                val = textscan(numbersStr{i},'%f');
                val = val{1};
                if ~isempty(val) && isscalar(val)
                    numbers(i) = true;
                end
            end
        end
    catch me %#ok<NASGU>
    end
    
    try
        prefix = [st.prefix]';
    catch me %#ok<NASGU>
        prefix = string;
    end
    
    try
        % Consider text with numbers in the suffix to not be detected as
        % numeric.  For example "3 out of 5 people" will have 3 as the
        % number, but the suffix as "out of 5 people".  Don't treat this as
        % numeric.
        suffix = [st.suffix]';
        res = regexp(suffix, '[0-9]');
        if iscell(res)
            numsInSuffix = ~cellfun('isempty', res);
            numbers(1:length(res)) = ~numsInSuffix;
        else
            numsInSuffix = ~isempty(res);
            numbers = ~numsInSuffix;
        end
        
    catch me %#ok<NASGU>
        suffix = string;
    end
end

function skipped = localskiplinebreak(fid)

skipped = false;
if ~feof(fid) 
   ch = fread(fid,1,'*uchar');
   if ch==newline
       skipped = true;
   elseif ch==sprintf('\r')
       skipped = true;
       if ~feof(fid)      
          ch = fread(fid,1,'*uchar');
          if ch==newline
             % no op
          else
             fseek(fid,ftell(fid)-1,'bof');
          end
       end
   else
       % If the next char is not a line break, back up one
       fseek(fid,ftell(fid)-1,'bof');
   end
end
end


% Synthesize a fixed width format strings from the format letters and the 
% character counts 
function formatString = localcreatefixedwidthformat(fixedWidthColumnLengths,formats)

if nargin<=1 || isempty(formats) % String formats
    formats = repmat({'s'},[length(fixedWidthColumnLengths) 1]);
else
    formats = strrep(formats,'%',''); % Strip % symbols
end
formatString = '';
if ~isempty(fixedWidthColumnLengths)    
    for k=1:length(fixedWidthColumnLengths)
        if isfinite(fixedWidthColumnLengths(k))
            idx = strfind(formats{k}, '*');
            if ~isempty(idx) && idx(1) == 1
                % For skipping columns, the formatSpec should be something
                % like %*<width><conversion type>
                formatString = sprintf('%s%%*%d%s', formatString, ...
                    fixedWidthColumnLengths(k), formats{k+1});
            else
                formatString = sprintf('%s%%%d%s', formatString, ...
                    fixedWidthColumnLengths(k), formats{k});
            end
        else
            formatString = sprintf('%s%%%s',formatString,formats{k});
        end
    end
end
formatString = sprintf('%s%s',formatString,'%[^\n\r]');

end


function [dataArray,rawArray,parsedLocations] = localParseColumn(dataArray,rawArray,parseRules,col,cols,progressInterval,wb,decimalSeparator)
% Apply the column parse rules to the specified column on the result of
% calling textscan. Return the modified dataArray (cell array of parsed
% data as numeric columns with NaNs in unparsable locations) and rawArray
% (cell array of cell arrays with the unparsed strings in unparsable
% locations).
columnCell = dataArray{col-cols(1)+1};

parseRules{col}.setDecimalSeparator(decimalSeparator);

% If the column has more than 1e4 cells, process it in blocks and update
% the waitbar each iteration.
if length(columnCell)>1e4
    if isa(parseRules{col}, 'com.mathworks.mlwidgets.importtool.DateParsingRule')
        parsedData = datetime(NaN(length(columnCell),1), ...
            NaN(length(columnCell),1), NaN(length(columnCell),1), ...
            'Format', char(parseRules{col}));
    elseif isa(parseRules{col}, 'com.mathworks.mlwidgets.importtool.CategoricalParsingRule')
        parsedData = repmat(categorical(nan), length(columnCell), 1);
    else
        parsedData = NaN(length(columnCell),1);
    end
    parsedLocations = false(length(columnCell),1);
    
    % Loop through complete blocks of 1e4 cells
    for page=0:floor(length(columnCell)/1e4)-1
        [parsedDataBlock,parsedLocationsBlock] = feval(char(parseRules{col}.getApplyFcn),...
            parseRules{col},[],columnCell(page*1e4+1:(page+1)*1e4));
        parsedData(page*1e4+1:min((page+1)*1e4,page*1e4+size(parsedDataBlock,1))) = parsedDataBlock;
        parsedLocations(page*1e4+1:min((page+1)*1e4,page*1e4+size(parsedLocationsBlock,1))) = parsedLocationsBlock;
        progress = page*1e4/length(columnCell);
        barProgress = progressInterval(1)*(1-progress)+progressInterval(2)*progress;       
        if localUpdateWaitBar(wb,barProgress,...
                getString(message('MATLAB:codetools:TextFileParsingData',sprintf('%2.0f%%',100*barProgress))))
             error(message('MATLAB:codetools:TextImportWaitBarCancel')); 
        end
    end
    
    % Process remaining blocks
    [parsedDataBlock,parsedLocationsBlock] = feval(char(parseRules{col}.getApplyFcn),...
            parseRules{col},[],columnCell(1e4*floor(length(columnCell)/1e4)+1:end));
    if ~isempty(parsedDataBlock)
        endRow = min(length(parsedData),1e4*floor(length(columnCell)/1e4)+length(parsedDataBlock));
        parsedData(1e4*floor(length(columnCell)/1e4)+1:endRow) = parsedDataBlock;
    end
    parsedLocations(1e4*floor(length(columnCell)/1e4)+1:end) = parsedLocationsBlock;
else      
   [parsedData,parsedLocations] = feval(char(parseRules{col}.getApplyFcn),...
      parseRules{col},[],columnCell);
end

if iscategorical(parsedData)
    parsedData(~parsedLocations,:) = '<undefined>';
    rawCellColumn = parsedData;
elseif ~isa(parsedData, 'datetime')
    parsedData(~parsedLocations,:) = NaN;
    rawCellColumn = num2cell(parsedData);
    if any(~parsedLocations)
        c = columnCell(~parsedLocations);
        rawCellColumn(~parsedLocations) = mat2cell(c, ones(1, length(c)), 1);
    end
else
    % Create cell array with datetimes
    rawCellColumn = mat2cell(parsedData, ...
        ones(1, length(parsedData)), 1);  %#ok<*MMTC>
    if any(~parsedLocations)
        rawCellColumn(~parsedLocations) = ...
            mat2cell(columnCell(~parsedLocations), ...
            ones(1, length(find(~parsedLocations))), 1);
    end
end
dataArray{col-cols(1)+1} = parsedData;
rawArray{col-cols(1)+1} = rawCellColumn;  

end

% Cancel button callback
function localCreateCancelBtn(es,~)
   wb = ancestor(es,'figure');
   setappdata(wb,'cancelled',true);
   waitbar(0,wb,getString(message('MATLAB:codetools:TextFileImportCancelling')));   
end

function cancelledState = localUpdateWaitBar(wb,fraction,msg)

cancelledState = false;
if ~isempty(wb)
    drawnow
    cancelledState = isappdata(wb,'cancelled') && getappdata(wb,'cancelled');
    if cancelledState
        delete(wb)
    else
        waitbar(fraction,wb,msg);
    end
end  


end

function [dataArray,rawArray] = localFastPathParseNonNumericColumns(dataArray,cols,parseRules,emptyReplacementNumber,progressInterval,wb,isfixedwidth,decimalSeparator)

    % Use the parseRules to parse any columns that are not
    % numeric vectors. This is essentially date strings that
    % were read as strings and need to be converted with the
    % datenum function.
    rawArray = dataArray;
    for col=cols(1):cols(end)
        if ~isempty(parseRules{col})
            % Fast path imported data should not require
            % parsing if the column is numeric because textscan
            % already performed the parse.
            if ~isnumeric(dataArray{col-cols(1)+1})
                if ~isempty(wb)
                    progress1 = (col-cols(1))/(cols(end)-cols(1)+1);
                    progress2 = (col-cols(1)+1)/(cols(end)-cols(1)+1);
                    columnProgressInterval = [progressInterval(2)*progress1+progressInterval(1)*(1-progress1),...
                        progressInterval(2)*progress2+progressInterval(1)*(1-progress2)];
                else
                    columnProgressInterval = [0 1];
                end
                [dataArray,rawArray,parsedLocations] = localParseColumn(dataArray,...
                    rawArray,parseRules,col,cols,...
                    columnProgressInterval,...
                    wb,decimalSeparator);
                % If any locations failed to parse, use the slow path so that
                % these cells can be processed by un-importable
                % data rules.
                if ~all(parsedLocations)
                    error(message('MATLAB:codetools:TextImportFastPathError'));
                end
            elseif ~isempty(emptyReplacementNumber) && ...
                    (~isfixedwidth || (isfixedwidth && isreal(dataArray{col-cols(1)+1})))
                 % If there is a single replace rule one of 2 conditions apply:
                 %
                 % 1. The replacement value is not NaN, which means that if 
                 % the file was scanned without error, any empty values have
                 % been replaced and there are no NaNs in rawArray
                 % 2. The replacement value is NaN, which means that if 
                 % the file was scanned without error, any empty values have
                 % been replaced with NaN and NaNs are allowed in rawArray
                 rawArray{col-cols(1)+1} = num2cell(dataArray{col-cols(1)+1});   
            elseif ~any(isnan(dataArray{col-cols(1)+1})) && ...
                    (~isfixedwidth || (isfixedwidth && isreal(dataArray{col-cols(1)+1})))
                % If the post-processing rules do not comprise a single
                % replacement rule then any NaNs in rawArray represent 
                % empty values which were converted to NaN by the 
                % default behavior of textscan. This means that there was 
                % unprocessed un-importable data and the post processing
                % rules must be applied (i.e. slow path must be used).
                rawArray{col-cols(1)+1} = num2cell(dataArray{col-cols(1)+1});                           
            else
                % If dataArray{col-cols(1)+1} contains NaNs 
                % selected numeric cells have been parsed as
                % empty. Use the slow path for this case so
                % these cells can be processed by un-importable
                % data rules.
                error(message('MATLAB:codetools:TextImportFastPathError'));
            end

        else
            if isfixedwidth
                rawArray{col-cols(1)+1} = strtrim(dataArray{col-cols(1)+1});
            else
                % Assign into rawArray.  Any values which are just a single
                % space ' ' should be set to empty strings.  The single space
                % is just an artifact of how textscan is used.  The generated
                % code and readtable utility produce just empty strings.
                rawArray{col-cols(1)+1} = regexprep(dataArray{col-cols(1)+1}, '^\s$', '');
            end
            dataArray{col-cols(1)+1} = NaN(size(rawArray{col-cols(1)+1}));
        end                
    end
end


function percent = localCalculateNextPercent(rowCount,selectionMode, absoluteEndRow,focusedRow,lastRowToBeSearched,firstRowToBeSearched)
    if selectionMode == 0              % no cell selected
        percent = absoluteEndRow/rowCount;
    elseif selectionMode == 1          % single cell selected
        if absoluteEndRow > focusedRow
            percent = (absoluteEndRow - focusedRow + 1)/rowCount;
        else
            percent = (((rowCount - focusedRow) + 1) + absoluteEndRow)/rowCount;
        end
    else                                % block selection
        if absoluteEndRow > focusedRow
            percent = ((absoluteEndRow - focusedRow) + 1)/((lastRowToBeSearched - firstRowToBeSearched) + 1);
        else
            percent = (((lastRowToBeSearched - focusedRow) + 1) + absoluteEndRow)/((lastRowToBeSearched - firstRowToBeSearched) + 1);
        end
    end
end

function percent = localCalculatePrevPercent(rowCount,selectionMode, absoluteStartRow,focusedRow,lastRowToBeSearched,firstRowToBeSearched)
   if selectionMode == 0                    % no selection
        percent = (rowCount - absoluteStartRow)/rowCount;
   elseif selectionMode == 1                % single cell selection
        if absoluteStartRow <= focusedRow
            percent = (focusedRow - absoluteStartRow + 1)/rowCount;
        else
            percent = ((focusedRow + ((rowCount - absoluteStartRow) + 1)))/rowCount;
        end
   else                                     % block selection 
       if absoluteStartRow <= focusedRow
            percent = ((focusedRow - absoluteStartRow + 1))/((firstRowToBeSearched - lastRowToBeSearched) + 1);
        else
            percent = ((focusedRow + (firstRowToBeSearched - absoluteStartRow) + 1))/((firstRowToBeSearched - lastRowToBeSearched) + 1);
       end
    end
end

function expandedRowArray = localGetExpandedRowArray(selRowsIntervalArray)
    selRowsCount = 1;
    expandedArrayCount = 1;
    while selRowsCount < length(selRowsIntervalArray)
        intervalElement = selRowsIntervalArray(selRowsCount);
        while intervalElement <= selRowsIntervalArray(selRowsCount + 1)
            expandedRowArray(expandedArrayCount) = intervalElement; %#ok<AGROW>
            expandedArrayCount = expandedArrayCount + 1;
            intervalElement = intervalElement + 1;
        end
        selRowsCount = selRowsCount + 2;
    end
end

function [selectionMode, firstRowToBeSearched,lastRowToBeSearched,firstColumnToBeSearched,lastColumnToBeSearched] = localGetSearchScope(rowCount,columnCount,selRowsIntervalArray, selCols,searchOnlySelection)
     % defining scope of search when no cell is selected. A boolean
     % 'selection' with value 0 is used to denote this case
     if isempty(selCols)
        selectionMode = 0;
        lastRowToBeSearched = rowCount;
        lastColumnToBeSearched = columnCount;
        firstRowToBeSearched = 1;
        firstColumnToBeSearched = 1;
     elseif (length(selRowsIntervalArray) == 2 && length(selCols) == 1 && selRowsIntervalArray(1) == selRowsIntervalArray(2)) || searchOnlySelection == 0
        % single cell selection
        selectionMode = 1;
        % absolute row,column values of search boundaries
        lastRowToBeSearched = rowCount;
        lastColumnToBeSearched = columnCount;
        firstRowToBeSearched = 1;
        firstColumnToBeSearched = 1;

     % defining scope of search for block selections
     else
        selectionMode = 2;

        % expand the selRowsIntervalArray array to include all the selected
        % rows as individual elements
        expandedRowArray = localGetExpandedRowArray(selRowsIntervalArray);  %#ok<NASGU>

        lastRowToBeSearched = selRowsIntervalArray(end);
        lastColumnToBeSearched = selCols(length(selCols));
        firstRowToBeSearched = selRowsIntervalArray(1);
        firstColumnToBeSearched = selCols(1);
    end
end

function [firstValue, secondValue] = localSwap(firstValue,secondValue)
    temp = firstValue;
    firstValue = secondValue;
    secondValue = temp;
end

function v = isnat(t) 
    % Temporary local function to be replaced when datetime version is
    % available
    v = isnan(datenum(t));
end
