function introspectFile(ds)
%INTROSPECTFILE reads variable names and format information from text file.
%   This function is responsible for detecting the variable name and format
%   informationusing readVarFormat and using them to set the active
%   variable names and active formats.

%   Copyright 2014-2018 The MathWorks, Inc.

    % imports
    import matlab.internal.datatypes.warningWithoutTrace;

    % if no splits, or empty splits, return early
    if isempty(ds.Splitter.Splits) || all([ds.Splitter.Splits.Size] == 0)
        % set properties of the empty datastore that were removed in
        % initTextFiles
        datastorePropSetter(ds,ds.PrivateVarFormatStruct);
        return;
    end

    % variable name and format information as passed by the user during
    % datastore construction. These are always cellstrs.
    inStruct = ds.PrivateVarFormatStruct;
    
    % detect variable names and formats and the ones that are skipped.
    % varNames and formatCell come out as cellstrs always
    [varNames, formatCell, skippedVec] = readVarFormat(ds, inStruct);
    
    % local vars
    allVarNames = inStruct.VariableNames;
    sVarNames = inStruct.SelectedVariableNames;
    sFormats = inStruct.SelectedFormats;
    
    % when both ReadVariableNames is true and VariableNames are provided
    % the detected VariableNames are overwritten by the specified ones
    % after issuing a warning message.
    if ~isempty(allVarNames)
    
        % ReadVariableNames is true by default
        if ds.ReadVariableNames
            warningWithoutTrace(message('MATLAB:datastoreio:tabulartextdatastore:replaceReadVariableNames'));
        end
        
        % number of VariableNames and TextscanFormats must match
        if numel(allVarNames) ~= numel(formatCell)
            error(message('MATLAB:datastoreio:tabulartextdatastore:varFormatMismatch', ...
                                      'VariableNames', 'TextscanFormats'));
        end
        
        varNames = allVarNames;
    end
    
    % make valid variable names
    validVarNames = matlab.internal.tabular.makeValidVariableNames(varNames, 'warn');
    
    % this is explicitly done so that the numel check happens in the actual
    % setters of VariableNames and TextscanFormats and that they are in the
    % right state
    ds.PrivateVariableNames = validVarNames;
    ds.PrivateTextscanFormats = formatCell;
    
    % final sets
    ds.VariableNames = validVarNames;
    ds.TextscanFormats = formatCell;
    
    % handle skips in formats with SelectedVariableNames and
    % SelectedFormats
    if any(skippedVec)
        
        % SelectedVariableNames cannot be specified when there are skips in
        % the format
        if ~isempty(sVarNames)
            error(message('MATLAB:datastoreio:tabulartextdatastore:invalidActiveSkip', ...
                                                 'SelectedVariableNames'));
        end
        
        % SelectedFormats cannot be specified when there are skips in the
        % format
        if ~isempty(sFormats)
            error(message('MATLAB:datastoreio:tabulartextdatastore:invalidActiveSkip', ...
                                                       'SelectedFormats'));
        end
        
        % set the active variable names
        ds.SelectedVariableNames = validVarNames(~skippedVec);
    else
        if isempty(sVarNames)
            if ~isempty(sFormats)
                % SelectedFormats cannot be specified without
                % SelectedVariableNames
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidActiveFormats'));
            end
        else
            % make the SelectedVariableNames valid
            ds.SelectedVariableNames = matlab.internal.tabular.makeValidVariableNames(sVarNames, 'warn');
            
            if ~isempty(sFormats)
                ds.SelectedFormats = sFormats;
            end
        end
    end
end

