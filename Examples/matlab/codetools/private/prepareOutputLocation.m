function outputMessage = prepareOutputLocation(outputAbsoluteFilename)
%PREPAREOUTPUTLOCATION Verifies directory is writable and creates subdirectory.
%   PREPAREOUTPUTLOCATION(filename) checks that the directory exists, tries to
%   create the directory if it doesn't, and checks the file is writable.  It
%   returns a descriptive string if there's a problem or an empty string if
%   everything is OK.

% Matthew J. Simoneau, October 2003
% Copyright 1984-2012 The MathWorks, Inc.

outputMessage = [];

% Make sure the output directory exists.  If not, try to make it.
outputDir = fileparts(outputAbsoluteFilename);
if isempty(dir(outputDir))
    try
        mkdir(outputDir)
    catch
        outputMessage = pm('MkdirFailed',outputDir);
        return
    end
end

% Make sure the output location is writable.
if isempty(dir(outputAbsoluteFilename))
    % This file doesn't exist yet.  Can we write to this location?
    fid = fopen(outputAbsoluteFilename,'w');
    if (fid == -1)
        % No, we can't.
        outputMessage = pm('DirNotWritable',outputDir);
    else
        % Yes, we can.
        fclose(fid);
        delete(outputAbsoluteFilename)
    end 
else
   % This file exists.  Delete it to make way.
    w = warning('off','MATLAB:DELETE:Permission');
    delete(outputAbsoluteFilename);
    warning(w);
    if ~isempty(dir(outputAbsoluteFilename))
       % Couldn't delete it.
       outputMessage = pm('FileNotWritable',outputAbsoluteFilename);
    end
end

%===============================================================================
function m = pm(id,varargin)
m = message(['MATLAB:publish:' id],varargin{:});