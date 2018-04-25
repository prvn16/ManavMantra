function t = readTextFile(file, args)
%READFILE Read in a delimited text file and create a table.

%   Copyright 2012-2018 The MathWorks, Inc.
import matlab.internal.datatypes.validateLogical
% Platform standard EOL character combinations
% Carriage Return : CR = sprintf('\r') = char(13)
% Line Feed       : LF = sprintf('\n') = char(10)
CR   = sprintf('\r');   % Mac (old-style) EOL
LF   = newline;         % Unix (standard) EOL
CRLF = sprintf('\r\n'); % Windows (standard) EOL -- default

defaultwhitespace = sprintf(' \b\t');

nvPairs = { 'ReadVariableNames', true;
    'ReadRowNames',false;
    'Delimiter',',';
    'Format',[];
    'Whitespace',defaultwhitespace;
    'TreatAsEmpty', {};
    'HeaderLines', 0;
    'FileEncoding','';
    'Encoding','system';
    'DateLocale','';
    'EndOfLine',CRLF;
    'CommentStyle',{}
    'TextType','char';
    'DatetimeType','datetime'
    'DurationType','duration'};

[readVarNames,readRowNames,delimiter,format,...
    whitespace,treatAsEmpty,headerlines, ...
    altNameEncoding,fileEncoding,locale,eol,...
    commentstyle,texttype,datetimetype,durationtype,supplied,otherArgs]...
    = matlab.internal.datatypes.parseArgs(nvPairs(:,1)', nvPairs(:,2)', args{:});

detected.Delimiter = ~supplied.Delimiter;
detected.HeaderLines = ~supplied.HeaderLines;
detected.Format = ~supplied.Format;
detected.ReadVariableNames = ~supplied.ReadVariableNames;

if supplied.FileEncoding && ~supplied.Encoding
    fileEncoding = altNameEncoding;
end

eol = sprintf(eol);
whitespace = sprintf(whitespace);

validatestring(texttype,{'char','string'});
validatestring(datetimetype,{'datetime','text'});
validatestring(durationtype,{'duration','text'});

otherArgs = [otherArgs , {'TextType',texttype}];
readRowNames = validateLogical(readRowNames,'ReadRowNames');
readVarNames = validateLogical(readVarNames,'ReadVariableNames');

inferFormat = ~supplied.Format;

% Pass the locale along to textscan
if supplied.Format && supplied.DateLocale
    otherArgs{end+1} = 'DateLocale';
    otherArgs{end+1} = locale;
end

if supplied.CommentStyle
    otherArgs{end+1} = 'CommentStyle';
    otherArgs{end+1} = commentstyle;
end

if isempty(treatAsEmpty)
    treatAsEmpty = {};
elseif ischar(treatAsEmpty) && ~isrow(treatAsEmpty)
    % textscan does something a little obscure when treatAsEmpty is char but not a
    % row vector, disallow that here.
    error(message('MATLAB:readtable:InvalidTreatAsEmpty'));
elseif ischar(treatAsEmpty) || iscellstr(treatAsEmpty) || isstring(treatAsEmpty)
    % TreatAsEmpty is only ever applied to numeric fields in the file, and textscan
    % ignores leading/trailing whitespace for those fields, so trim insignificant
    % whitespace.
    treatAsEmpty = strtrim(treatAsEmpty);
    if any(~isnan(str2double(treatAsEmpty))) || any(strcmpi('nan',treatAsEmpty))
        error(message('MATLAB:readtable:NumericTreatAsEmpty'));
    end
else
    error(message('MATLAB:readtable:InvalidTreatAsEmpty'));
end

if ~isscalar(headerlines) || ~isnumeric(headerlines) || ...
        (headerlines < 0) || (round(headerlines) ~= headerlines)
    error(message('MATLAB:readtable:InvalidHeaderLines'));
end

if supplied.Delimiter
    % Check the delimiter, and convert 'space','comma', etc. into real delimiters.
    delimiter = validateDelims(delimiter);
end

% Check the parameters for valid values in textscan.
validateTextscanParameters(otherArgs);

