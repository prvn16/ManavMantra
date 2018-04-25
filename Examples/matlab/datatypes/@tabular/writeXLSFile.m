function writeXLSFile(t,filename,ext,args)
%WRITEXLSFILE Write a table to an Excel spreadsheet file.

%   Copyright 2012-2016 The MathWorks, Inc.

[writeVarNames,writeRowNames,sheetName,range,locale] = getArgs(t,args);

book = createWorkbook(filename, ext, true);
if book.AreDates1904
    dateOrigin = '1904';
else
    dateOrigin = '1900';
end

sheetObj = getSheetFromBook(book, sheetName);

[row1, col1, row2, col2, truncateColumns, truncateRows] = parseRange(range, sheetObj, t);

% Determine the maximum number of columns we can write
if truncateColumns
    maxCol = col2;
else
    maxCol = Inf;
end

% How many rows are we supposed to write.
if truncateRows && (row2 - row1 + 1 <= t.rowDim.length)
    dataHeight = row2 - row1 + 1 - writeVarNames;
else
    dataHeight = t.rowDim.length;
end

vars = cell(dataHeight + writeVarNames, 0);

% Write row names.
if writeRowNames
    rownames = t.rowDim.labels(1:dataHeight);
    if writeVarNames
        rownames = [t.metaDim.labels{1}; rownames];
    end
    vars = [vars rownames];
end