function [varNames, outFormatCell, skippedVec] = readVarFormat(ds, inStruct)
%readvarFormat detects variable names and format information from text file
%   This function is responsible for detecting the variable name and format
%   information from the text file based on the value of ReadVariableNames
%   and whether TextscanFormats are provided during datastore construction.
%   It ensures that the TextscanFormats detected or specified are valid and
%   match the number of variable names detected or specified.

    % imports
    import matlab.io.datastore.TabularTextDatastore;
    import matlab.io.datastore.internal.filesys.createStream;
    import matlab.io.internal.text.determineVarNames;
    import matlab.io.internal.text.determineFormatString;    
    import matlab.io.internal.text.detectVariableNames;
    import matlab.io.internal.text.detectParametersFromFileOrStr;

    % currently we use the first file to detect variable names and formats
    file = ds.Files{1};

    % open the first file as a read only stream
    try
        stream = createStream(file, 'rt', ds.FileEncoding);
    catch
        error(message('MATLAB:datastoreio:tabulartextdatastore:unableToOpenFile', file));
    end

    % close the stream on exit.
    cleanup = onCleanup(@() close(stream));

    % Our lower level API's use upto 4 MB to detect Delimiter,
    % NumHeaderlines and MultipleDelimitersAsOne
    delimSupplied = ds.PrivateDelimiterSupplied;
    headerSupplied = ds.PrivateNumHeaderLinesSupplied;
    types = {};
    % empty delimiters are not handled by detectParametersFromFileOrStr
    if ~isempty(ds.Delimiter)
        dataForDetection = readTextBytes(stream, TabularTextDatastore.DEFAULT_DETECTION_SIZE);
        stream.seek(0); % reset the stream for later use.
        args = ds.getTextscanArgs();
        % unescaping the values passed to TreatAsMissing 
        args{14} = matlab.io.internal.utility.unescape(args{14});
        fmt = ds.PrivateVarFormatStruct.TextscanFormats;
        if ~isempty(fmt)
            fmt_str = matlab.iofun.internal.formatParser([fmt{:}]);
            n = nnz(~fmt_str.IsLiteral);
            args(end+1:end+2) = {'NumVariables',n};
        end
        [delim,header,multipleDelimsAsOne,types] = detectParametersFromFileOrStr(dataForDetection,delimSupplied,headerSupplied,ds.Delimiter,ds.NumHeaderLines,false,args);
        if ~ds.PrivateMultipleDelimitersAsOneSupplied
            ds.PrivateMultipleDelimitersAsOne = multipleDelimsAsOne;
        end
        if ~delimSupplied
            % Detected delimiter might have a whitespace
            % character, if so, remove it from the whitespace
            % parameter to avoid warning

            if iscell(delim) && numel(delim) == 1
                delim = delim{1};
            end
            % isWhitespaceUsingDefault argument to handleDelimWhitespaceConflicts
            % method is 'true' here, because we detect the delimiter
            % and we need to handle the conflict without any warnings.
            [delim, ws] = TabularTextDatastore.handleDelimWhitespaceConflicts(...
                delim, ds.PrivateWhitespace, true);
            ds.PrivateWhitespace = ws;
            ds.PrivateDelimiter = delim;
        end
        if ~headerSupplied
            ds.PrivateNumHeaderLines = header;
        end
    end
    
    % escape the delimiter before using
    delim = ds.Delimiter;
    if ischar(delim)
        delim = sprintf(delim);
    else
        delim = cellfun(@(x) sprintf(x), delim, 'UniformOutput', false);    
    end
    
    % setting up textscan arguments used for introspection, this does not
    % contain delimiter, whitespace, treatAsMissing and headerlines as they
    % are passed separately. Also MissingValue, ReturnOnError are not
    % passed as they do not affect the VariableNames and Formats. Currently
    % ExponentCharacters cannot be detected as a numeric format.
    cStyle = ds.CommentStyle;
    txtScanArgsforIntroSpection = {'CommentStyle', cStyle, ...
                        'MultipleDelimsAsOne', ds.MultipleDelimitersAsOne};
    
    % index in the data
    strIdx = 0;
    
    % local variables
    hdrLines = ds.NumHeaderLines;
    readVarNames = ds.ReadVariableNames;
    rowDelim = ds.RowDelimiter;
    whiteSpace = ds.Whitespace;
    varFormatData = [];
    
    % block of code which detects VariableNames from the file.
    if readVarNames || ~ds.PrivateReadVariableNamesSupplied
        % buffer atleast 1 row of information (not including the header
        % lines and the comment lines) which includes the variable names
        varFormatData =  ...
            bufferDataFromFile(stream, file, rowDelim, cStyle, hdrLines, ...
                                        whiteSpace, 'VariableNames', true);

        % Read in the first line of var names as a single string, skipping
        % any leading blank lines and header lines. This call handles
        % non-default row delimiters like : for example ignoring delimiter
        % and whitespace. This call also accepts CommentStyle as we want to
        % skip comment lines. Also consume the eor as we do not want to
        % account for it when we reuse varFormatData.
        [raw,strIdx] = textscan(varFormatData, ['%s%[' rowDelim ']'], 1, ...
                                'Delimiter', '', 'Whitespace', whiteSpace, ...
                                'Headerlines', hdrLines, 'EndOfLine', ...
                                rowDelim, txtScanArgsforIntroSpection{:});
        hdrLines = 0; % just skipped them
        if isempty(raw{1}) || isempty(raw{1}{1})
            error(message('MATLAB:datastoreio:tabulartextdatastore:varFormatDetectionFailure', ...
                file, 'VariableNames', 'VariableNames'));
        else
            vnline = raw{1}{1};
        end
    end
    
    % local variables    
    treatAsMissing = ds.TreatAsMissing;
    inFormatCell = inStruct.TextscanFormats;
    
    % block of code that detect formats. If ReadVariableNames was false we
    % buffer data. Otherwise we resize the data. We check if it is empty in
    % which case we buffer data from file, otherwise we try to check if the
    % nonempty data ends in a row delimiter. We buffer more if it does not
    % (to check against truncated data) otherwise use the same data to
    % detect formats.
    if isempty(inFormatCell)
        % if ReadVariableNames is false, buffer data from file.
        if isempty(varFormatData)
            varFormatData =  bufferDataFromFile(stream, file, rowDelim, ...
                                cStyle, hdrLines, whiteSpace, 'TextscanFormats', true);
        else
            % resize the data
            varFormatData = varFormatData(strIdx+1:end);
            
            % if there is no more data, then ask for more
            if isempty(varFormatData)
                varFormatData =  bufferDataFromFile(stream, file, ...
                      rowDelim, cStyle, hdrLines, whiteSpace, 'TextscanFormats', true);
            else
                % ensure data ends at a row delimiter
                delimAtEndOfData = findRowDelim(varFormatData, rowDelim, cStyle, hdrLines, whiteSpace);
                
                % request more data if the data does not end at a row delimiter
                if ~delimAtEndOfData
                    varFormatData = [varFormatData bufferDataFromFile(stream, ...
                                 file,  rowDelim, cStyle, hdrLines, whiteSpace, 'TextscanFormats', false)];
                end
            end
        end
        
        % Guess a format string for the dataline by reading it as a single
        % string, skipping any leading blank lines. This call handles
        % non-default row delimiters like (':') for example, ignoring
        % delimiter and whitespace. This call also accepts CommentStyle as
        % we want to skip comment lines.
        raw = textscan(varFormatData, '%s', 1, 'Delimiter', '', ...
                       'Whitespace', whiteSpace, 'Headerlines', hdrLines, ...
                       'EndOfLine', rowDelim, txtScanArgsforIntroSpection{:});
        if isempty(raw{1}) || isempty(raw{1}{1})
            error(message('MATLAB:datastoreio:tabulartextdatastore:varFormatDetectionFailure', ...
                              file, 'TextscanFormats', 'TextscanFormats'));
        else
            % determine the format string from the first line
            rawContents = raw{1}{1};
            formatStr = determineFormatString(rawContents, delim, whiteSpace, ...
                              rowDelim, treatAsMissing, types, ds.DatetimeType, ds.DurationType, true, txtScanArgsforIntroSpection);
            % convert to a struct
            fStruct = matlab.iofun.internal.formatParser(formatStr);
            outFormatCell = fStruct.Format;
            skippedVec = zeros(1,numel(outFormatCell));
        end
    else
        % user specified formats are always wrapped in a cell
        [outFormatCell, skippedVec] = ...
            TabularTextDatastore.concatLiteral(inFormatCell, ds.TextscanFormatsAsCellStr);
    end
    
    % detect ReadVariableNames
    fmtstr = [outFormatCell{:}];
    if ~ds.PrivateReadVariableNamesSupplied && ~matlab.io.internal.text.fomatIsAllString(fmtstr)
        ds.PrivateReadVariableNames = detectVariableNames(fmtstr,vnline, ...
            ds.Delimiter,ds.Whitespace,ds.RowDelimiter,txtScanArgsforIntroSpection);
        readVarNames = ds.PrivateReadVariableNames;
    end

    % setup VariableNames
    if readVarNames
        varNames = determineVarNames(vnline, strjoin(outFormatCell), delim, ...
                           whiteSpace, rowDelim, false, txtScanArgsforIntroSpection);
        if numel(varNames) ~= numel(outFormatCell)
            error(message('MATLAB:readtable:ReadVarNamesFailed',file, ...
                                    numel(outFormatCell),numel(varNames)));
        end
    else
        % defaults are {'Var1', 'Var2', ...}
        varNames = matlab.internal.tabular.defaultVariableNames((1:numel(outFormatCell)));
    end
