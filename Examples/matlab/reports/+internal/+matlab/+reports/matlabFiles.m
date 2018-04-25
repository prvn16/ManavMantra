function matlabFileList = matlabFiles( dirname, reportName)
%MATLABFILES parses a directory and returns an array of the
% MATLAB files that exist in that directory.
%
% This function follows the same rules as the MATLAB path and excludes
% files that begin with "._".  This function also excludes Contents.m
% from the list.
%
%   This function is unsupported and might change or be removed without
%   notice in a future version.

% Copyright 2012-2016 The MathWorks, Inc.

%% input params
matlabFileList = [];

if isdir(dirname)
    dirFileList = what(dirname);
    unsortedList = [dirFileList.m];
    
    if(~strcmp(reportName, getString(message('MATLAB:codetools:reports:HelpReportName'))))
        if (isfield(dirFileList, 'mlapp'))
            unsortedList = [unsortedList; dirFileList.mlapp];
        end
    end
    
    if (isfield(dirFileList, 'mlx'))
        unsortedList = [unsortedList; dirFileList.mlx];
    end
    
    matlabFileList = sort(unsortedList);
    
    % Exclude the Contents file from the list
    matlabFileList = matlabFileList(~strcmp(matlabFileList,'Contents.m'));
    
else
    internal.matlab.reports.webError(getString(message('MATLAB:codetools:reports:IsNotAFolder', dirname)), reportName);
end
end
