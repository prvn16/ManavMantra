% Copyright 2011-2015 The MathWorks, Inc.

%   This class is unsupported and might change or be removed without
%   notice in a future version.

classdef AbstractSpreadsheet < handle & JavaVisible
    properties(SetAccess = protected)
        FileName;
        WorksheetStructure;
    end
    
    
    properties (Hidden=true, SetAccess = protected)
        HasFile = false;
        ErrorOccurred = false;
    end
    
    properties(SetAccess = protected, GetAccess = public)
        DstWorkspace = 'caller';
    end
     
    methods 
        function setDstWorkspace(obj,newWksp)
            obj.DstWorkspace = newWksp;
        end
        
        function [data, dateData, raw] = ImportDataBlock(obj, sheetname, range, selectedExcludedColumns, useValue2)
            import com.mathworks.mlwidgets.importtool.*;
            
            if nargin<=3
                [data,raw,dateData] = Read(obj, sheetname, range);
            else
                % If we're checking for dates (useValue2 is set), then use
                % datetimes.
                datesAsDatetime = true;
                [data,raw,dateData] = Read(obj, sheetname, range, ...
                    useValue2, datesAsDatetime);
            end
            
            % Non empty data must be converted to DateCells.
            if any(useValue2) && ~isempty(dateData)
                if ~isempty(selectedExcludedColumns)                   
                    % Exclude cell array columns from data conversion
                    raw = reshape(raw,size(data));
                    rawNumeric = raw(:,~selectedExcludedColumns);
                    dateDataNumeric = dateData(:,~selectedExcludedColumns);
                    if ~isempty(dateDataNumeric) && ~isempty(rawNumeric)
                         rawNumeric  = cell(com.mathworks.mlwidgets.importtool.DateCell.addDateCells(rawNumeric(:),dateDataNumeric(:)));
                    end
                    % Overwrite raw data with converted dates in numeric
                    % columns.
                    raw(:,~selectedExcludedColumns) = reshape(rawNumeric,size(raw(:,~selectedExcludedColumns)));
                    raw = raw(:);
                else
                    raw = cell(com.mathworks.mlwidgets.importtool.DateCell.addDateCells(raw(:),dateData(:)));
                end
            end            
        end
        
        function [raw,data,dates,varNames,columnTargetTypes,columnVarNames] = ImportSheetData(obj, ...
                varNames, sheetname, range, rules, columnTargetTypes, columnVarNames)
            %IMPORTSHEETDATA
            %
            import com.mathworks.mlwidgets.importtool.*;
            
            % Create default excluded column arrays for range blocks
            haveColumnTypeData = ~isempty(columnTargetTypes);
            if ~haveColumnTypeData
                columnTargetTypes = repmat({repmat({''},size(range{1}))},size(range));
            end

            % ImportData returns the names of variables and their sizes
            % which have not been excluded as a result of the application
            % of a column exclusion rule.
           
            % Set useValue2 to true for columns which are set to datetime
            % or timeseries.  Reevaluate this for each block of data 
            useValue2 = internal.matlab.importtool.AbstractSpreadsheet.isDatetimeOrTimeseriesColumn(...
                columnTargetTypes, 1, 1);
            
            % The Read method and xlsread only work on one contiguous 
            % block. Loop through each contiguous block in the range 
            % cell array building up the combined arrays "data" and "raw"
            excludedColumns = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                columnTargetTypes{1}{1},'CELL_ARRAY');
            
            [blockData, blockDates, blockRaw]  = ImportDataBlock(obj, sheetname, ...
                char(range{1}{1}),excludedColumns,useValue2);
            blockRaw = reshape(blockRaw,size(blockData)); 
            for colBlock = 2:length(range{1})
                %excludedColumns = strcmp(columnTargetTypes{1}{colBlock},'targettype.cellarrays');
                excludedColumns = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                    columnTargetTypes{1}{colBlock},'CELL_ARRAY');
                useValue2 = internal.matlab.importtool.AbstractSpreadsheet.isDatetimeOrTimeseriesColumn(...
                    columnTargetTypes, 1, colBlock);
                 [blockData_, blockDates_, blockRaw_]  = ImportDataBlock(obj, sheetname, ...
                    char(range{1}{colBlock}),excludedColumns,useValue2);
                  blockRaw_ = reshape(blockRaw_,size(blockData_));
                  blockData = [blockData blockData_]; %#ok<AGROW>
                  blockDates = [blockDates blockDates_]; %#ok<AGROW>
                  blockRaw = [blockRaw blockRaw_]; %#ok<AGROW>
            end
            data = blockData;
            dates = blockDates;
            raw = blockRaw;            
            for rowBlock = 2:length(range)
                %excludedColumns = strcmp(columnTargetTypes{rowBlock}{1},'targettype.cellarrays');
                excludedColumns = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                    columnTargetTypes{rowBlock}{1},'CELL_ARRAY');
                useValue2 = internal.matlab.importtool.AbstractSpreadsheet.isDatetimeOrTimeseriesColumn(...
                    columnTargetTypes, rowBlock, 1);
                [blockData, blockDates, blockRaw]  = ImportDataBlock(obj, sheetname, ...
                    char(range{rowBlock}{1}),excludedColumns,useValue2);
                blockRaw = reshape(blockRaw,size(blockData)); 
                for colBlock = 2:length(range{1})
                    %excludedColumns = strcmp(columnTargetTypes{rowBlock}{colBlock},'targettype.cellarrays');
                    excludedColumns = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                        columnTargetTypes{rowBlock}{colBlock},'CELL_ARRAY');
                    useValue2 = internal.matlab.importtool.AbstractSpreadsheet.isDatetimeOrTimeseriesColumn(...
                        columnTargetTypes, rowBlock, colBlock);
                     [blockData_,blockDates_,blockRaw_]  = ImportDataBlock(obj, sheetname, ...
                        char(range{rowBlock}{colBlock}),excludedColumns,useValue2);
                      blockRaw_ = reshape(blockRaw_,size(blockData_));
                      blockData = [blockData blockData_]; %#ok<AGROW>
                      blockDates = [blockDates blockDates_]; %#ok<AGROW>
                      blockRaw = [blockRaw blockRaw_]; %#ok<AGROW>
                end
                data = [data;blockData]; %#ok<AGROW>
                raw = [raw;blockRaw]; %#ok<AGROW>
                
                % combine the dates array so that the datetimes are
                % together in a single datetime array
                dates = cellfun(@(x,y) [x; y], dates, blockDates, 'UniformOutput', false);
            end
            
            columnTargetTypes = [columnTargetTypes{1}{:}]; % Columns from top line of contiguous blocks

            % collapse any string or categorical columns into their correct
            % types
            strOrCatColIndices = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                columnTargetTypes, 'TEXT_OR_CATEGORICAL_ARRAY');
            if any(strOrCatColIndices)
                cols = find(strOrCatColIndices);
                for n = cols
                    empties = cellfun('isempty', raw(:, n));
                    raw(empties, n) = {nan};
                    raw{1, n} = string(raw(:,n));
                    raw(2:end, n) = {[]};
                end
            end
            
            %Apply post-processing rules to columns.
            %
            %Check columns for cell arrays that must be excluded from rule
            %processing.
            %cols = strcmp(cols,'targettype.cellarrays');
            cols = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                columnTargetTypes, 'TEXT_CELL_OR_CATEGORICAL_ARRAY');
            if any(cols) % Column exclusion input defined
                raw = reshape(raw,size(data));
                if ~isempty(columnVarNames)
                    [rawPostRules,~,ruleExcludedRows,ruleExcludedColumns] = internal.matlab.importtool.AbstractSpreadsheet.applyRules(...
                        rules,raw(:,~cols),data(:,~cols),dates(:,~cols),columnVarNames(~cols));
                else
                    [rawPostRules,~,ruleExcludedRows,ruleExcludedColumns] = internal.matlab.importtool.AbstractSpreadsheet.applyRules(...
                        rules,raw(:,~cols),data(:,~cols),dates(:,~cols),varNames(~cols));
                end
                %raw(ruleExcludedRows,:) = [];
                
                if any(ruleExcludedRows)
                    if any(strOrCatColIndices)
                        strOrCatCols = find(strOrCatColIndices);
                        for n = strOrCatCols
                            raw{1,n}(ruleExcludedRows) = [];
                        end
                    end
                    %raw(excludedRows,:) = [];
                    %raw{excludedRows, ~strOrCatColIndices} = [];
                    
                    % Need to process row exclusions such that the
                    % excluded rows are essentially removed
                    tmpRaw = raw(:, ~strOrCatColIndices);
                    % process the excluded rows
                    tmpRaw(ruleExcludedRows,:) = [];
                    sz = size(tmpRaw, 1);
                    
                    % grow the cell array with empties for the
                    % assignment, and assign back to raw
                    tmpRaw{size(raw,1), 1} = [];
                    raw(:, ~strOrCatColIndices) = tmpRaw;
                    
                    % now remove the empty rows entirely
                    raw(sz+1:end, :) = [];
                end
                    
                                    
                
                % If columns are excluded as a result of applying a
                % column exclusion rule, remove those columns from the
                % raw array and varNames
                if any(ruleExcludedColumns)
                    I = find(~cols); % Indices of numeric cols

                    %Remove excluded columns from the data
                    data(:,I(ruleExcludedColumns)) = [];
                    raw(:,I(~ruleExcludedColumns)) = rawPostRules;
                    raw(:,I(ruleExcludedColumns)) = [];
                else
                    raw(:,~cols) = rawPostRules;
                end
            else
                % Any numeric data for columns set to datetime should not
                % be considered
                data(:,useValue2) = NaN;
                [raw,varNames,ruleExcludedRows,ruleExcludedColumns] = ...
                    internal.matlab.importtool.AbstractSpreadsheet.applyRules(...
                    rules,raw,data,dates,varNames);
            end
            
            if any(ruleExcludedColumns)
                I = find(~cols); % Indices of numeric cols
                % I(ruleExcludedColumns) - indices of cols excluded by rules
                
                %Remove excluded columns from variable name lists
                if ~isempty(columnVarNames)
                    if(isequal(columnVarNames, varNames))
                        %Happens when importing variables per column
                        varNames(I(ruleExcludedColumns)) = [];
                    end
                    columnVarNames(I(ruleExcludedColumns)) = [];
                elseif iscell(varNames) && ...
                        length(varNames) == length(ruleExcludedColumns)
                    varNames(I(ruleExcludedColumns)) = [];
                end
                
                %Remove excluded columns from column target type list
                columnTargetTypes(I(ruleExcludedColumns)) = [];
                dates(I(ruleExcludedColumns)) = [];
            end
            
            for i=1:length(dates)
                if ~isempty(dates{i})
                    dates{i}(ruleExcludedRows,:) = [];
                end
            end
        end
        
        function [varNames,varSizes] = ImportData(obj, varNames, allocationFcn, sheetname, range, rules, columnTargetTypes, columnVarNames)
            %IMPORTDATA
            %
            
            try
                %Extract the data from the sheet and apply any rules
                [raw,data,dates,varNames,columnTargetTypes,columnVarNames] = ImportSheetData(obj,varNames, sheetname, range, rules, columnTargetTypes, columnVarNames);
                                
                % Allocate the data to variables of the requested type
                if ischar(allocationFcn)
                    allocationFcn = str2func(allocationFcn);
                end
                outputVars = feval(allocationFcn,raw,dates,data,columnTargetTypes,columnVarNames);
                
                %Assign the imported data to workspace variables
                varSizes = cell(length(varNames),1);
                for k=1:length(varNames)
                    % Convert any java objects (probably a result of DateCells) to strings
                    if iscell(outputVars{k})
                        I = cellfun(@(x) isjava(x),outputVars{k});
                        outputVars{k}(I) = cellfun(@(x) char(x.toString()),...
                            outputVars{k}(I),'UniformOutput',false);
                    end
                    assignin(obj.DstWorkspace,varNames{k},outputVars{k});
                    varSizes{k,1} = size(outputVars{k});
                end
            catch me
                internal.matlab.importtool.AbstractSpreadsheet.manageImportErrors(me);
            end
        end
        
        function headerRow = GetDefaultHeaderRow(this,sheetname)
           cachedWorksheetStructExists = ~isempty(this.WorksheetStructure) && isfield(this.WorksheetStructure,sheetname);
           if ~cachedWorksheetStructExists 
               this.init(sheetname);
           end
           headerRow = this.WorksheetStructure.(this.generateVariableName(sheetname)).HeaderRow;  
        end
        
        function numericContainerColumns = GetNumericContainerColumns(this,sheetname)
           % Use a subset of sheet data to define defaults for which columns 
           % in a column vector import should be stored in numeric column
           % vectors (vs. cell vectors)
           cachedWorksheetStructExists = ~isempty(this.WorksheetStructure) && isfield(this.WorksheetStructure,sheetname);
           if ~cachedWorksheetStructExists 
               this.init(sheetname);
           end
           numericContainerColumns = this.WorksheetStructure.(this.generateVariableName(sheetname)).NumericContainerColumns;  
        end    
        
        function mixedContainerColumns = GetMixedContainerColumns(this,sheetname)
            % Use a subset of sheet data to define defaults for which
            % columns in a column vector import should be considered as
            % mixed data (cell array vs. numeric/datetime/text)
            cachedWorksheetStructExists = ~isempty(this.WorksheetStructure) && isfield(this.WorksheetStructure,sheetname);
            if ~cachedWorksheetStructExists
                this.init(sheetname);
            end
            mixedContainerColumns = this.WorksheetStructure.(this.generateVariableName(sheetname)).MixedContainerColumns;
        end
        
        function categoricalContainerColumns = GetCategoricalContainerColumns(this,sheetname)
            % Use a subset of sheet data to define defaults for which
            % columns in a column vector import should be considered as
            % mixed data (categorical vs. numeric/datetime/text)
            cachedWorksheetStructExists = ~isempty(this.WorksheetStructure) && isfield(this.WorksheetStructure,sheetname);
            if ~cachedWorksheetStructExists
                this.init(sheetname);
            end
            categoricalContainerColumns = this.WorksheetStructure.(this.generateVariableName(sheetname)).CategoricalContainerColumns;
        end
        
        % Return the recommended initial selection for the sheet.
        function initialSelection = GetInitialSelection(obj,sheetname)
            if isempty(obj.WorksheetStructure) || ~isfield(obj.WorksheetStructure,obj.generateVariableName(sheetname))
                obj.init(sheetname);
            end    
            initialSelection = obj.WorksheetStructure.(obj.generateVariableName(sheetname)).InitialSelection;                   
        end
        
        function dateFormats = GetColumnDateFormats(this, sheetname)
           sheetVarName = this.generateVariableName(sheetname);
           cachedWorksheetStructExists = ~isempty(this.WorksheetStructure) ...
               && isfield(this.WorksheetStructure, sheetVarName);
           if ~cachedWorksheetStructExists 
               this.init(sheetname);
           end

           if isfield(this.WorksheetStructure.(sheetVarName), 'dateFormats')
              dateFormats = this.WorksheetStructure.(sheetVarName).dateFormats;  
           else
               dateFormats = {};
           end
        end
        
        function Reset(obj, sheetName)
            % Called when the spreadsheet which is currently open in the
            % Import Tool changes, in order to reset the spreadsheet object
            % so it can be read in again.
            if isobject(obj) && isprop(obj, 'WorksheetStructure')
                obj.WorksheetStructure = [];
                init(obj, sheetName);
            end
        end
    end
    
    methods (Static, Access = public)
        function obj = createSpreadsheet
            % If there is no ActiveX Excel server on this machine,
            % use BasicMode where the spreadsheet data is loaded inside
            % the BasicSheetData property by calling xlsread
            
            if ~internal.matlab.importtool.AbstractSpreadsheet.alwaysUseBasicMode
                try
                    application = actxserver('excel.application');              
                    application.DisplayAlerts = 0;
                    obj = internal.matlab.importtool.COMSpreadsheet(application);
                    obj.Workbook = [];
                catch me %#ok<NASGU>
                    obj = internal.matlab.importtool.InMemSpreadsheet;
                end
            else
                obj = internal.matlab.importtool.InMemSpreadsheet;
            end
        end
        
        function state = alwaysUseBasicMode(state)
            persistent staticAlwaysUseBasicMode;
            
            if nargin>=1
               staticAlwaysUseBasicMode = state;
            elseif isempty(staticAlwaysUseBasicMode)
               staticAlwaysUseBasicMode = false;
            end
            state = staticAlwaysUseBasicMode;
            
        end
               
        function manageImportErrors(err)
            %MANAGEIMPORTERRORS
            %
            
            rethrowErrList = {...
                'MATLAB:timeseries:tsChkTime:matrixtime'; ...
                'MATLAB:timeseries:tsChkTime:inftime'; ...
                'MATLAB:timeseries:tsChkTime:realtime'};
            if any(strcmp(err.identifier,rethrowErrList))
                err = MException(message('MATLAB:codetools:errImport_SpecificImportError',err.message));
            else
                err = MException(message('MATLAB:codetools:errImport_GenericImportError'));
            end
            throw(err)
        end
    end
    
    methods (Abstract)
      init(obj,sheetname)
      [data,raw,dateData] = Read(obj, sheetname, range)
      dimensions = GetSheetDimensions(obj,sheetname)
      Open(obj, filename)
      [message, description, format] = GetInfo(obj)
      columnNames = getDefaultColumnNames(this,sheetname,row,ncols,avoidShadow)
      Close(obj)
    end
    
    methods (Static, Access = protected)
        function data = parse_data(data)
            % PARSE_DATA parse data from raw cell array into a numeric array and a text
            % cell array.
            %
            %==========================================================================
            
            if isempty(data)
                return
            end
            
            % Ensure data is in cell array
            if ischar(data)
                data = cellstr(data);
            elseif isnumeric(data) || islogical(data)
                data = num2cell(data);
            end
            
            % Find non-numeric entries in data cell array
            vIsText = cellfun('isclass',data,'char');
            
            
            % Place NaN in empty numeric cells
            vIsNaN = strcmpi(data,'nan') | vIsText;
            if any(vIsNaN(:))
                data(vIsNaN) = {NaN};
            end
            
            % Extract numeric data
            rows = size(data,1);
            m = cell(rows,1);
            % Concatenate each row first
            for n=1:rows
                m{n} = cat(2,data{n,:});
            end
            % Now concatenate the single column of cells into a matrix
            data = cat(1,m{:});
            
        end
        
        function b = findColumnTargetTypes(columnTypes,cType)
            %FINDCOLUMNTARGETTYPES
            %
        
            switch cType
                case 'CELL_ARRAY'
                    b = cellfun(@(x) x.isCellArrayColumn, columnTypes);
                case 'NUMERIC_ARRAY'
                    b = cellfun(@(x) x.isNumericArray, columnTypes);
                case 'TIME_ARRAY'
                    b = cellfun(@(x) x.isTimeArray, columnTypes);
                case 'DATETIME_ARRAY'
                    b = cellfun(@(x) x.isDatetimeArray, columnTypes);
                case 'TEXT_ARRAY'
                    b = cellfun(@(x) x.isTextArray, columnTypes);
                case 'TEXT_OR_CELL_ARRAY'
                    b = cellfun(@(x) x.isCellArrayColumn | x.isTextArray, columnTypes);
                case 'TEXT_OR_CATEGORICAL_ARRAY'
                    b = cellfun(@(x) x.isTextArray | x.isCategoricalArray, columnTypes);
                case 'TEXT_CELL_OR_CATEGORICAL_ARRAY'
                    b = cellfun(@(x) x.isTextArray | x.isCellArrayColumn | x.isCategoricalArray, columnTypes);
                otherwise
                    error('id:id','Unknown column type');
            end
        end
        
        function useValue2 = isDatetimeOrTimeseriesColumn(...
                columnTargetTypes, row, column)
            % Returns a vector of logicals, where it contains true if the
            % specified column is a datetime array or a timeseries array
            useValue2 = (internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                columnTargetTypes{row}{column},'DATETIME_ARRAY') | ...
                internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                columnTargetTypes{row}{column},'TIME_ARRAY'));
        end
		
        function varName = generateVariableName(S)
            varName = matlab.lang.makeUniqueStrings(...
                matlab.lang.makeValidName(S), {}, namelengthmax);
        end
    end
    
    methods (Static)
        % NonNumericReplacementRule applyFnc. WorksheetRule of RuleType 
        % REPLACE must return double arrays (*replaceArray)
        % containing replaced content and boolean arrays (*replaceIndexes)
        % identifying the location of replaced content. All of these arrays
        % must be the same size as the data input. replaceArrays may also
        % contain non-replaced content, which will be ignored.
        function [numericReplaceArr, numericReplaceIdx, datetimeReplaceArr, ...
                datetimeReplaceIdx] = nonNumericReplaceFcn(...
                rule, numericData, datetimeData, raw)
            % Do not stomp on cells that have been converted to NaN
            % (g716691)
            numericReplaceIdx = isnan(numericData(:)) & ...
                cellfun(@(x) isempty(x) || ~isnumeric(x) || ~isnan(x), raw(:));
            numericReplaceArr = zeros(length(numericReplaceIdx), 1);
            numericReplaceArr(numericReplaceIdx) = rule.getReplacementNumber();
            numericReplaceArr = numericReplaceArr(:);
            
            datetimeReplaceIdx = cellfun(@isempty, datetimeData(:));
            datetimeReplaceArr = zeros(length(datetimeReplaceIdx), 1);
            datetimeReplaceArr(datetimeReplaceIdx) = rule.getReplacementNumber();
            datetimeReplaceArr = datetimeReplaceArr(:);
        end

        
        % StringReplacementRule applyFnc. WorksheetRule of RuleType 
        % REPLACE must return a double array (replaceArray)
        % containing replaced content and a boolean array (replaceIndexes)
        % identifying the location of replaced content. Both these arrays
        % must be the same size as the data input. replaceArray may also
        % contain non-replaced content, which will be ignored.
        function [numericReplaceArr, numericReplaceIdx, datetimeReplaceArr, ...
                datetimeReplaceIdx] = stringReplaceFcn(rule,~,~,rawData)
            targetStr = char(rule.getTargetString);
            % If the target string contains a wildcard, convert the string
            % to a regular expression and use regular expression matching.
            targetStrRegesp = regexptranslate('wildcard', targetStr);
            if strcmp(targetStr, targetStrRegesp)
                numericReplaceIdx = cellfun(@(x) (isstring(x) || ischar(x)) ...
                    && strcmp(x, targetStr), rawData);
            else
                numericReplaceIdx = cellfun(@(x) (isstring(x) || ischar(x)) && ...
                    isequal(regexp(x, targetStrRegesp, 'once'),1), rawData);
            end
            numericReplaceArr(numericReplaceIdx) = rule.getReplacementNumber();
            numericReplaceArr = numericReplaceArr(:);
            
            datetimeReplaceArr = numericReplaceArr;
            datetimeReplaceIdx = numericReplaceIdx;
        end
        
        % BlankReplacementRule applyFnc. WorksheetRule of RuleType 
        % REPLACE must return double arrays (*replaceArray)
        % containing replaced content and boolean arrays (*replaceIndexes)
        % identifying the location of replaced content. All of these arrays
        % must be the same size as the data input. replaceArrays may also
        % contain non-replaced content, which will be ignored.
        function [numericReplaceArr, numericReplaceIdx, datetimeReplaceArr, ...
                datetimeReplaceIdx] = blankReplaceFcn(rule, ~, ~, rawData)
            numericReplaceIdx = findBlankCells(rawData);
            numericReplaceArr(numericReplaceIdx) = rule.getReplacementNumber();
            numericReplaceArr = numericReplaceArr(:);
            
            datetimeReplaceArr = numericReplaceArr;
            datetimeReplaceIdx = numericReplaceIdx;
        end
        
        % ExcelDateFunction applyFcn. WorksheetRule of RuleType 
        % CONVERT must return a double array (replaceArray)
        % containing replaced content and a boolean array (replaceIndexes)
        % identifying the location of replaced content. Both these arrays
        % must be the same size as the data input. replaceArray may also
        % contain non-replaced content, which will be ignored.
        function [replaceArray,replaceIndexes] = excelDateFunctionFcn(~,~,rawData)
            dateNumArray = NaN(size(rawData));
            replaceIndexes = cellfun('isclass',rawData,'com.mathworks.mlwidgets.importtool.DateCell');
            ind = find(replaceIndexes);
            for k=1:length(ind)
                dateNumArray(ind(k)) = rawData{ind(k)}.getDateNum;
            end
            replaceArray = dateNumArray(:);          
        end

        % NonNumericRowExclusionRule applyFnc. WorksheetRule of RuleType 
        % ROWEXCLUDE must return a boolean array (excludeIndexes)
        % identifying the location of cells which will cause the corresponding
        % row to be excluded. excludeIndexes must be the same size as the
        % data input.
        function [numericExcludeIndexes, datetimeExcludeIndexes] = ...
                excludeRowFcn(~, data, raw, datetimeData)
            % Do not stomp on cells that have been converted to NaN
            % (g716691)
            numericReplaceIndexes = isnan(data(:)) & ...
                cellfun(@(x) isempty(x) || ~isnumeric(x) || ~isnan(x),raw(:));
            if size(data) == size(datetimeData)
                datetimeReplaceIndexes = cellfun(@isempty, datetimeData(:));
            else
                % datetimeData may contain column(s) of datetimes that we
                % need to consider in determining if a row is unimportable.
                datetimeReplaceIndexes = true(size(data(:)));
                for i=1:length(datetimeData)
                    if ~isempty(datetimeData{i})
                        dates = datetimeData{i};
                        len = length(dates);
                        for j=1:len
                            if ~isnan(dates(j).Hour)
                                datetimeReplaceIndexes((i-1)*len + j) = false;
                            end
                        end
                    end
                end
            end
            numericExcludeIndexes = false(size(numericReplaceIndexes));
            numericExcludeIndexes(numericReplaceIndexes) = true;
            datetimeExcludeIndexes = false(size(datetimeReplaceIndexes));
            datetimeExcludeIndexes(datetimeReplaceIndexes) = true;
        end

        % NonNumericColumnExclusionRule applyFnc. WorksheetRule of RuleType 
        % COLUMNEXCLUDE must return a boolean array (excludeIndexes)
        % identifying the location of cells which will cause the corresponding
        % column to be excluded. excludeIndexes must be the same size as the
        % data input.
        function [numericExcludeIndexes, datetimeExcludeIndexes] = ...
                excludeColumnFcn(~, data, raw, datetimeData)
            % Do not stomp on cells that have been converted to NaN
            % (g716691)
            numericReplaceIndexes = isnan(data(:)) & ...
                cellfun(@(x) isempty(x) || ~isnumeric(x) || ~isnan(x),raw(:));
            if size(data) == size(datetimeData)
                datetimeReplaceIndexes = cellfun(@isempty, datetimeData(:));
            else
                % datetimeData may contain column(s) of datetimes that we
                % need to consider in determining if a row is unimportable.
                datetimeReplaceIndexes = true(size(data(:)));
                for i=1:length(datetimeData)
                    if ~isempty(datetimeData{i})
                        dates = datetimeData{i};
                        len = length(dates);
                        for j=1:len
                            if ~isnan(dates(j).Hour)
                                datetimeReplaceIndexes((i-1)*len + j) = false;
                            end
                        end
                    end
                end
            end
            numericExcludeIndexes = false(size(numericReplaceIndexes));
            numericExcludeIndexes(numericReplaceIndexes) = true;
            datetimeExcludeIndexes = false(size(datetimeReplaceIndexes));
            datetimeExcludeIndexes(datetimeReplaceIndexes) = true;
        end
 
        % BlankExcludeColumnRule applyFnc. WorksheetRule of RuleType 
        % COLUMNEXCLUDE must return a boolean array (excludeIndexes)
        % identifying the location of cells which will cause the corresponding
        % column to be excluded. excludeIndexes must be the same size as the
        % data input.
        function [numericExcludeIndexes, datetimeExcludeIndexes] ...
                = blankExcludeColumnFcn(~,~,rawData,~)
            I = findBlankCells(rawData);
            numericExcludeIndexes(I) = true;
            J=~I & cellfun('isclass',rawData,'char');
            numericExcludeIndexes(J) = cellfun(@(x) all(x==' '),rawData(J));
            datetimeExcludeIndexes = numericExcludeIndexes;
        end
        
        % BlankExcludeRowRule applyFnc. WorksheetRule of RuleType 
        % ROWEXCLUDE must return a boolean array (excludeIndexes)
        % identifying the location of cells which will cause the corresponding
        % column to be excluded. excludeIndexes must be the same size as the
        % data input.
        function [numericExcludeIndexes, datetimeExcludeIndexes] ...
                = blankExcludeRowFcn(~,~,rawData,~)
            I = findBlankCells(rawData);
            numericExcludeIndexes(I) = true;
            J=~I & cellfun('isclass',rawData,'char');
            numericExcludeIndexes(J) = cellfun(@(x) all(x==' '),rawData(J));
            datetimeExcludeIndexes = numericExcludeIndexes;
        end
        
        % HeaderRowExcludeRule applyFnc. NoOp just to keep in model. 
        function excludeIndexes = headerExcludeRowFcn(~,~,~)
            excludeIndexes = [];
        end
        
        % Convert an Excel range string of the form "*:*" to MATLAB row and column
        % arrays.        
        function [rows,cols] = excelRangeToMatlab(range)
            colon = strfind(range,':');
            block1 = range(1:colon-1);
            block2 = range(colon+1:end);
            rows = str2double(block1(regexp(block1,'\d'))):str2double(block2(regexp(block2,'\d')));
            cols = base27dec(block1(regexp(block1,'\D'))):base27dec(block2(regexp(block2,'\D')));
        end
        
        
        
        function [raw,varNames,excludedRows,excludedColumns] = applyRules(rules,raw,data,dates,varNames)
            
            matrixDims = size(raw);
            includedRows = 1:size(raw,1);
            includedColumns = 1:size(raw,2);
            excludedRows = true(size(raw,1),1);
            excludedColumns = true(size(raw,2),1);
            raw = raw(:);

            
            % Loop through each of the rules, successively replacing and
            % excluding data from the arrays "raw", "data", and "dates".
            % This needs to be done so when multiple rules are applied they
            % are working with the data which had the previous rules
            % applied.
            for k=1:length(rules)
                if rules{k}.isRowExcludeType
                    excludeIndexes = false(size(raw));
                    [numericExclusions, datetimeExclusions] = feval(char(rules{k}.getApplyFcn),rules{k},data,raw,dates);
                    excludeIndexes(numericExclusions & datetimeExclusions) = true;
                    shapedRawMatrix = reshape(raw,matrixDims);
                    shapedExcludeIndexes = reshape(excludeIndexes,matrixDims);
                    I = any(shapedExcludeIndexes,2);
                    shapedRawMatrix(I,:) = [];
                    data(I,:) = [];
                    % dates is a cell array of datetime vectors for columns
                    % selected as datetimes.  Exclude the rows from those
                    % which are not empty.
                    for d=1:length(dates)
                        if ~isempty(dates{d})
                            dates{d}(I,:) = [];
                        end
                    end
                    matrixDims(1) = matrixDims(1)-sum(any(shapedExcludeIndexes,2));
                    raw = shapedRawMatrix(:);
                    includedRows(I) = [];
                elseif rules{k}.isColumnExcludeType
                    excludeIndexes = false(size(raw));
                    [numericExclusions, datetimeExclusions] = feval(char(rules{k}.getApplyFcn),rules{k},data,raw,dates);
                    excludeIndexes(numericExclusions & datetimeExclusions) = true;
                    shapedRawMatrix = reshape(raw,matrixDims);
                    shapedExcludeIndexes = reshape(excludeIndexes,matrixDims);
                    % Remove excluded columns from the list of variable names
                    I = any(shapedExcludeIndexes,1);
                    if size(data,2)==length(varNames)
                        varNames(I) = [];
                    end
                    shapedRawMatrix(:,I) = [];
                    data(:,I) = [];
                    dates(:,I) = [];
                    matrixDims(2) = matrixDims(2)-sum(any(shapedExcludeIndexes,1));
                    raw = shapedRawMatrix(:);
                    includedColumns(I) = [];
                else
                    [replaceArray,replaceIndexes] = feval(char(rules{k}.getApplyFcn),rules{k},data,dates,raw);
                    raw(replaceIndexes) = num2cell(replaceArray(replaceIndexes));
                    data(replaceIndexes) = replaceArray(replaceIndexes);
                    
                end
            end
            raw = reshape(raw,matrixDims);
            excludedRows(includedRows) = false;
            excludedColumns(includedColumns) = false;
        end
        
        
        function outputVars = columnVectorAllocationFcn(raw, dates, ~, columnTargetTypes, ~)
            %COLUMNVECTORALLOCATIONFCN
            %
            outputVars = cell(1,size(raw,2));
            for col=1:length(outputVars)
                if columnTargetTypes{col}.isCellArrayColumn || columnTargetTypes{col}.isTextArray
                    if isstring(raw{1, col})
                        strColumn = raw{1,col};
                        strColumn(ismissing(strColumn)) = '';
                        if internal.matlab.importtool.ImportUtils.isStringTextType
                            outputVars{col} = strColumn;
                        else
                            outputVars{col} = cellstr(strColumn);
                        end
                    else
                        outputVars{col} = raw(:,col);
                    end
                elseif (columnTargetTypes{col}.isTimeArray || ...
                        columnTargetTypes{col}.isDatetimeArray) && ...
                        ~isempty(dates{:,col})
                    % Use the dates (array of datetimes) for both datetime
                    % and timeseries import (timeseries will convert it to
                    % datenum for its internal use)
                    outputVars{col} = dates{:,col};
                elseif columnTargetTypes{col}.isCategoricalArray
                    if iscategorical(raw{1,col})
                        outputVars{col} = removecats(raw{1,col});
                    else
                        outputVars{col} = removecats(categorical(raw{1,col}));
                    end
                else
                    outputVars{col} = cell2mat(raw(:,col));
                end
            end
        end
           
        function outputVars = datasetAllocationFcn(raw, dates, data,columnTargetTypes,columnVarNames)
            %DATASETALLOCATIONFCN
            %
            columnData = internal.matlab.importtool.AbstractSpreadsheet.columnVectorAllocationFcn(raw,dates, data,columnTargetTypes,columnVarNames);
            outputVars = {dataset(columnData{:},'VarNames',columnVarNames)};
        end

        function outputVars = tableAllocationFcn(raw, dates, data, columnTargetTypes, columnVarNames)
            %TABLEALLOCATIONFCN
            %
            columnData = internal.matlab.importtool.AbstractSpreadsheet.columnVectorAllocationFcn(raw,dates, data,columnTargetTypes,columnVarNames);
            outputVars = {table(columnData{:},'VariableNames',columnVarNames)};
        end
        
        function outputVars = timeseriesAllocationFcn(raw, dates, data, columnTargetTypes, columnVarNames)
            %TIMESERIESALLOCATIONFCN
            %
            columnData = internal.matlab.importtool.AbstractSpreadsheet.columnVectorAllocationFcn(raw,dates,data,columnTargetTypes);
            idxT = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                    columnTargetTypes,'TIME_ARRAY');
            if any(idxT)
                % Convert datetime columns to datenum for the timeseries
                ts = timeseries(cell2mat(columnData(~idxT)),datenum(columnData{idxT}));
            else
                ts = timeseries(cell2mat(columnData(~idxT)));
           end
            ts.DataInfo.UserData = struct('ChannelNames', {columnVarNames(~idxT)});
            outputVars = {ts};
        end

        function outputVars = matrixAllocationFcn(raw,~,~,~,~)
            %MATRIXALLOCATIONFCN
            %            
            outputVars = {cell2mat(raw)};
        end

        function outputVars = cellArrayAllocationFcn(raw,~,~,~,~)
        
            %CELLARRACYALLOCATIONFCN
            %
            outputVars = cell(size(raw));
            for col=1:size(raw, 2)
                if isstring(raw{1, col})
                    % raw contains strings.  Handle missing strings before
                    % the assignment into the outputVars
                    strColumn = raw{1,col};
                    strColumn(ismissing(strColumn)) = '';
                    if internal.matlab.importtool.ImportUtils.isStringTextType
                        % Create a cell array with individual strings in it
                        outputVars(:,col) = mat2cell(strColumn, ones(1, length(strColumn)), 1); %#ok<MMTC>
                    else
                        % Convert strings to cellstr
                        outputVars(:,col) = cellstr(strColumn);
                    end
                else
                    % raw is a cell array.  Convert text in it to strings
                    % if necessary.
                    if internal.matlab.importtool.ImportUtils.isStringTextType
                        outputVars(:,col) = cellfun(@convertTextToString, raw(:,col), 'UniformOutput', false);
                    else
                        outputVars(:,col) = {raw{:,col}};
                    end
                end
            end
            outputVars = {outputVars};
        end
        
        function outputVars = stringAllocationFcn(raw, ~, ~, ~, ~)
            strArray = [raw{1,:}];
            % Prevent missing strings in the output
            strArray(ismissing(strArray)) = '';
            outputVars = {strArray};
        end

        % Estimate the location of the default header row from a raw cell
        % array and an optional data array
        function headerrow = getHeaderRowFromData(raw,data)
            firstColumnWithData = find(any(~cellfun('isempty',raw),1),1,'first');
            if isempty(firstColumnWithData)
                headerrow = 1;
                return
            end
            raw = raw(:,firstColumnWithData:end);
            if nargin>=2 && ~isempty(data)
                data = data(:,firstColumnWithData:end);
                stringRows = find(all(isnan(data) & cellfun('isclass',raw,'char'),2));
            else
                Inumeric = cellfun('isclass',raw,'double');
                Inonnumeric = cellfun('isclass',raw,'char') | (Inumeric & cellfun(@(x) isscalar(x) && isnan(x),raw));
                stringRows = find(all(Inonnumeric,2));
            end

            if isempty(stringRows)
                headerrow = 1;
                return
            end
            % TO Explain logic below
            titleRow = find(sum(cellfun(@(x) ischar(x) && ~isempty(regexp(x,'^[a-zA-Z].*','once')),...
                     raw(stringRows,:)),2)>size(raw,2)/2,1,'first');

            if isempty(titleRow)
                headerrow = stringRows(1);
            else  
                headerrow = stringRows(titleRow);
            end
        end
            
        function [numericContainerColumns, mixedContainerColumns] = ...
                getNumericContainerColumnsFromData(raw,data,dateData)
            % Use a subset of sheet data to define defaults for which columns
            % in a column vector import should be stored in numeric column
            % vectors (vs. cell vectors)
            if nargin>=3 && ~isempty(data) && ~isempty(dateData)
                % Numeric columns have at least one number or date
                numericContainerColumns = sum(~isnan(data)|~isnan(dateData),1)>=1;
            elseif nargin>=2 && ~isempty(data)
                % Numeric columns have at least one number
                numNumerics = sum(~isnan(data),1);
                numericContainerColumns = numNumerics >= 1;
                empties = sum(cellfun(@(x) isempty(x) || (ischar(x) && isempty(strtrim(x))), raw));
                mostlyNumericColumns = numNumerics > (size(data,1) - empties)/2;
                mixedContainerColumns = numericContainerColumns & ~mostlyNumericColumns;
            else
                % Numeric columns have at least one number
                Inumeric = cellfun('isclass',raw,'double');
                numericContainerColumns = sum(Inumeric,1)>size(raw,1)/2;
            end
        end
        
        function categoricalContainerColumns = getCategoricalContainerColumnsFromData(raw)
            if ~isstring(raw)
                raw = string(raw);
            end
            categoricalContainerColumns = false(1, size(raw, 2));
            for col = 1:size(raw, 2)
                colData = raw(:, col);
                [~, ia, ~] = unique(colData);
                categoricalContainerColumns(col) = (length(ia)/length(colData(colData ~= '')) < 0.7);
            end
        end
    end 
