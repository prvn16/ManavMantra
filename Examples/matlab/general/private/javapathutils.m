function [retval] = javapathutils(option,str)
% Utilities used by javaclasspathpath, javarmpath

switch(option)
    case '-relativetoabsolute'
        retval = localAbsolute(str); 
    case '-isurl'
        retval = localIsURL(str);    
end

%--------------------------------------------------
function retval = localIsURL(str)
% Check to see if the string is a URL
% ToDo: Use java.net.URL to do check
retval = strncmp(str, 'http://', 7) || strncmp(str, 'ftp://', 6);

%--------------------------------------------------
function path_out = localAbsolute(path_in)
% Converts a relative path to an absolute path

path_out = path_in;
if ~(localIsURL(path_in))
    file = java.io.File(path_in);
    if ~(file.isAbsolute)
        path_out = fullfile(pwd,path_in);
        file = java.io.File(path_out);
        path_out = char(file.getCanonicalPath);
    end
end
