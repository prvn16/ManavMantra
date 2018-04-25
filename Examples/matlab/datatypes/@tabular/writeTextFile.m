function writeTextFile(t,file,args)
%WRITETEXTFILE Write a table to a text file.

% Copyright 2012-2017 The MathWorks, Inc.

% Parse and validate input arguments
import matlab.internal.datatypes.validateLogical

pnames = {'WriteVariableNames' 'WriteRowNames' 'Delimiter' 'QuoteStrings' 'DateLocale' 'Encoding'};
dflts =  {               true           false      'comma'         'auto'           ''   'system'};
[writeVarNames,writeRowNames,delimiter,quoteString,locale,encoding,isSpecified] = matlab.internal.datatypes.parseArgs(pnames, dflts, args{:});

% Only write row names if asked to, and if they exist.
writeParams.writeRowNames = validateLogical(writeRowNames,'WriteRowNames') && t.rowDim.hasLabels;
writeParams.writeVarNames = validateLogical(writeVarNames,'WriteVariableNames');
writeParams.delimiter     = standardizeDelimiter(delimiter);
writeParams.locale        = locale;
if isSpecified.QuoteStrings
    writeParams.quoteString = validateLogical(quoteString,'QuoteStrings');
else % default quoting to automatic detection of embedded delimiter
    writeParams.quoteString = quoteString;
end

% Open the file for writing
if strcmp(encoding,'system')
    [fid,errmsg] = fopen(file,'Wt'); % text mode: CRLF -> LF
else
    [fid,errmsg] = fopen(file,'Wt','n',encoding); % text mode: CRLF -> LF
end

if fid == -1
    error(message('MATLAB:table:write:FileOpenError', file, errmsg));
else
    fileHandleCleanup = onCleanup(@()fclose(fid));
end

% Extract & matricize variables (char arrays are processed to strings)
% and get variable names
adata = cell(1,size(t,2));
for ii = 1 : size(t,2)
    adata{ii} = tabular.writetableMatricize(t.data{ii});
end

avarnames = t.varDim.labels;

% If writing row labels, tack them on up front as for any other variable
if writeParams.writeRowNames
    adata     = [{t.rowDim.labels} adata];
    avarnames = [t.metaDim.labels{1} avarnames];
end

% Get variable traits
varTraits = variableTraits(adata,writeParams);

% Write header if needed
if writeVarNames
    writeHeader(fid, adata, avarnames, writeParams, varTraits);
end

% Write to file
if (t.rowDim.length == 0) || (t.varDim.length == 0)
    % nothing to write
else % write data in chunks
    % If all variables are of the same numeric type, it is faster to write
    % each chunk as a single array (especially for large number of rows)
    numTypes = cellfun(@class, adata, 'UniformOutput', false);
    writeParams.writeChunkAsOneArray = all(varTraits.isNumeric) && isequal(numTypes{1},numTypes{:}); % extract the first element to catch 1-variable case
    
    % Get indices that define the range of each variable pack (the same
    % range applies to all chunks) and varTraits of packed up variables
    packParams = varPackParams(adata, varTraits);
    
    % Estimate number of rows per chunk from size-in-memory of an one row
    % chunk processed the same way as if to be written to file
    if writeParams.writeChunkAsOneArray
        chunkSizeInBytes = 64*2^20; % 64MB
    else
        % if not writing chunk as one array, limit chunk size to 32MB as
        % use of character buffer created from SPRINTF() doubles memory
        % needed to write each chunk
        chunkSizeInBytes = 32*2^20; % 32MB
    end
    nRowsPerChunk = numRowsPerChunk(adata, chunkSizeInBytes, varTraits, packParams, writeParams);
    
    % Loop through chunks
    rowFmt = rowFormat(adata, writeParams.delimiter); % Get format for each row from original table data
    rowStart = 1;
    while rowStart <= t.rowDim.length
        % Extract the raw rows of the table for this chunk
        rowFinish = min([rowStart + nRowsPerChunk - 1, t.rowDim.length]); % end of chunk
        rowChunk  = makeChunk(adata, rowStart, rowFinish);
        
        % Convert chunk into a cell array containing only numbers and
        % strings, in the correct orientation for fprintf() to write out
        % rows of the table
        rowChunk  = processChunk(rowChunk, varTraits, packParams, writeParams);
        
        % Write chunk to file
        if writeParams.writeChunkAsOneArray
            fprintf(fid, rowFmt, rowChunk);
        else % format chunk to character buffer before writing to file
            fprintf(fid, '%s', sprintf(rowFmt, rowChunk{:}));
        end
        
        % update row-index to next chunk
        rowStart = rowFinish + 1;
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN FUNCTION END %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nRowsPerChunk = numRowsPerChunk(data, chunkSizeInBytes, varTraits, packParams, writeParams)
row = makeChunk(data, 1, 1);
row = processChunk(row, varTraits, packParams, writeParams); %#ok<NASGU>: used in WHOS
rowSizeInBytes = getfield(whos('row'), 'bytes'); % size of one row in memory
nRowsPerChunk = ceil(chunkSizeInBytes/rowSizeInBytes); % number of rows, at least one, per chunk
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function delimiter = standardizeDelimiter(delimiter)
tab = sprintf('\t');
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
        throwAsCaller(MException(message('MATLAB:table:write:UnrecognizedDelimiter', delimiter(1))));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varTraits = variableTraits(cellVector, writeParams)
