function makecontentsfile(dirname,option)
%MAKECONTENTSFILE  Make a new Contents.m file.
%   MAKECONTENTSFILE(dirname, option)
%   If OPTION equals 'force', then any existing Contents.m file is
%   over-written.

%   Copyright 1984-2016 The MathWorks, Inc.

if nargin < 1
    dirname = pwd;
end

if nargin < 2
    option = '';
end

d = dir([dirname filesep '*.m']);
[null,sortIndex] = sort(lower({d.name}));
d = d(sortIndex);

maxNameLen = 0;
killIndex = [];
noContentsFlag = 1;
for n = 1:length(d)
    d(n).mfilename = regexprep(d(n).name,'\.m$','');
    if strcmp(d(n).mfilename,'Contents')
        % Special case: remove the Contents.m file from the list
        % Contents.m should not list itself.
        killIndex = n;
        noContentsFlag = 0;
    else
        d(n).description = getdescription(d(n).name);
        maxNameLen = max(length(d(n).mfilename), maxNameLen);
    end
end
d(killIndex) = [];

maxNameLenStr = num2str(maxNameLen);

lineSep = char(java.lang.System.getProperty('line.separator'));

if noContentsFlag || strcmp(option,'force')
    [fid,errMsg] = fopen([dirname filesep 'Contents.m'],'w');
    if fid < 0
        error(message('MATLAB:filebrowser:MakeContentsFileOpenError', errMsg))
    end
    [pth,nm] = fileparts(dirname);
    fprintf(fid,'%% %s%s%%%s',upper(nm), lineSep, lineSep);
    fprintf(fid,'%% Files%s', lineSep);
    for n = 1:length(d)
        fprintf(fid,['%%   %-' maxNameLenStr 's - %s%s'], ...
            d(n).mfilename, d(n).description, lineSep);
    end
    fclose(fid);
else
    error(message('MATLAB:filebrowser:MakeContentsFileExists'))
end
