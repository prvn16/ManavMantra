function sheetNames = sheetnames(ds, fileNameOrIdx)
%SHEETNAMES returns the sheet names in the file name or file index
%   This function is responsible for returning the sheet names from the
%   specified file name or file index. The file name must be contained in
%   the datastore. The file index must be less than or equal to the number
%   of files in the datastore.
%
%   Example:
%   --------
%      % Create a SpreadsheetDatastore
%      ssds = spreadsheetDatastore('airlinesmall_subset.xlsx')
%      % sheetnames in the first file
%      sNames = sheetnames(ssds, 1)

%   Copyright 2015-2017 The MathWorks, Inc.

    % imports
    import matlab.io.internal.validators.isString;
    import matlab.io.spreadsheet.internal.createWorkbook;

    if nargin > 1
        fileNameOrIdx = convertStringsToChars(fileNameOrIdx);
    end

    try
        % specified input must be a valid filename or a file index.
        if isString(fileNameOrIdx)
            if ~ismember(fileNameOrIdx, ds.Files)
                error(message('MATLAB:datastoreio:spreadsheetdatastore:invalidFileName', fileNameOrIdx));
            end
        else
            try
                validateattributes(fileNameOrIdx, {'numeric'}, {'scalar', 'positive', 'integer', '<=', numel(ds.Files)});
            catch
                error(message('MATLAB:datastoreio:spreadsheetdatastore:invalidFileIndex', numel(ds.Files)));
            end
            fileNameOrIdx = ds.Files{fileNameOrIdx};
        end
        
        fmt = matlab.io.spreadsheet.internal.getExtension(fileNameOrIdx);
        % return the sheet names
        bookObj = createWorkbook(fmt, fileNameOrIdx);
        sheetNames = bookObj.SheetNames;
    catch ME
        throw(ME);
    end
end