end

function d = base27dec(s)
    %   BASE27DEC(S) returns the decimal of string S which represents a number in
    %   base 27, expressed as 'A'..'Z', 'AA','AB'...'AZ', and so on. Note, there is
    %   no zero so strictly we have hybrid base26, base27 number system.
    %
    %   Examples
    %       base27dec('A') returns 1
    %       base27dec('Z') returns 26
    %       base27dec('IV') returns 256
    %-----------------------------------------------------------------------------

    s = upper(s);
    if length(s) == 1
        d = s(1) -'A' + 1;
    else
        cumulative = 0;
        for i = 1:numel(s)-1
            cumulative = cumulative + 26.^i;
        end
        indexes_fliped = 1 + s - 'A';
        indexes = fliplr(indexes_fliped);
        indexes_in_cells = num2cell(indexes);
        d = cumulative + sub2ind(repmat(26, 1,numel(s)), indexes_in_cells{:});
    end
end

function blankIndices = findBlankCells(rawData)
        
    blankIndices = cellfun('isempty',rawData);
    Iblank = find(cellfun('isclass',rawData,'char'));
    if ~isempty(Iblank)
        Iblank(cellfun(@(x) ~all(x==' '),rawData(Iblank))) = [];
        blankIndices(Iblank) = true;
    end
    
    blankStringIndices = cellfun(@(x) isa(x, 'string') && x == string(''), rawData);
    if any(blankStringIndices)
        blankIndices = blankIndices | blankStringIndices;
    end
    
    catIndices = cellfun('isclass', rawData, 'categorical');
    if any(catIndices)
        catColIndices = find(catIndices);
        for i=1:length(catColIndices)
            catColIndex = catColIndices(i);
            undefCategoricals = isundefined(rawData{catColIndex});
            blankIndices(catColIndex:catColIndex + length(undefCategoricals) - 1) = undefCategoricals;
        end
    end
    
    IdatetimeBlank = find(cellfun('isclass', rawData', ...
        'com.mathworks.mlwidgets.importtool.DateCell'));
    if ~isempty(IdatetimeBlank)
        IdatetimeBlank(cellfun(@(x) ~isempty(char(x)), ...
            rawData(IdatetimeBlank))) = [];
        blankIndices(IdatetimeBlank) = true;
    end
end

function val = convertTextToString(c)
    if ischar(c)
        val = string(c);
    else
        val = c;
    end
end


