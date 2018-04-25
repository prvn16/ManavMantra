function javarmpath(varargin)
%JAVARMPATH Remove directory from dynamic java path.
%   JAVARMPATH DIRNAME  removes the specified directory from the
%   dynamic java path.
%
%   JAVARMPATH DIR1 DIR2 DIR3  removes all the specified directories
%   from the dynamic java path.
%
%   Use the functional form of JAVARMPATH, such as
%   JAVARMPATH('dir1','dir2',...), when the directory specification
%   is stored in a string.
%
%   Whenever the dynamic java path is changed, 'clear java' is run.
%
%   Examples
%       javarmpath c:\matlab\work
%       javarmpath /home/user/matlab
%
%   See also JAVAADDPATH, JAVACLASSPATH.

%   Copyright 2002-2016 The MathWorks, Inc.

dynamicPath = javaclasspath;
WARNID = 'MATLAB:GENERAL:JAVARMPATH:NotFoundInPath';
ERRID = 'MATLAB:GENERAL:JAVARMPATH:InvalidInput';

% Loop through entries
for n = 1:length(varargin)
    entry = varargin{n};
    if ischar(entry) || (isstring(entry) && isscalar(entry) && ~ismissing(entry))
        
        % Clean up path string
        entry = strtrim(char(entry));
        entry = javapathutils('-relativetoabsolute',entry);
        
        % Remove entry from class path
        ind = strcmp(dynamicPath,entry);
        if isempty(ind) || ~any(ind)
            warning(WARNID,'%s',getString(message('MATLAB:javaclasspath:RmpathNotFoundInPath',entry)));
        else
            dynamicPath(ind) = [];
        end
    else
        error(ERRID,'%s',getString(message('MATLAB:javaclasspath:RmpathInvalidInput')));
    end
end
javaclasspath(dynamicPath);

