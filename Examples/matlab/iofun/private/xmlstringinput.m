function out = xmlstringinput(xString,isFullSearch,varargin)
%XMLSTRINGINPUT Determine whether a string is a file or URL
%   RESULT = XMLSTRINGINPUT(STRING) will return STRING if
%   it contains "://", indicating that it is a URN.  Otherwise,
%   it will search the path for a file identified by STRING.
%
%   RESULT = XMLSTRINGINPUT(STRING,FULLSEARCH) will
%   process STRING to return a RESULT appropriate for passing
%   to an XML process.   STRING can be a URN, full path name,
%   or file name.
%
%   If STRING is a  filename, FULLSEARCH will control how 
%   the full path is built.  If TRUE, the XMLSTRINGINPUT 
%   will search the entire MATLAB path for the filename
%   and return an error if the file can not be found.
%   This is useful for source documents which are assumed
%   to exist.  If FALSE, only the current directory will
%   be searched.  This is useful for result documents which
%   may not exist yet.  FULLSEARCH is TRUE if omitted.
%
%   This utility is used by XSLT, XMLWRITE, and XMLREAD

%   Copyright 1984-2009 The MathWorks, Inc.

%Note: the varargin in the signature is to support a legacy input argument
%which returned the result as a java.io.File object.  This turned out to
%be worse than useless, causing multiple encoding and escaping problems so
%it was removed.  Leave the varargin here in case anyone was calling 
%the function with the third argument.

if isempty(xString)
    error(message('MATLAB:xmlstringinput:EmptyFilename'));
elseif ~isempty(strfind(xString,'://'))
    %xString is already a URL, most likely prefaced by file:// or http://
    out = xString;
    return;
end

if nargin<2 || isFullSearch
    if ~exist(xString,'file')
        %search to see if xString exists when isFullSearch
        error(message('MATLAB:xml:FileNotFound', xString));
    else
        out = which(xString);
        if isempty(out)
            out = xString;
        end
    end
else
    out = xString;
end

temp = java.io.File(out);

if ~temp.isAbsolute()
    out = fullfile(pwd,out);
end

%Return as a URN
if strncmp(out,'\\',2)
    % SAXON UNC filepaths need to look like file:///\\\server-name\
    out = ['file:///',out];
elseif strncmp(out,'/',1)
    % SAXON UNIX filepaths need to look like file:///root/dir/dir
    out = ['file://',out];
else
    % DOS filepaths need to look like file:///d:/foo/bar
    out = ['file:///',strrep(out,'\','/')];
end
