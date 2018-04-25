function reset(ds)
%RESET Reset the SpreadsheetDatastore to the start of the data.
%   RESET(SSDS) resets SSDS to the beginning of the datastore.
%
%   Example:
%   --------
%      % Create a SpreadsheetDatastore
%      ssds = spreadsheetDatastore('airlinesmall_subset.xlsx')
%      % We are only interested in the Arrival Delay data
%      ssds.SelectedVariableNames = 'ArrDelay'
%      ssds.ReadSize = 'sheet';
%      [tab,info] = read(ssds);
%      % Since reading from the datastore above affected the state
%      % of ssds, reset to the beginning of the datastore:
%      reset(ssds)
%      % Sum the Arrival Delays
%      sumAD = 0;
%      while hasdata(ssds)
%         tab = read(ssds);
%         data = tab.ArrDelay(~isnan(tab.ArrDelay)); % filter data
%         sumAD = sumAD + sum(data);
%      end
%      sumAD
%
%   See also - matlab.io.datastore.SpreadsheetDatastore, read, readall, hasdata, preview.

%   Copyright 2015-2016 The MathWorks, Inc.

    try
        reset@matlab.io.datastore.FileBasedDatastore(ds);
    catch ME
        throw(ME);
    end
    
    % reset the sheets to read index and set state to signify that there is
    % no data available to convert.
    ds.SheetsToReadIdx = 1;
    ds.IsDataAvailableToConvert = false;
    ds.NumRowsAvailableInSheet = 0;
    % Create a BookObject and SheetObject from the first file
    if ~isEmptyFiles(ds) && ~ds.IsFirstFileBook
        import matlab.io.datastore.SpreadsheetDatastore;
        import matlab.io.spreadsheet.internal.createWorkbook;

        firstFile = ds.Files{1};
        fmt = matlab.io.spreadsheet.internal.getExtension(firstFile);
        ds.BookObject = createWorkbook(fmt, firstFile);
        ds.SheetObject = SpreadsheetDatastore.getSheetObject(ds.BookObject, ds.Sheets);
        % No need to create BookObject unless a new BookObject for first file is needed
        % after reading from a different file
        ds.IsFirstFileBook = true;
    end
end