import matlab.internal.datatypes.matricize
cells = {};
colCount = col1;
for j = 1:t.varDim.length
    if colCount > maxCol, break; end
    
    varnamej = t.varDim.labels{j};
    
    if dataHeight > 0
        varj = t.data{j};
        varj = extractVarChunk(varj, 1, dataHeight);
        
        if iscell(varj)
            % xlswrite cannot write out non-scalar-valued cells -- convert cell
            % variables to a cell of the appropriate width containing only
            % scalars.
            [~,ncols] = size(varj); % Treat N-D as 2-D
            ncellColsj = max(cellfun(@ncolsCell,matricize(varj)),[],1);
            newNumCols = sum(ncellColsj);
            newVarj = cell(dataHeight,newNumCols);

            % Expand out each column of varj into as many columns as needed to
            % have only scalar-valued cells, possibly padded with empty cells.
            cnt = 0;
            for jj = 1:ncols
                varjj = varj(:,jj);
                num = ncellColsj(jj);
                newVarjj = cell(dataHeight,num);
                for i = 1:dataHeight
                    % Expand each cell with non-scalar contents into a row of cells containing scalars
                    varjj_i = varjj{i};
                    if ischar(varjj_i)
                        % Put each string into its own cell.  If there are no
                        % strings (zero rows or zero pages in the original char
                        % array), the output will be a single empty cell.
                        vals = char2cell(varjj_i); % creates a 2-D cellstr
                        if isempty(vals), vals = {''}; end
                    elseif isstring(varjj_i)
                        vals = num2cell(varjj_i);
                    elseif isnumeric(varjj_i)
                        if isreal(varjj_i)
                            vals = num2cell(varjj_i);
                        else
                            vals = num2cell(real(varjj_i));
                        end
                    elseif islogical(varjj_i)
                        vals = num2cell(varjj_i);
                    elseif isa(varjj_i,'categorical')
                        vals = strrep(cellstr(varjj_i),'<undefined>','');
                    elseif isa(varjj_i,'duration') || isa(varjj_i,'calendarDuration')
                        vals = strrep(cellstr(varjj_i,[],locale),'NaN','');
                    elseif isa(varjj_i,'datetime')
                        if any(exceltime(varjj_i, dateOrigin) < 0)
                            vals = cellstr(varjj_i,[],locale);
                        else
                            % datetimes are represented as complex numbers in C++. The
                            % signals libmwspreadsheet that the data is a datetime and
                            % should be treated as such.
                            vals = arrayfun(@(x){complex(x,0)},exceltime(varjj_i));
                        end
                    else
                        vals = cell(0,0); % write out only an empty cell
                    end
                    newVarjj(i,1:numel(vals)) = vals(:)';
                end
                newVarj(:,cnt+(1:num)) = newVarjj;
                cnt = cnt + num;
            end

            varj = newVarj;
        else
            % xlswrite will convert any input to cell array anyway, may as well do
            % it here in all cases to get correct behavior for character and for
            % cases xlswrite won't handle.
            if ischar(varj)
                varj = char2cell(varj);
            elseif isstring(varj)
                varj = num2cell(varj);
            elseif isnumeric(varj)
                if isreal(varj)
                    varj = num2cell(varj);
                else
                    varj = num2cell(real(varj));
                end
            elseif islogical(varj)
                varj = num2cell(matricize(varj));
            elseif isa(varj,'categorical')
                varj = strrep(cellstr(matricize(varj)),'<undefined>','');
            elseif isa(varj,'duration') ||  isa(varj,'calendarDuration')
                varj = strrep(cellstr(matricize(varj),[],locale),'NaN','');
            elseif isa(varj,'datetime')
                if any(exceltime(varj, dateOrigin) < 0)
                    varj = cellstr(matricize(varj),[],locale);
                else
                    % datetimes are represented as complex numbers in C++. The
                    % signals libmwspreadsheet that the data is a datetime and
                    % should be treated as such.
                    varj = arrayfun(@(x){complex(x,0)},exceltime(varj));
                end
            else % write out empty cells
                varj = cell(dataHeight,1);
            end
        end
    else
        varj = cell(0, 1);
    end

    [~,ncols] = size(varj); % Treat N-D as 2-D
    if writeVarNames
        if ncols > 1
            varj = [strcat({varnamej},'_',num2str((1:ncols)'))'; varj]; %#ok<AGROW>
        else
            varj = [{varnamej}; varj]; %#ok<AGROW>
        end
    end
    vars = [vars varj]; %#ok<AGROW>
    colCount = colCount + ncols;
    cells = [cells vars]; %#ok<AGROW>
    vars = cell(dataHeight + writeVarNames,0);
end

% in case matricizing grew it beyond the bounds we care to write
[~, numCols] = size(cells);
if truncateColumns
    endCol = min(col2 - col1 + 1, numCols);
    cells = cells(:,1:endCol);
end

% validate the range by trying to get the range to write to. if it is
% beyonds the edges, the call to getRange() will throw
try
    [hght, wdth] = size(cells);
    writeRng = [row1, col1, hght, wdth];
    sheetObj.getRange(writeRng);
catch% only one thing could go wrong, we are using a numeric range
    throwTooBigForFormatError(book.Format, writeRng);
end

% Prior to writing, unmerge all the cells in the range
% Writing to merged cells will drop the 2nd->Nth items in the range
% without error.
sheetObj.unmerge(writeRng);

try
    sheetObj.write(cells, writeRng);
catch ME
    if strcmp(ME.identifier, 'MATLAB:spreadsheet:sheet:failedWrite')
        error(message('MATLAB:table:write:FailedWrite', sheetObj.Name, filename));
    else
        throw(ME);
    end
end

sheetObj.autoFitColumns(writeRng);

try
    book.save(filename);
catch ME
    if ispc && strcmp(ME.identifier, 'MATLAB:spreadsheet:book:save') ...
        && exist(filename, 'file')
        error(message('MATLAB:table:write:FileOpenInAnotherProcess', filename));
    else
        throw(ME);
    end
end

end % writeXLSFile function

%--------------------------------------------------------------------------
function [writeVarNames,writeRowNames,sheet,range,locale] = getArgs(t,args)
import matlab.internal.datatypes.validateLogical

pnames = {'WriteVariableNames' 'WriteRowNames' 'Sheet' 'Range' 'DateLocale'};
dflts =  { true                 false           1      'A1'    'system'};

[writeVarNames,writeRowNames,sheet,range,locale] ...
                   = matlab.internal.datatypes.parseArgs(pnames, dflts, args{:});
               
writeRowNames = validateLogical(writeRowNames,'WriteRowNames');
writeVarNames = validateLogical(writeVarNames,'WriteVariableNames');

% Only write row names if asked to, and if they exist.
writeRowNames = (writeRowNames && t.rowDim.hasLabels);
end

%--------------------------------------------------------------------------
function sheetObj = getSheetFromBook(book, sheet)
try
    sheetObj = book.getSheet(sheet);
catch ME
    if strcmp(ME.identifier, 'MATLAB:spreadsheet:book:openSheetName')
        % Add the sheet with the name provided.
        sheetObj = book.addSheet(sheet);
    elseif strcmp(ME.identifier, 'MATLAB:spreadsheet:book:openSheetIndex')
        % Add blank sheets leading up to the index specified.
        nSheets = size(book.SheetNames);
        blanksToAdd = sheet - nSheets - 1;
        
        % If blanksToAdd <= 0, we do nothing
        for i = 1:blanksToAdd
            sheetNum = nSheets + i;
            book.addSheet(['Sheet' num2str(sheetNum)], sheetNum);
        end
        
        % Add a new sheet using Excel's sheet naming convention at the
        % specified index.
        sheetObj = book.addSheet(['Sheet' num2str(sheet)], sheet);
    else
        rethrow(ME);
    end
    % Use the same warning xlswrite does.
    warning(message('MATLAB:xlswrite:AddSheet'));
end
end

%--------------------------------------------------------------------------
function [row1, col1, row2, col2, truncateColumns, truncateRows] = parseRange(range, sheet, t)
% Transform the range into one we can parse using the spreadsheet
% library.
try
    if ~ischar(range)
        % Only accept non-numeric ranges
        error(message('MATLAB:table:write:InvalidRange'));
    end
    
    % Get the numeric representation of the range, and the range type.
    [numRange, rangetype] = sheet.getRange(range, false);
    
    % Assign output variables.
    row1 = numRange(1);
    col1 = numRange(2);
    row2 = row1 + numRange(3) - 1;
    col2 = col1 + numRange(4) - 1;
    
    switch rangetype
        case {'two-corner', 'named'}
            truncateColumns = true;
            truncateRows = true;
        case 'single-cell'
            truncateColumns = false;
            truncateRows = false;
        case 'column-only'
            row1 = 1;
            row2 = t.rowDim.length;
            truncateColumns = true;
            truncateRows = false;
        case 'row-only'
            col1 = 1;
            col2 = t.varDim.length;
            truncateColumns = false;
            truncateRows = true;
        otherwise
            truncateColumns = true;
            truncateRows = true;
    end
 
catch ME
    if strcmp(ME.identifier, 'MATLAB:spreadsheet:sheet:rangeParseInvalid')
        % Throw our own range validation error.
        error(message('MATLAB:table:write:InvalidRange'));
    else
        % If we get an unexpected error, rethrow it.
        rethrow(ME);
    end
end
end

%--------------------------------------------------------------------------
function book = createWorkbook(filename, ext, interactive)
% If the workbook exists, open it.  Otherwise create a new workbook.
if exist(filename, 'file')
    try
        book = matlab.io.spreadsheet.internal.createWorkbook(ext, filename, interactive);
    catch ME
        if strcmp(ME.identifier, 'MATLAB:spreadsheet:book:fileOpen')
            % The file exists but is invalid or encrypted with a password.
            error(message('MATLAB:table:write:CorruptOrEncrypted', filename));
        else
            throw ME;
        end
    end
else % The file doesn't exist so we need to create one.
    book = matlab.io.spreadsheet.internal.createWorkbook(ext, [], interactive);
    % Create the default second and third sheets that Excel gives us.
    book.addSheet('Sheet2', 2);
    book.addSheet('Sheet3', 3);
end
end

%--------------------------------------------------------------------------
function m = ncolsCell(c)
% How many columns will be needed to write out the contents of a cell?
if ischar(c)
    % Treat each row as a separate string, including rows in higher dims.
    [n,~,d] = size(c);
    % Each string gets one "column".  Zero rows (no strings) gets a single
    % column to contain the empty string, even for N-D,.  In particular,
    % '' gets one column.
    m = max(n*d,1);
elseif isnumeric(c) || islogical(c) || isa(c,'categorical')
    m = max(numel(c),1); % always write out at least one empty field
else
    m = 1; % other types are written as an empty field
end
end


%--------------------------------------------------------------------------
function cs = char2cell(c)
% Convert a char array to a cell array of strings, each cell containing a
% single string.  Treat each row as a separate string, including rows in
% higher dims.

% Create a cellstr array the same size as the original char array (ignoring
% columns), except with trailing dimensions collapsed down to 2-D.
[n,~,d] = size(c); szOut = [n,d];

if isempty(c)
    % cellstr would converts any empty char to {''}.  Instead, preserve the
    % desired size.
    cs = repmat({''},szOut);
else
    % cellstr does not accept N-D char arrays, put pages as more rows.
    if ~ismatrix(c)
        c = permute(c,[2 1 3:ndims(c)]);
        c = reshape(c,size(c,1),[])';
    end
    cs = reshape(num2cell(c,2),szOut);
end
end

%--------------------------------------------------------------------------
function varChunk = extractVarChunk(var, rowStart, rowFinish)
    if ischar(var)
        % Turn ND char array into 3D
        varChunk = var(rowStart:rowFinish, :, :);
        % 'Matricize' 3D char into 2D
        [n,m,d] = size(varChunk);
        if d > 1
            varChunk = permute(varChunk,[1 3:ndims(varChunk) 2]);
            varChunk = reshape(varChunk,[n*d,m]);
        end
        varChunk = reshape(num2cell(varChunk,2), [n d]);
    else % 2D indexing automatically 'matricize' ND non-char arrays
        varChunk = var(rowStart:rowFinish, :);
    end
end

%--------------------------------------------------------------------------
function throwTooBigForFormatError(fmt, writerng)
    % We only care about the size limits of the given format. We don't want
    % to start Excel, so if the format is XLSB, use XLSX since they are the
    % same size.
    if strcmpi(fmt, 'xlsb')
        fmt = 'xlsx';
    end
    % create a non-interactive book
    b = matlab.io.spreadsheet.internal.createWorkbook(fmt, [], false);
    s = b.getSheet(1);
    
    maxColsRange = s.getRange('1:1', false);
    maxRowsRange = s.getRange('A:A', false);
    maxrange = [maxRowsRange(3), maxColsRange(4)];
    writerngRC = writerng(1:2) + writerng(3:4) - 1;
    
    exceedsByRC = max(writerngRC - maxrange, [0 0]);
    
    writeStartCell = s.getRange([writerng(1) writerng(2) 1 1]);
    error(message('MATLAB:table:write:DataExceedsSheetBounds', writeStartCell, exceedsByRC(1), exceedsByRC(2)));
end
