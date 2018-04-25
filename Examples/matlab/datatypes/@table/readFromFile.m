function t = readFromFile(filename,args)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% READFROMFILE Create a table by reading from a file.

%   Copyright 2012-2015 The MathWorks, Inc.
try
    %Make readtable and writetable accept strings (shallow)
    [filename, args{:}] = matlab.io.internal.utility.convertStringsToChars(filename, args{:});
    
    pnames = {'FileType'};
    dflts =  {       [] };
    [fileType,supplied,otherArgs] = matlab.internal.datatypes.parseArgs(pnames, dflts, args{:});

    if ~supplied.FileType
        [~,~,fx] = fileparts(filename);
        switch lower(fx)
        case {'.txt' '.dat' '.csv'}, fileType = 'text';
        case {'.xls' '.xlsx' '.xlsb' '.xlsm' '.xltm' '.xltx' '.ods'}, fileType = 'spreadsheet';
        case '', fileType = 'text';
        otherwise
            error(message('MATLAB:readtable:UnrecognizedFileExtension',fx));
        end
    else
        fileTypes = {'text' 'spreadsheet'};
        itype = find(strncmpi(fileType,fileTypes,length(fileType)));
        if isempty(itype)
            error(message('MATLAB:readtable:UnrecognizedFileType',fileType));
        elseif ~isscalar(itype)
            error(message('MATLAB:readtable:AmbiguousFileType',fileType));
        end
    end

    % readTextFile and readXLSFile will add an extension if need be, no need to add one here.

    switch lower(fileType)
    case 'text'
        t = table.readTextFile(filename,otherArgs);
    case 'spreadsheet'
        t = table.readXLSFile(filename,otherArgs);
    end
catch ME
    throwAsCaller(ME)
end