end

function varFormatData =  bufferDataFromFile(stream, file, rowDelim, cStyle, hdrLines, whiteSpace, propName, throwErrorIfNoData)
%BUFFERDATAFROMFILE buffers data from file.
%   This function is responsible to gurantee returning atleast 1 row of
%   data (variable name line or data line, not incuding comment lines and
%   header lines). The upper bound on the how much data we buffer to detect
%   variable names and fomat information is 32 MB which is also the split
%   size. We error graciously when we cannot find the row of information.

    % imports
    import matlab.io.datastore.TabularTextDatastore;
    
    % read data from file
    [tmpData, tmpBytesRead] = readTextBytes(stream, TabularTextDatastore.DEFAULT_PEEK_SIZE);
    
    % error early if no data is available
    if isempty(tmpData)
        if throwErrorIfNoData
            error(message('MATLAB:datastoreio:tabulartextdatastore:varFormatDetectionFailure', ...
                                                file, propName, propName));
        else
            varFormatData = [];
            return
        end
    end
    
    % see if rowDelim exists at the end of the first variable or data line
    varFormatData = tmpData;
    bytesRead = tmpBytesRead;
    delimAtEndOfData = findRowDelim(varFormatData, rowDelim, cStyle, hdrLines, whiteSpace);
    
    % buffer data if a rowDelim was not found in the initial peek size
    while (bytesRead <= TabularTextDatastore.BUFFER_UPPERLIMIT) && ~delimAtEndOfData
        
        % read data from file
        [tmpData, tmpBytesRead] = readTextBytes(stream, TabularTextDatastore.DEFAULT_PEEK_SIZE);
        
        % this might just be data with no eor at the end.
        if isempty(tmpData)
            break;
        end
        
        % accumulate data before calling textscan, ensured that it is
        % non-empty
        varFormatData = [varFormatData tmpData];
        bytesRead = bytesRead + tmpBytesRead;
        
        % see if rowDelim exists at the end of the first variable or data line
        delimAtEndOfData = findRowDelim(varFormatData, rowDelim, cStyle, hdrLines, whiteSpace);
    end
    
    % error if we go beyond 32MB
    if (bytesRead > TabularTextDatastore.BUFFER_UPPERLIMIT) && ~delimAtEndOfData                  
        error(message('MATLAB:datastoreio:tabulartextdatastore:varFormatDetectionFailure', ...
                                                file, propName, propName));
    end
