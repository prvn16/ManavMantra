function winopen(filename)
%WINOPEN Open a file or directory using Microsoft Windows.
%   WINOPEN FILENAME opens the file or directory FILENAME using the
%   appropriate Microsoft Windows shell command, based on the file type and
%   extension.
%   This function behaves as if the you had double-clicked on the file
%   or directory inside of the Windows Explorer.
%
%   Examples:
%
%     If you have Microsoft Word installed, then
%     winopen('c:\myinfo.doc')
%     opens that file in Microsoft Word if the file exists, and errors if
%     it doesn't.
%
%     winopen('c:\')
%     opens a new Windows Explorer window, showing the contents of your C
%     drive.
%   
%   See also OPEN, DOS, WEB.
  
%   Copyright 1984-2012 The MathWorks, Inc.

if ~ispc
    error(message('MATLAB:winopen:pcOnly'));
end

narginchk(1,1);

if ~ischar(filename)
    error(message('MATLAB:winopen:MustBeString'));
end

if ~exist(filename,'file')
    error(message('MATLAB:winopen:noSuchFile'));
end

%On Vista and Windows7, we can no longer pass in a path with forward
%slashes.
filename = strrep(filename, '/', '\');

pathstr = '';
if ~isdir(filename)
    % which is needed only for files, not directories.
    fullfilename = which(filename); 
    
    if isempty(fullfilename)
        fullfilename = filename;
    end
    
    [pathstr, name, extension] = fileparts(fullfilename);
    filename = [name extension];
    if ~isempty(pathstr)
        if (length(pathstr) < 2 || pathstr(2) ~= ':') && pathstr(1) ~= '\' 
            pathstr = [pwd filesep pathstr];
        end
    end
end
win_open_mex(pathstr, filename);