% VARIABLETRAITS returns a varTraits struct with type traits of contents in
% cellVector and number of delimited fields needed to write out content of
% each variable in nVarFields.

    function m = numCellVarFields(c)
        % Number of delimited fields or columns needed to write out the
        % contents of a cell (excluding contents in nested cells)
        if ischar(c)
            % Treat each row as a separate string, including rows in higher dims.
            [n,~,d] = size(c);
            % Each string gets one "column".  Zero rows (no strings) gets a single
            % column to contain the empty string, even for N-D,.  In particular,
            % '' gets one column.
            m = max(n*d,1);
        elseif isnumeric(c) || islogical(c) || iscategorical(c) || isdatetime(c) || isduration(c) || iscalendarduration(c)
            m = max(numel(c),1); % always write out at least one empty field
        else % unsupported types
            m = 1; % write as an empty field
        end
    end

% Table variable traits
nVars = numel(cellVector);
varTraits.nVarFields = cell(1, nVars);
varTraits.quoteVariable = false(1, nVars);
for i = 1:nVars
    x = cellVector{i};
    
    % Table variable type info
    varTraits.isNumeric(i)         = islogical(x) || isnumeric(x);
    varTraits.isCharStrings(i)     = ischar(x) || matlab.internal.datatypes.isCharStrings(x);
    varTraits.isCategorical(i)     = iscategorical(x);
    varTraits.isTime(i)            = isdatetime(x) || isduration(x) || iscalendarduration(x);
    varTraits.isNonStringCell(i)   = iscell(x) && ~varTraits.isCharStrings(i);
    varTraits.isUnsupportedType(i) = ~(varTraits.isNumeric(i) || varTraits.isCharStrings(i) || varTraits.isCategorical(i) || varTraits.isTime(i) || varTraits.isNonStringCell(i));
    varTraits.isSparse(i)          = issparse(x);
    varTraits.isComplex(i)         = isnumeric(x) && ~isreal(x);
    varTraits.isStringType(i)      = isa(x,'string');
    % Number of fields to write from each variable. For regular non-cell
    % variables, number of fields is a scalar; for cell-variable with
    % multiple columns, number of fields is a row-vector with element
    % mapping to each column of the cell.
    if varTraits.isNonStringCell(i)
        % Multiple rows in each cell element are converted to delimited
        % fields. Number of fields for each column of a cell variable thus
        % equals to the maximum number of rows that column.
        varTraits.nVarFields{i} = max(cellfun(@numCellVarFields,x), [], 1);
    else
        varTraits.nVarFields{i} = max(size(x, 2), 1); % always write out at least one empty field
    end
    
    % Quote string/datetime/categorical variables of any embedded delimiter
    % is found in the variable. For cell array of strings, the QuoteStrings
    % flag overrides this automatic detection: string variables are either
    % always or never quoted with QuoteStrings flag equals True/False
    % respectively.
    if (varTraits.isCharStrings(i) || varTraits.isStringType(i) || varTraits.isTime(i) || varTraits.isCategorical(i))
        if strcmp(writeParams.quoteString,'auto')
            
            if varTraits.isStringType(i)
                varTraits.quoteVariable(i) = any(contains(x,writeParams.delimiter));
            else
                if varTraits.isCharStrings(i) % String/Char variable
                    strsToCheck = x; % Add quote if the string variable contains embedded delimiter
                elseif varTraits.isTime(i) % Datetime/Duration/CalendarDuration
                    strsToCheck = {x.Format}; % Add quote if Format contains embedded delimiter
                elseif varTraits.isCategorical(i) % Categorical
                    strsToCheck = categories(x); % Add quote if any category name contains embedded delimiter
                end
                varTraits.quoteVariable(i) = matlab.internal.datatypes.containsCharacter(strsToCheck, writeParams.delimiter);
            end
        else % user specified 'QuoteString' value
            % never add quotes to anything if user set QuoteString as FALSE.
            % always quote string, categorical, datetime if user set to TRUE.
            varTraits.quoteVariable(i) = writeParams.quoteString;
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fmt, fmtCell] = rowFormat(adata, delimiter)
% ROWFORMAT construct fprintf/sprintf format strings to write out contents
% of each cell in cell-vector ADATA.

