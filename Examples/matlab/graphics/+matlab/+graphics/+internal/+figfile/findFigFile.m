function full = findFigFile(filename)
%findFigFile Find the full path to a fig file that exists
%
%  findFigFile(filename) looks for the most likely figfile match on the
%  path for the specified filename and returns the full path to it.  This
%  function will default to adding a ".fig" extension if the input has no
%  extension.
%
%  If both the original input or the input plus a .fig extension cannot be
%  found, the original input filename will be returned.

%  Copyright 2012-2013 The MathWorks, Inc.

% If there is no extension, we will favour the .fig file over an exact match
[~, ~, ext] = fileparts(filename);
if isempty(ext)
    FilesToSearch = {[filename '.fig'], filename};
else
    FilesToSearch = {filename};
end

full = '';

for n=1:length(FilesToSearch)
    % Check the preferred filename to see if it exists
    if exist(FilesToSearch{n}, 'file')==2
        % Try to get full path using which
        whichPath = which(FilesToSearch{n});
        if ~isempty(whichPath)
            full = whichPath;
        else
            full = FilesToSearch{n};
        end
        break
    end
end

if isempty(full)
    % Stick with what the user gave us
    full = filename;
end
