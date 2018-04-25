function varargout = type_nocomments(fname, s, begincomment, endcomment)
%TYPE_NOCOMMENTS List file with no comments
%   TYPE_NOCOMMENTS foo or TYPE_NOCOMMENTS foo.m lists the ascii file
%   called 'foo.m' with no MATLAB-style comments (% to the end of line).
%
%   TYPE_NOCOMMENTS foo.c or TYPE_NOCOMMENTS foo.h lists the ascii file
%   called 'foo.c' or 'foo.h' with no C-style comments (between /* and */).
%
%   TYPE_NOCOMMENTS foo.cpp or TYPE_NOCOMMENTS foo.hpp lists the ascii file
%   called 'foo.cpp' or 'foo.hpp' with no C++-style comments
%   (between /* and */ or // to the end of line).
%
%   Examples:
%     type_nocomments blkdiag
%
%     type_nocomments([matlabroot ,'/extern/examples/mex/yprime.c'])
%
%   See also TYPE, DBTYPE, TYPE_NOCOMMENTS_NOSUBFUNCTIONS.

%   Thomas A. Bryan, 30 December 2004
%   Copyright 2004-2011 The MathWorks, Inc.
%   
newline = sprintf('\n');
cr = sprintf('\r');
backspace = sprintf('\b');

if isempty(strfind(fname,'.'))
  % Assume a file name with no extension is a MATLAB file
  fname = [fname,'.m'];
end
if nargin<4
  if ~isempty(strfind(fname,'.c')) || ~isempty(strfind(fname,'.h')) % C or CPP
    begincomment = '/\*';
    endcomment   = '\*/';
  elseif (length(fname)>2 && strcmpi(fname(end-1:end),'.m'))
    begincomment = '%';
    endcomment = newline;
  else
    error('type_nocomments doesn''t know how to handle this type of file')
  end
  fid = fopen(fname,'r');
  if fid<1
    error(['File ',fname,' not found.'])
  end
  s = char(fread(fid));
  fclose(fid);
  s = reshape(s,1,length(s));
end
s(strfind(s,cr)) = ''; % get rid of carriage returns


% Remove comments
s = regexprep(s,[begincomment '.*?' endcomment], newline);

% Remove blanks at the end of lines
s = regexprep(s,' *?\n','\n');

% Remove repeated newlines
eol=strfind(s, newline);
dupeol = eol(diff(eol)==1);
s(dupeol) = '';
if strcmp(s(1),newline)
  s = s(2:end);
end

if nargin==1 && ...
    (~isempty(strfind(fname,'.cpp')) || ...
    ~isempty(strfind(fname,'.hpp')) )
  % Make one more pass for C++
  begincomment = '//';
  endcomment = newline;
  type_nocomments(fname,s,begincomment,endcomment);
elseif nargout==0
  if strcmp(s(end),newline)
    s(end)='';
  end
  disp(s)
end

if nargout>0
  varargout{1}=s;
end