% Base string and numeric format specifiers
formatBase.string         = ['%s' delimiter];
formatBase.doubleReal     = ['%.15g' delimiter];
formatBase.doubleComplex  = ['%.15g+%.15gi' delimiter];
formatBase.singleReal     = ['%.7g' delimiter];
formatBase.singleComplex  = ['%.7g+%.7gi' delimiter];
formatBase.integerReal    = ['%d' delimiter];
formatBase.integerComplex = ['%d+%di' delimiter];
formatBase.unsignedIntegerReal    = ['%u' delimiter];
formatBase.unsignedIntegerComplex = ['%u+%ui' delimiter];
formatBase.logical        = ['%d' delimiter];

% Construct format specifier for each variable
fmtCell = cell(size(adata)); % pre-allocate
for i = 1:numel(adata)
    % get field name into formatBase struct
    x = adata{i};
    if isnumeric(x)
        % class base
        if isinteger(x)
            if startsWith(class(x),'u')
                fmtField = 'unsignedInteger';
            else
                fmtField = 'integer';
            end
        else % single or double
            fmtField = class(x);
        end
        
        % tag on complexity
        if isreal(x)
            fmtField = [fmtField 'Real']; %#ok<AGROW>
        else
            fmtField = [fmtField 'Complex']; %#ok<AGROW>
        end
    elseif islogical(x)
        fmtField = 'logical';
    else % isCharStrings(i) || isCategorical(i) || isTime(i) || isNonStringCell(i) || isUnsupportedType(i)
        fmtField = 'string'; % other supported types are written out as strings
    end
    
    % construct the full format specification for this variable
    fmtCell{i} = repmat(formatBase.(fmtField),1,size(x,2));
end

% Merge all format specifiers into one
fmt = [fmtCell{:}];
fmt = [fmt(1:end-length(delimiter)) '\n']; % Remove trailing delimiter at end of row and add newline
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rowChunk = makeChunk(data, rowStart, rowFinish)
% MAKECHUNK extracts a 1-by-NVars cell that contains chunk of rows from
% rowStart to rowFinish from each variable
rowChunk = cell(size(data)); % initialize rowChunk
for i = 1:numel(rowChunk)
    rowChunk{i} = data{i}(rowStart:rowFinish,:);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rowChunk = processChunk(rowChunk, varTraits, packParams, writeParams)
% standardize numerics to be compatible with fprintf()
for i = find(varTraits.isNumeric)
    rowChunk{i} = standardizeNumericVar(rowChunk{i}, varTraits.isComplex(i), varTraits.isSparse(i));
end

% Combine adjacent cell of matching supported types
rowChunk = packVariables(rowChunk, packParams);

if writeParams.writeChunkAsOneArray
    % If writeChunkAsOneArray is true, rowChunk is a 1x1 cell
    % containing all variables in this chunk packed in one array.
    rowChunk = rowChunk{1}'; % transpose for fprintf()
else
    % Get 1-by-NVars cell arrays with either numerics or cellstrs
    resolveCell = true; % resolve and expand non-string cell variables
    rowChunk = stringify(rowChunk, writeParams, packParams.varTraitsPacked, resolveCell);
    
    % merge 1-by-NVars cell containing chunkNRows-by-... cell arrays
    % into a chunkNRows-by-NFields cell & transpose for fprintf()
    rowChunk = [rowChunk{:}]';
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function writeHeader(fid, data, varnames, writeParams, varTraits)
% WRITEHEADER writes a header line with names for each delimited fields.
% Multiple columns variables are written as multiple delimited fields.

    function varnamej = colHeaders(varj, varnamej, ncellColsj)
        %COLHEADERS Create multiple column headers from a table variable name
        
        % Need multiple column headers if the variable has multiple columns.
        if ischar(varj)
            [~,~,ncols] = size(varj);
        else
            [~,ncols] = size(varj); % Treat N-D as 2-D.
        end
        if ncols > 1
            varnamej = matlab.internal.datatypes.numberedNames([varnamej{:},'_'],1:ncols);
        end
        
        % Need multiple column headers if the variable is a non-string cell
        % containing non-scalars.
        if iscell(varj) && ~matlab.internal.datatypes.isCharStrings(varj) && any(ncellColsj(:) > 1)
            vnj = cell(1,sum(ncellColsj));
            cnt = 0;
            for ii = 1:ncols
                num = ncellColsj(ii);
                vnj(cnt+(1:num)) = matlab.internal.datatypes.numberedNames([varnamej{ii},'_'],1:num);
                cnt = cnt + num;
            end
            varnamej = vnj;
        end
    end % colHeaders function

