function profsave(profInfo, dirname)
%PROFSAVE Save profile report in HTML format
%   PROFSAVE(PROFINFO) saves HTML files that correspond to each of the
%   files in the profiler data structure's FunctionTable.
%   PROFSAVE(PROFINFO, DIRNAME) saves the files in the specified directory
%   PROFSAVE by itself uses the results from the call PROFILE('INFO')
%
%   Example:
%   profile on
%   plot(magic(5))
%   profile off
%   profsave(profile('info'),'profile_results')
%
%   See also PROFILE, PROFVIEW.

%   Copyright 1984-2012 The MathWorks, Inc.

if nargin < 1
    profInfo = profile('info');
end

if nargin < 2
    dirname = 'profile_results';
end

pth = fileparts(dirname);

if isempty(pth)
    fullDirname = fullfile(cd,dirname);
else
    fullDirname = dirname;
end


if ~exist(fullDirname,'dir')
    if ~mkdir(fullDirname)
        error(message('MATLAB:profiler:UnableToCreateDirectory', fullDirname));
    end
end
    
for n = 0:length(profInfo.FunctionTable)
    str = profview(n,profInfo);
    
    str = regexprep(str,'<a href="matlab: profview\((\d+)\);">','<a href="file$1.html">');
    % The question mark makes the .* wildcard non-greedy
    str = regexprep(str,'<a href="matlab:.*?>(.*?)</a>','$1');
    % Remove all the forms
    str = regexprep(str,'<form.*?</form>','');

    insertStr = ['<body bgcolor="#F8F8F8"><strong>' getString(message('MATLAB:profiler:StaticCopyOfReport')) '</strong><p>' ...
        '<a href="file0.html">' getString(message('MATLAB:profiler:HomeUrl')) '</a><p>'];
    str = strrep(str,'<body>',insertStr);

    filename = fullfile(fullDirname,sprintf('file%d.html',n));
    fid = fopen(filename,'w','n','utf8');
    if fid > 0
        fprintf(fid,'%s',str);
        fclose(fid);
    else
        error(message('MATLAB:profiler:UnableToOpenFile', filename));
    end
    
end

web(['file:///' fullfile(fullDirname,'file0.html')],'-browser');
