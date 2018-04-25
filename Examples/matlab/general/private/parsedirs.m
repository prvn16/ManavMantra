function cdirs = parsedirs(str,varargin)
%PARSEDIRS Convert string of directories into a cell array
%   C = PARSEDIRS(S) converts S, a string of directories separated by path
%   separators, to C, a cell array of directories. 
%
%   The function will clean up each directory name by converting file
%   separators to the appropriate operating system file separator, and by
%   ending each cell with a path separator. It will also remove repeated
%   file and path separators, and insignificant whitespace. 
%
%   Example:
%       cp = parsedirs(path);

%   Copyright 1984-2007 The MathWorks, Inc.

fs = filesep;
ps = pathsep;

cdirs = regexp(str, sprintf('[^\\s%s;][^%s;]*', ps, ps), 'match')';

if ps == ';'
    % Only iron fileseps on PC:
    cdirs = strrep(cdirs,'/','\');

    % Remove repeated "\"s unless they are the start of string
    % Also ensure a "\" exists after a colon
	cdirs = regexprep(cdirs, '(:)\s*$|(.)\\{2,}', '$1\');
else
    % Remove repeated "/"s
    cdirs = regexprep(cdirs, '/{2,}', '/');

    % Do any tilde expansion
    ix = find(strncmp(cdirs,'~',1));
    if ~isempty(ix)
      cdirs(ix) = unix_tilde_expansion(cdirs(ix));
    end
end

% Remove trailing fileseps, but allow a directory to be "X:\", "\" or "/" 
% Add pathseps to the end of all paths
cdirs = regexprep(cdirs,sprintf('(.*[^:])\\%s\\s*$|(.+)\\s*$',fs),sprintf('$1%s', ps));

% Remove empty paths
cdirs(cellfun('isempty', cdirs)) = [];