% Get header for each variables
varHeaders = cell(size(varnames));
for i = 1:length(varHeaders)
    varHeaders{i} = colHeaders(data{i}, varnames(i), varTraits.nVarFields{i});
end

% Write out the header line
varHeaders = [varHeaders{:}];
headerFmt  = [strjoin(repmat({'%s'},1,length(varHeaders)), writeParams.delimiter), '\n'];
fprintf(fid,headerFmt,varHeaders{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function numericVar = standardizeNumericVar(numericVar, isVarComplex, isVarSparse)
% expand sparse matrix in full
if isVarSparse
    numericVar = full(numericVar);
end
% fprintf()/sprintf() does not write complex numbers. Convert to 2-element
% vector of real and imaginery part for writing
if isVarComplex
    numericVar = [real(numericVar), imag(numericVar)];
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function packParams = varPackParams(v, varTraits)
% variablePackIdx returns index vectors packStart and packFinish that
% together define groups of adjacent variables in cell-vector v that have
% the same kind (type, timezone, display format etc.) of supported datatypes
% (numerics, datetime, duration, calendarDuration, categorical).

% Get index of unique types (including timezone, format etc.)
varTypes = cell(1, numel(v));
for i = 1:numel(v)
    x = v{i};
    varTypes{i} = class(x);
    
    % datetime, duration or calendarDuration
    if varTraits.isTime(i)
        % treat time variables with different formats as different types so
        % they are not packed together
        varTypes{i} = [varTypes{i}, '_', x.Format];
        
        % treat datetime with different timezones as different types so they
        % are not packed together into a single datetime array
        if isdatetime(x)
            varTypes{i} = [varTypes{i}, '_', x.TimeZone];
        end
    end
end
[~, ~, idxVarType] = unique(varTypes,'stable');

% Type mask to perform packing on - force to be column. Only pack numeric,
% datetime, duration, calendarDuration or categorical variables.
isToPack = varTraits.isNumeric(:) | varTraits.isTime(:);

% Pack categorical variables only if they all have the same categories.
% Categorical variables with different categories are more time-consuming
% to concatenate and thus are not packed.
if (nnz(varTraits.isCategorical) > 1) % more than one categorical
    catVarIdx = find(varTraits.isCategorical);
    categoriesList = categories(v{catVarIdx(1)});
    packCategorical = true;
    for i = catVarIdx(2:end)
        if ~isequal(categories(v{i}), categoriesList)
            packCategorical = false;
            break;
        end
    end
    
    if packCategorical
        isToPack = isToPack | varTraits.isCategorical(:);
    end
end

% Find start and finish of each matching datatype
uniquePackStartMask   = diff( [0; idxVarType] ) ~= 0;
uniquePackFinishMask  = diff( [idxVarType; 0] ) ~= 0;
packParams.start  = find(uniquePackStartMask & isToPack);
packParams.finish = find(uniquePackFinishMask & isToPack);

% Return varTraits when adjacent variables of the same type are packed as one
varTraitFields = fieldnames(varTraits);
for i=1:numel(varTraitFields)
    varTraits.(varTraitFields{i}) = varTraits.(varTraitFields{i})(uniquePackStartMask | ~isToPack);
end
packParams.varTraitsPacked = varTraits;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function v = packVariables(v, packParams)
%  packVariables(v) packs cell vector v by concatenating range of cells
%  defined by index vectors packStart and packFinish into consolidated
%  nRows-by-1 cells.
packStart  = packParams.start;
packFinish = packParams.finish;
for ii = numel(packStart):-1:1 % work backwards to cope with removal
    v{packStart(ii)} = [v{packStart(ii):packFinish(ii)}]; % concatenate
    v(packStart(ii)+1:packFinish(ii)) = []; % remove
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rowChunk = stringify(rowChunk, writeParams, varTraits, resolveCell)
nRows = size(rowChunk{1},1);
numericVarBuf = cell(nRows, 1);
for ii = 1:numel(rowChunk)
    % keep track of which strings are missing so we don't put double quotes
    % around them later
    missingStrings = false(size(rowChunk{ii}));
    if varTraits.isNumeric(ii)
        % wrap each row in cell and delegate to fprintf for formatting
        for jj = 1:nRows
            numericVarBuf{jj} = rowChunk{ii}(jj,:); % equivalent to NUM2CELL(rowChunk{ii},2) but faster
        end
        rowChunk{ii} = numericVarBuf;
    elseif varTraits.isCategorical(ii)
        rowChunk{ii} = cellstr(rowChunk{ii});
    elseif varTraits.isStringType(ii)
        strchunk = rowChunk{ii};
        % replace all missing values with empty chars
        missingStrings = ismissing(strchunk);
        strchunk(missingStrings) = '';
        rowChunk{ii} = cellstr(strchunk);
    elseif varTraits.isTime(ii)
        rowChunk{ii} = cellstr(rowChunk{ii},[],writeParams.locale);
    elseif varTraits.isUnsupportedType(ii)
        rowChunk{ii} = repmat({''}, nRows, 1);
    elseif varTraits.isNonStringCell(ii)
        if resolveCell
            rowChunk{ii} = stringify_cell(rowChunk{ii}, varTraits.nVarFields{ii}, writeParams);
        else
            rowChunk{ii} = repmat({''}, nRows, 1);
        end
    end
    
    % Add quotes to stringified variable if needed
    if varTraits.quoteVariable(ii) && ~isempty(rowChunk{ii})
        if ischar(rowChunk{ii}{1})
            rowChunk{ii}(~missingStrings) = strcat('"',strrep(rowChunk{ii}(~missingStrings),'"','""'),'"');
        else
            rowChunk{ii} = num2cell(strcat('"',strrep([rowChunk{ii}{:}],'"','""'),'"'))';
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cellVar = stringify_cell(cellVar, nFields, writeParams)
% STRINGFY_CELL formats and converts content of each row of a cell array
% into a single delimited string.

% The STRINGIFY helper function assumes row cell vector. Stretch cell
% variable out to a 1-by-numel(cellVar) cell to facilitate the call
[nCellRows, nCellCols] = size(cellVar); % cache the shape for reconstruction at the end
cellVar = cellVar(:)';

% Matricize elements in cellVar (char arrays are processed to strings)
% as subsequent processing assumes 2D content in the cells.
cellVar = cellfun(@tabular.writetableMatricize,cellVar,'UniformOutput',false);

% variable traits of contents in this cell
varTraits = variableTraits(cellVar, writeParams);

% get format specifier for each cell
[~, fmtCell] = rowFormat(cellVar, writeParams.delimiter);


% process strings and numerics
for i = 1:numel(cellVar)
    % pre-process: matricize char array and stringify numerics
    if varTraits.isNumeric(i)
        % standardize numerics to be compatible with sprintf()
        cellVar{i} = standardizeNumericVar(cellVar{i}, varTraits.isComplex(i), varTraits.isSparse(i));
        
        % convert numerics into cell array of strings with respective
        % format specifiers
        fmt = strtok(fmtCell{i}, writeParams.delimiter);
        cellVar{i} = sprintfc(fmt, cellVar{i});
        
        % the numeric have been converted to cellstrs
        varTraits.isNumeric(i) = false;
        varTraits.isString(i)  = true;
    end
end

% convert non-numerics into cell array of strings
resolveCell = false; % do not further resolve nested cells
cellVar = stringify(cellVar, writeParams, varTraits, resolveCell);

% Content of each cell is linearly indexed out as delimited fields in
% each table row. Since each table row must have the same number of
% fields, rows with fewer fields need to be pad up with empty fields.
% The correct number of fields for each cell column is passed in
% (nFields). Compute the number of empty fields to pad with respect to
% number of elements in each cell.
nFieldsCells = cellfun(@(x)max(numel(x),1),cellVar); % number of fields (at least one) in each cell
nPadFields = max(repelem(nFields,nCellRows)-nFieldsCells, 0);

% reshape back to the original number of rows
cellVar = reshape(cellVar, nCellRows, nCellCols);
for i = 1:numel(cellVar)
    % Combine multiple fields in each table row into one row with delimiters
    cellVar{i} = strjoin(cellVar{i}, writeParams.delimiter);
    
    % Pad each cell content with required number of empty fields (i.e. nPadFields)
    cellVar{i} = [cellVar{i}, repmat(writeParams.delimiter,1,nPadFields(i))];
end
end
