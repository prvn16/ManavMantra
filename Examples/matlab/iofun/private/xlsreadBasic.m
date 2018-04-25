function [numericData, textData, rawData] = xlsreadBasic(filename, sheet)
    % xlsreadBasic is the BIFFPARSE implementation of xlsread.
    %   [NUM,TXT,RAW]=xlsreadBasic(FILE,SHEET) reads from the specified SHEET.
    %
    %   See also XLSREAD, XLSWRITE, XLSFINFO.

    %   Copyright 1984-2012 The MathWorks, Inc.
    
    % Read Excel file as binary image file
    biffvector = biffread(filename);
    
    % get sheet names
    [data, names] = matlab.iofun.internal.excel.biffparse(biffvector);
    
    % if the names array is empty, this is an old style biff record with
    % no sheet name.  Just return data and empty text cell array.
    if isempty(names)
        numericData = data;
        textData = cell(names);
        if nargout > 2
            rawData = num2cell(data);
        end
        return;
    end
    
    if nargin == 1 || isempty(sheet)
        % just get the first sheet
        [n, s] = matlab.iofun.internal.excel.biffparse(biffvector, names{1});
    else
        % try to read this sheet
        try
            [n, s] = matlab.iofun.internal.excel.biffparse(biffvector, sheet);
        catch exception
            error(message('MATLAB:xlsread:WorksheetNotOpened', sheet, exception.message));
        end
    end
    
    % trim trailing empty text cells and NaN matrix elements
    [numericData, textData] = xlsreadTrimArrays(n,s);
    % replace empty text cells with char([]).
    textData(cellfun('isempty',textData))={''};
    
    if nargout > 2
        % create raw data return
        if isempty(s)
            rawData = num2cell(n);
        else
            rawData = cell(max(size(n),size(s)));
            rawData(1:size(n,1),1:size(n,2)) = num2cell(n);
            for i = 1:size(s,1)
                for j = 1:size(s,2)
                    if (~isempty(s{i,j}) && (i > size(n,1) || j > size(n,2) || isnan(n(i,j))))
                        rawData(i,j) = s(i,j);
                    end
                end
            end
        end
        % trim all-empty-string leading rows from raw array
        while size(rawData,1)>1 && all(cellfun('isempty',rawData(1,:)))
            rawData = rawData(2:end,:);
        end
        % trim all-empty-string leading columns from raw array
        while size(rawData,2)>1 && all(cellfun('isempty',rawData(:,1)))
            rawData = rawData(:,2:end);
        end
        % replace empty raw data with NaN, to comply with specification
        rawData(cellfun('isempty',rawData))={NaN};
    end
end