end

function tf = findRowDelim(varFormatData, rowDelim, cStyle, hdrLines, whiteSpace)
%FINDROWDELIM finds a row delimiter at the end of a data line.
%   This function is responsible to find a row delimiter at the end of a 
%   data line and return true/false based on whether it succeeded. For 
%   '\r\n' it looks for either a \r or a \n or both.

    % at this stage rowDelim is always unescaped
    if strcmp(rowDelim, '\r\n')
        tf  = checkForRowDelimAfterData('\n') || checkForRowDelimAfterData('\r');
    else
        tf = checkForRowDelimAfterData(rowDelim);
    end

        % nested function to return true when row delimiter is found. This
        % skips all the leading blank lines, header lines, comment lines
        % and lines with only whitespace characters (empty lines)
        function tf = checkForRowDelimAfterData(rowDelim)
            tf = true;    
            delimAfterData = textscan(varFormatData, ['%*s%[' rowDelim ']'], 1, ...
                                     'Delimiter', '', 'Whitespace', whiteSpace, ...
                                     'Headerlines', hdrLines, 'EndOfLine', ...
                                         rowDelim, 'CommentStyle', cStyle);
            if (isempty(delimAfterData{1}) || isempty(delimAfterData{1}{1}))
                tf = false;
            end
        end
end

function datastorePropSetter(ds,inStruct)
%DATASTOREPROPSETTER sets the properties of the datastore that were removed 
%in the InitTextProperties, when the datastore is initialized without files.
    ds.PrivateVariableNames = inStruct.VariableNames;
    ds.PrivateTextscanFormats = inStruct.TextscanFormats;
    ds.PrivateSelectedFormats = inStruct.SelectedFormats;
end