% Open the file.
[fid,file] = openFile(file,fileEncoding);
try
    if ~supplied.Delimiter || ~supplied.HeaderLines || inferFormat
        
        detectIOargs = struct('Encoding',fileEncoding);
        detectIOargs.Whitespace = whitespace;
        detectIOargs.LineEnding = eol;
        detectIOargs.CommentStyle = commentstyle;
        
        if ~inferFormat
            fmt_str = matlab.iofun.internal.formatParser(format);
            n = nnz(~fmt_str.IsLiteral);
            detectIOargs.NumVariables = n;
        end
        
        if supplied.Delimiter
            detectIOargs.Delimiter = delimiter;
        end
        if ~supplied.HeaderLines
            headerlines = [];
        end
        detectIOargs.NumHeaderLines = headerlines;

        if supplied.DateLocale
            detectIOargs.DatetimeLocale = locale;
        end

        file = matlab.io.internal.validateFileName(file);
        % Choose the first match from the list of valid file names.
        file = file{1};

        emptyColType = 'double';
        opts = matlab.io.internal.text.getTextOpts(file,emptyColType,detectIOargs);

        delimiter = cellfun(@sprintf,opts.Delimiter,'UniformOutput',false);
        if opts.VariableNamesLine > 0
            if ~supplied.HeaderLines
                headerlines = opts.VariableNamesLine - 1;
                supplied.HeaderLines = true;
            end
            if ~supplied.ReadVariableNames
                readVarNames =  true;
                supplied.ReadVariableNames = true;
            end
        else
            if ~supplied.HeaderLines
                headerlines = opts.DataLines(1) - 1;
                supplied.HeaderLines = true;
            end
            if ~supplied.ReadVariableNames
                readVarNames =  false;
                supplied.ReadVariableNames = true;
            end
        end
        
        % If using space aligned reading, pass in mdao true (unless it's being
        % overridden by a user input; This is why it's added to the front.)
        if strcmp(opts.ConsecutiveDelimitersRule,'join')
            otherArgs = [{'MultipleDelimsAsOne', true}, otherArgs];
        end
    else
        opts = matlab.io.text.DelimitedTextImportOptions('Delimiter',delimiter,...
            'Whitespace',whitespace,...
            'LineEnding',eol,...
            'DataLines',[headerlines+readVarNames+1 inf],...
            'VariableNamesLine',readVarNames*(headerlines+readVarNames)...
            );
        
        if [otherArgs{find(strcmp(otherArgs,'MultipleDelimsAsOne'))+1}] %#ok<BDSCA>
            opts.ConsecutiveDelimitersRule = 'join';
            opts.LeadingDelimitersRule = 'ignore';
        end
    end
    
    if ~supplied.Whitespace
        whitespace = sprintf(opts.Whitespace);
        if supplied.Delimiter
            if ischar(delimiter) && isscalar(delimiter)
                whitespace(whitespace==delimiter)=[];
            else
                for d = delimiter
                    if isscalar(d{1})
                        whitespace(whitespace==d{1})=[];
                    end
                end
            end
        end

        % If a non-standard EOL character combination is specified as the
        % the delimiter separating rows of data in the text file (e.g. ':'),
        % then the default standard EOL character combinations should be
        % treated as whitespace and ignored (i.e. '\r\n').
        if supplied.EndOfLine && ~any(strcmp(eol, {CR, LF, CRLF}))
            whitespace = [whitespace, CRLF];
        end
    end
    
    % Skip the header
    [~,endHeaderPos] = textscanReadLines(fid, 0, whitespace, eol, headerlines, otherArgs);
    if readVarNames
        vnline = getVariableNamesLine(inferFormat, fid, whitespace, eol, otherArgs);
        if isa(vnline,'double') && isempty(vnline) % file was empty, return empty table
            t = table.empty(0,0);
            fclose(fid);
            return
        end
    else
        vnline = '';
    end
    % Guess at a format string for the data.
    if inferFormat
        % Save current position (start of data) in file, make a guess at the file format
        % based on first line of data, step back to the start of the data, and read in
        % the data using the guessed-at format.
        startDataPosn = ftell(fid);
        format = guessFormat(fid, vnline, delimiter, whitespace, eol, treatAsEmpty, datetimetype, durationtype, opts, otherArgs);
        fseek(fid, startDataPosn, 'bof');
        
    end
    
    numNonDataLines = headerlines + readVarNames;
    
    if inferFormat % read data using the detected format and update as it fails.
        rawData = textscanReadData(fid, format, delimiter, whitespace, eol, treatAsEmpty, otherArgs);
        
        if ~feof(fid)
            % textscan failed because some column had the "wrong" value in it, i.e., a field
            % in the first data line was numeric (or an empty field), but a subsequent row
            % had a non-numeric string in that column.
            
            % Step back to the start of the data, make a more careful guess at the format,
            % step back again, and reread with the new format.
            fseek(fid, startDataPosn, 'bof');
            format = updateFormatGuess(fid, format, delimiter, whitespace, eol, treatAsEmpty, numNonDataLines, datetimetype, durationtype, opts, otherArgs);
            
            if ~supplied.ReadVariableNames
                % May have detected no variable names, but then the format changed to all
                % strings. In that case, read variable names
                if matlab.io.internal.text.fomatIsAllString(format)
                    readVarNames = true;
                    fseek(fid,endHeaderPos,'bof');
                    vnline = getVariableNamesLine(inferFormat, fid, whitespace, eol, otherArgs);
                    startDataPosn = ftell(fid);
                else
                    % Otherwise, recheck the vnline against the new format.
                    readVarNames = matlab.io.internal.text.detectVariableNames(format,vnline,delimiter,whitespace,eol,otherArgs);
                    if ~readVarNames
                        fseek(fid,endHeaderPos,'bof');
                        startDataPosn = endHeaderPos;
                    end
                end
                
            end
            fseek(fid, startDataPosn, 'bof');
            rawData = textscanReadData(fid, format, delimiter, whitespace, eol, treatAsEmpty,otherArgs);
            
            if ~feof(fid)
                % Even the more careful format guess did not succeed. Reread the file treating
                % all variables as strings.
                format(2:2:end) = 'q';
                fseek(fid,startDataPosn,'bof');
                % If varnames was detected as false, and not supplied by the user, reset
                % readVarNames at this point and skip the first data line as it will be read as
                % variable names. All string output always reads varnames unles told otherwise.
                if ~supplied.ReadVariableNames && ~readVarNames
                    readVarNames = true;
                    fseek(fid,endHeaderPos,'bof');
                    vnline = getVariableNamesLine(inferFormat, fid, whitespace, eol, otherArgs);
                end
                rawData = textscanReadData(fid, format, delimiter, whitespace, eol, treatAsEmpty,otherArgs);
            end
        end
        
        
    else % ~inferFormat
        % Read in the data using the specified format.
        rawData = textscanReadData(fid, format, delimiter, whitespace, eol, treatAsEmpty, otherArgs);
        
        if ~feof(fid)
            m = message('MATLAB:readtable:CouldNotReadEntireFileWithFormat');
            baseME = MException(m.Identifier,'%s',getString(m));
            % If all the cells in rawData are the same length, textscan stopped at the start
            % of a line. If the first few cells have length L, and the rest L-1, then
            % textscan stopped mid-line. We can be helpful here.
            varlens = cellfun(@(x)size(x,1),rawData);
            dvarlens = diff(varlens);
            locs = find(dvarlens);
            if isempty(locs) || (isscalar(locs) && dvarlens(locs)==-1)
                errLine = min(varlens) + 1 + numNonDataLines;
                m = message('MATLAB:readtable:ReadErrorOnLine',errLine);
                throw(addCause(baseME,MException(m.Identifier,'%s',getString(m))));
            else
                % Otherwise, something else happened for which we have no specific advice.
                throw(baseME);
            end
        end
    end
catch ME
    fclose(fid);
    reportParamsWithError(ME, detected, delimiter, headerlines, readVarNames, format);
end

isEndOfFile = feof(fid);
fclose(fid);

try
    if readVarNames
        % Determine the table's variable names from the variable names line in the file.
        varNames = matlab.io.internal.text.determineVarNames(vnline,format,delimiter,whitespace,eol,true,otherArgs);
        
        if numel(varNames) ~= length(rawData)
            [id,collectOutput] = findParamValue('CollectOutput',otherArgs);
            if ~isempty(id) && collectOutput % collect output is true.
                % This concatinates the variable names to match the output sizes when
                % CollectOutput is true
                sizes = cellfun(@(c)size(c,2),rawData);
                startOffset = cumsum([0 sizes(1:end-1)]);
                numNewVars = numel(sizes);
                newVarNames = cell(1,numNewVars);
                for i = 1:numNewVars
                    oldNamesIdx = startOffset(i) + (1:sizes(i));
                    newVarNames{i} = strjoin(varNames(oldNamesIdx),'_');
                end
                varNames = newVarNames;
            else
                varNames = matlab.io.internal.text.determineVarNames([vnline eol],format,delimiter,whitespace,eol,true,otherArgs);
                if numel(varNames) > length(rawData) && all(cellfun(@isempty,varNames(length(rawData)+1:end)))
                    varNames(length(rawData)+1:end) = [];
                else
                    error(message('MATLAB:readtable:ReadVarNamesFailed',file,length(rawData),numel(varNames)));
                end
            end
        end
    else
        % If reading row names, number remaining columns beginning from 1, we'll drop
        % Var0 below.
        varNames = matlab.internal.tabular.private.varNamesDim.dfltLabels((1:length(rawData))-readRowNames);
    end
    
    if isempty(rawData) % i.e., if the file had no data
        t_data = cell(length(rawData));
    else
        columnLengths = cellfun(@(x)size(x,1),rawData);
        tooShort = columnLengths ~= columnLengths(1);
        if any(tooShort)
            % Some of the columns didn't read to completion. If the file ended, then all the
            % data was read and we can pad the output with empty values.
            if isEndOfFile
                rawData = fillShortRows(rawData,tooShort,columnLengths(1),otherArgs);
            else % otherwise, issue an error.
                if inferFormat
                    error(message('MATLAB:readtable:UnequalVarLengthsFromFileWithFormat'));
                else
                    error(message('MATLAB:readtable:UnequalVarLengthsFromFileNoFormat'));
                end
            end
        end
        
        if readRowNames
            rowNames = rawData{1};
            if ischar(rowNames)
                rowNames = cellstr(rowNames);
            elseif isstring(rowNames)
                rowNames = cellstr(convertStringsToChars(rowNames));
            elseif isnumeric(rowNames)
                rowNames = sprintfc('%.15g',rowNames);
            elseif ~iscellstr(rowNames)
                error(message('MATLAB:readtable:RowNamesVarNotString', class(rowNames)));
            end
            rawData(1) = [];
            dimNames = matlab.internal.tabular.private.metaDim.dfltLabels;
            if readVarNames, dimNames{1} = varNames{1}; end
            varNames(1) = [];
        end
        t_data = rawData(:)';
    end
catch ME
    reportParamsWithError(ME,detected,delimiter,headerlines,readVarNames,format);
end
t = table(t_data{:});

% Set the var names.  These will be modified to make them valid, and the
% original strings saved in the VariableDescriptions property.  Fix up duplicate
% or empty names.
t.varDim = t.varDim.setLabels(varNames,[],true,true,true);

if ~isempty(rawData) && readRowNames
    t.rowDim = t.rowDim.setLabels(rowNames,[],true,true); % Fix up duplicate or empty names
    t.metaDim = t.metaDim.setLabels(dimNames,[],true,true,true); % Fix up duplicate, empty, or invalid names
end
if readVarNames
    % Make sure var names and dim names don't conflict. That could happen if var
    % names read from the file are the same as the default dim names (when ReadRowNames
    % is false), or same as the first dim name read from the file (ReadRowNames true).
    t.metaDim = t.metaDim.checkAgainstVarLabels(t.varDim.labels,'silent');
end
end


%-------------------------------------------------------------------------------
function format = guessFormat(fid,vnline,delimiter,whitespace,eol,treatAsEmpty,datetimetype,durationtype,opts,otherArgs)
% Guess at the format string for the data, based on the first line of data.
% Read the first line of data as a single string.
dataLine = textscanReadLines(fid, 1, whitespace, eol, 0, otherArgs);

% There is no data, use the variable names line to create an "all numeric"
% format.
if isempty(dataLine{1}) || isempty(dataLine{1}{1})
    if ~isempty(vnline)
        nvars = countDelimiters(vnline,delimiter, otherArgs)+1;
    else
        nvars = 0;
    end
    if nvars > 0
        format = repmat('%f',1,nvars);
    else
        format = '%*s'; % textscan does not accept an empty format
    end
else
    % Determine the format from the first line of data.
    format = matlab.io.internal.text.determineFormatString(dataLine{1}{1}, ...
        delimiter, whitespace, eol, treatAsEmpty, opts.VariableTypes, datetimetype, durationtype, false, otherArgs);
end
end


%-------------------------------------------------------------------------------
function format = updateFormatGuess(fid,format,delimiter,whitespace,eol,treatAsEmpty,numNonDataLines,datetimetype,durationtype,opts,otherArgs)
% Guess at the format string for the data, based on reading all lines of the
% file.

% Use the existing format as a starting point for the updated guess. We will
% parse each line with a format that reads fields, but generates no output. This
% is a fast way to determine if the format succeeds for a given line. Do this as
% a separate (single) pass through the file before (re)reading the data to avoid
% repeated passes that actually create data that is then thrown away due to
% failed format guesses.
nvars = numel(format)/2;
skipValuesFormat = repmat('%*f', 1, nvars);
skipValuesFormat(3:3:end) = format(2:2:end);

% Read blocks of 100 lines at a time, and keep a count.
blockSize = 100;
blockNum = 0;
while ~feof(fid)
    
    % Read a block of lines from the file as separate strings.
    blockNum = blockNum + 1;
    dataLines = textscanReadLines(fid, blockSize, whitespace, eol, 0, otherArgs);
    dataLines = cellstr(dataLines{1});
    
    if isempty(dataLines), break; end % reached end of file
    
    % Check the current format guess against each line.
    for jj = 1:numel(dataLines)
        
        % The file must be rectangular, with same number of delimiters on every line.
        numDelimiter = countDelimiters(dataLines{jj}, delimiter, otherArgs);
        if numDelimiter ~= nvars-1
            errLine = jj + blockSize*(blockNum-1) + numNonDataLines; % account for nonDataLines not read into rawline
            error(message('MATLAB:readtable:BadFileFormat', errLine, errLine, numDelimiter, nvars-1));
        end
        
        % Parse each line, without actually creating values, to determine if the current
        % format guess works for this line. 'EndOfLine' is not needed, but saves the
        % effort of trying to detect it.
        [~,pos] = textscan(dataLines{jj}, skipValuesFormat, 1, ...
            'Delimiter',delimiter,...
            'Whitespace',whitespace,...
            'TreatAsEmpty',treatAsEmpty,...
            'EndOfLine',eol,...
            otherArgs{:});
        
        % If parsing failed, update the format guess to use %q where %f failed.
        if pos ~= length(dataLines{jj})
            format = matlab.io.internal.text.determineFormatString(dataLines{jj}, ...
                delimiter, whitespace, eol, treatAsEmpty, opts.VariableTypes, datetimetype, durationtype, false, otherArgs, format);
            skipValuesFormat(3:3:end) = format(2:2:end);
        end
        
        % updateFormatGuess does not go back and reparse the entire file again each time
        % a line fails -- only one pass trough the file. As a result, the updated format
        % may fail when we use it to actually read all the data. This happens only in
        % perverse cases where changing %f to %q when a line fails causes textscan to
        % interpret an earlier line differently. For example, although line 2 satisfies
        % the format guessed based on line 1, it does not satisfy the updated format
        % after reacting to line 3:
        %    1, 11, aa, 21, xx 2, 12  bb, 22, yy, 3, EE, cc, 23, zz
    end
end
end


%-------------------------------------------------------------------------------
function delimiter = validateDelims(delimiter)
% Check the delimiter, and convert 'space','comma', etc. into real delimiters.

tab = sprintf('\t');

if ischar(delimiter)
    % Convert aliases to real delimiters.
    switch delimiter
        case {'tab', '\t', tab}
            delimiter = tab;
        case {'space',' '}
            delimiter = ' ';
        case {'comma', ','}
            delimiter = ',';
        case {'semi', ';'}
            delimiter = ';';
        case {'bar', '|'}
            delimiter = '|';
        otherwise
            % Otherwise, pass to textscan.
    end
    delimiter = num2cell(sprintf(delimiter));
end

try
    textscan('a','%*s','Delimiter',delimiter);
    for k = 1:numel(delimiter)
        delimiter{k} = sprintf(delimiter{k});
    end
catch
    error(message('MATLAB:readtable:InvalidDelimiter'));
end
end


%-------------------------------------------------------------------------------
function [lines,pos] = textscanReadLines(fid,N,whitespace,eol,headerlines,otherArgs)
% Read N non-blank lines from the current position in an open file.

% Read each line (defined as "up to an EOL char") into a separate string. This
% will skip any leading or embedded blank lines, where "blank" is defined modulo
% white space. Specifying the EOL flag lets textscan skip over the unconsumed
% EOL chars as blank lines (and saves textscan the bother of figuring out EOL).
% The last EOL will not be consumed, but since textscan skips leading blank
% lines, subsequent calls won't care.
[lines,pos] = textscan(fid, ['%[^' eol ']'], N, 'whitespace',whitespace, ...
    'headerlines',headerlines, 'EndOfLine',eol, otherArgs{:});

end


%-------------------------------------------------------------------------------
function data = textscanReadData(fid,format,delimiter,whitespace,eol,treatAsEmpty,otherArgs)
% Read data from from current position in an open file using a specified format.

% textscan automatically skips blank lines, where "blank" is defined modulo
% white space. Even if there's nothing left in the file, textscan will return
% the right types in data.
data = textscan(fid, format, 'Delimiter',delimiter, 'whitespace',whitespace, ...
    'TreatAsEmpty',treatAsEmpty, 'EndOfLine',eol, otherArgs{:});
end


%-------------------------------------------------------------------------------
function vnline = getVariableNamesLine(inferFormat,fid,whitespace,eol,otherArgs)
% Read in the first line of var names as a single string, skipping header lines.
% This will not skip blank lines that precede the header lines, but will skip
% blank lines that precede the variable names line.
vnline = textscanReadLines(fid, 1, whitespace, eol, 0, otherArgs);
if isempty(vnline{1}) || isempty(vnline{1}{1})
    if inferFormat % empty file
        vnline = [];
        return
    else
        vnline = ' '; % whitespace
    end
else
    vnline = vnline{1}{1};
end
end


%-------------------------------------------------------------------------------
function fid = fopenEnc(file,enc)
if strcmp(enc,'system')
    fid = fopen(file,'rt');% text mode: CRLF -> LF on windows (no-op on linux)
else
    fid = fopen(file,'rt','n',enc); % text mode: CRLF -> LF on windows (no-op on linux)
end
end


%-------------------------------------------------------------------------------
function [fid,file] = openFile(file,enc)
fid = fopenEnc(file,enc);
if fid == -1
    % Try again with default extension if there wasn't one
    [~,~,ext] = fileparts(file);
    if isempty(ext)
        file = [file '.txt'];
        fid = fopenEnc(file,enc);
    end
end
if fid == -1
    error(message('MATLAB:readtable:OpenFailed',file));
end
end


%-------------------------------------------------------------------------------
function validateTextscanParameters(otherArgs)
% ReturnOnError doesn't make sense with READTABLE since it already errors when
% the file fails to parse
id = find(ismember(otherArgs(1:2:end),{'ReturnOnError'}));
if ~isempty(id)
    error(message('MATLAB:table:parseArgs:BadParamName',otherArgs{2*id-1}));
end
if ~isempty(otherArgs)
    try
        % Give error based on whether we have a textscan param, or something completely
        % unknown.
        textscan('a','%*s',otherArgs{:});
    catch ME
        if strcmp(ME.identifier,'MATLAB:textscan:UnknownOption')
            error(message('MATLAB:table:parseArgs:BadParamName',otherArgs{1}));
        end
        % textscan may fail to validate a parameter, throw the appropriate message
        throw(ME);
    end
end
end


%-------------------------------------------------------------------------------
function data = fillShortRows(data,tooShort,len,otherArgs)
% Pass in otherArgs in case EmptyValue is set.
[emptyvalID,emptyNumericValue] = findParamValue('EmptyValue',otherArgs);
if isempty(emptyvalID)
    emptyNumericValue = NaN;
end

% Fill everything else
for colID = find(tooShort)
    if isnumeric(data{colID})
        data{colID}(end+1,:) = emptyNumericValue;
    elseif iscell(data{colID})
        data{colID}(end+1,:) = {''};
    else
        data{colID} = tabular.lengthenVar(data{colID},len);
    end
end
end


%-------------------------------------------------------------------------------
function numDelimiter = countDelimiters(row, delimiter, otherArgs)
fields = textscan([row char(0)], '%q', 'Delimiter', delimiter, otherArgs{:},'CollectOutput',false);
numDelimiter = numel(fields{1})-1;
end

function [id,value] = findParamValue(param,args)
id = find(strcmp(args,param),1,'last');
if ~isempty(id)
    value = args{id+1};
else
    value = [];
end
end


%-------------------------------------------------------------------------------
function reportParamsWithError(ME,detected,delimiter,headerlines,readVarNames,format)
params = matlab.io.text.internal.reportParamsList(detected,delimiter,headerlines,readVarNames,format);
if ~isempty(params)
    msg = matlab.io.internal.utility.unescape(ME.message);
    throw(MException(ME.identifier,[msg '\n\n' getString(message('MATLAB:readtable:ParameterListHeader')) params]));
else
    throw(ME);
end
end
