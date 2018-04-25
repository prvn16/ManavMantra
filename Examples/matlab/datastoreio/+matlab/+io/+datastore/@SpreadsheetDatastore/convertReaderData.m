function data = convertReaderData(ds, numRowsToRead)
%convertReaderData function responsible for conversion

%   Copyright 2015-2016 The MathWorks, Inc.

    % imports
    import matlab.io.spreadsheet.internal.readSpreadsheetFile;

    % setup the options structure.
    rdOpts = getBasicReadOpts(ds, ds.BookObject, ds.SheetObject, false, ds.TextType);

    if nargin < 2
        numRowsToRead = 'sheetOrFile';
    end

    data = table;
    sVarNames = ds.SelectedVariableNames;

    firstIdx = ds.SelectedVariableNamesIdx(1);
    if all(firstIdx:(firstIdx + numel(sVarNames) - 1) == ds.SelectedVariableNamesIdx)
        % If all the SelectedVariableNames are in an increasing order, we can
        % read all the selected variablenames in one swoop using the range for those
        % variable names
        rdOpts.range = getVarRange(ds, ds.SelectedVariableNamesIdx, numRowsToRead);
        out = readSpreadsheetFile(rdOpts);
        data = tableFromCell(out.variables, sVarNames);
        for sVarIdx = 1:numel(sVarNames)
            varName = sVarNames{sVarIdx};
            d = data.(varName);
            varType = ds.SelectedVariableTypes{sVarIdx};
            if ~strcmp(class(d), varType)
                data = convertTableVariableToType(ds, data, d, varName, varType);
            end
        end
    else
        % Make the dimension names unique with respect to the var names, silently
        data.Properties.DimensionNames = matlab.lang.makeUniqueStrings(data.Properties.DimensionNames,sVarNames,namelengthmax);

        % populating the table, taking ordering into account
        for sVarIdx = 1:numel(sVarNames)
            rdOpts.range = getVarRange(ds, ds.SelectedVariableNamesIdx(sVarIdx), numRowsToRead);
            out = readSpreadsheetFile(rdOpts);
            data = convertTableVariableToType(ds, data, out.variables{1}, sVarNames{sVarIdx}, ds.SelectedVariableTypes{sVarIdx});
        end

    end
    if isnumeric(numRowsToRead)
        if numRowsToRead <= ds.NumRowsAvailableInSheet
            ds.CurrRangeVector = ds.CurrRangeVector + [numRowsToRead 0 -numRowsToRead 0];
            ds.NumRowsAvailableInSheet = ds.NumRowsAvailableInSheet - numRowsToRead;
        else
            ds.NumRowsAvailableInSheet = 0;
        end
    end
end

function tblData = convertTableVariableToType(ds, tblData, varData, varName, varType)
%CONVERTTABLEVARIABLETOTYPE This function converts a particular variable type in a table
% to the required type from the SelectedVariableTypes property
    try
        convertedData = convertToType(varData, varType, ds.TextType);
        tblData.(varName) = convertedData;
    catch e
        error(message('MATLAB:datastoreio:spreadsheetdatastore:conversionFail', varName, ds.SheetObject.Name, ds.CurrInfo.Filename, varType));
    end
end

function tblData = tableFromCell(cellArr, sVariableNames)
%TABLEFREOMCELL This function creates a table from the given cell array of data.
% This also resolves any conflict/overlap between VariableNames and the default DimensionNames.
    emptyTempTable = table.empty(0,0);
    % Find if any conflicting variablenames compared to DimensionNames
    conflictingVarNames = ismember(sVariableNames, emptyTempTable.Properties.DimensionNames);

    if any(conflictingVarNames)
        tempSelectedVarNames = sVariableNames;
        % Append '_Temp' to conflicting VariableNames
        tempSelectedVarNames(conflictingVarNames) = cellfun(@(x)[x '_Temp'], sVariableNames(conflictingVarNames), 'UniformOutput', false);
        tblData = table(cellArr{:}, 'VariableNames', tempSelectedVarNames);
        % Make the dimension names unique with respect to the var names, silently
        tblData.Properties.DimensionNames = matlab.lang.makeUniqueStrings(emptyTempTable.Properties.DimensionNames,sVariableNames,namelengthmax);
        % Switch back to original VariableNames from VariableNames with '_Temp' appended to them.
        tblData.Properties.VariableNames(conflictingVarNames) = sVariableNames(conflictingVarNames);
    else
        tblData = table(cellArr{:}, 'VariableNames', sVariableNames);
    end

end

function dataRange = getVarRange(ds, varIdx, numRowsToRead)
%GETVARRANGE This function is responsible for returning the range for the
%selected variable based on its index and the number of rows to read

%    sVarNamesIdx = ds.SelectedVariableNamesIdx;
    readSize = ds.ReadSize;
    dataIdx = find(varIdx(1) == 1:numel(ds.VariableNames));

    % update the dataRange
    dataRange = ds.CurrRangeVector;
    dataRange(4) = numel(varIdx);
    dataRange(2) = dataRange(2) + dataIdx - 1;

    if isnumeric(readSize) && numRowsToRead <= ds.NumRowsAvailableInSheet
        dataRange(3) = numRowsToRead;
    end
end

function data = convertToType(data, type, textType)
%CONVERTTOTYPE This function is responsible for converting data lines to
%the apprpriate types.

    switch type
        case 'double'
            % throw if the data is not double
            switch(class(data))
                case {'string','cell'}
                        data = double(string(data));
                otherwise
                    assert(isa(data, 'double'));
            end
        case 'datetime'
            if isa(data, 'double') && all(isnan(data))
                % If all the values are NaN convert them to NaT
                data = NaT(size(data), 'Format', 'default');
            else
                % force convert data to datetime and error if not possible
                % double data would error here.
                data = datetime(data);
            end
        case 'duration'
            if isa(data, 'double') && all(isnan(data))
                data = duration(data,NaN,NaN); % get NaN as duration
            else
                % If text data, convert to duration via constructor.
                data = duration(data);
            end
        case 'categorical'
            data = categorical(data);
        case 'char'
              if isa(data, 'double')
                  data = strtrim(cellstr(num2str(data)));
              elseif isdatetime(data)
                  data = strrep(cellstr(data), 'NaT', '');
              elseif isequal(textType, 'string')
                  % convert string array to cellstr
                  data = cellstr(data);
              end
        case 'string'
            if isa(data, 'cell') && isequal(textType, 'char')
                % convert cellstr to string array
                data = string(data);
            end
    end
end
