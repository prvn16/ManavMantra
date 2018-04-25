function varargout = type_nocomments_nosubfunctions(fname)
%TYPE_NOCOMMENTS_NOSUBFUNCTIONS List file with no comments
%   TYPE_NOCOMMENTS_NOSUBFUNCTIONS foo,  or 
%   TYPE_NOCOMMENTS_NOSUBFUNCTIONS foo.m lists the ascii file called
%   'foo.m' with no MATLAB-style comments (% to the end of line).  Only
%   the first function in the file is listed.  No subfunctions are
%   listed.
%
%   Examples:
%     type_nocomments_nosubfunctions fi_radix2fft_withscaling
%
%   See also TYPE, DBTYPE, TYPE_NOCOMMENTS.

%   Thomas A. Bryan, 30 December 2004
%   Copyright 2004-2011 The MathWorks, Inc.
%   

s=fidemo.type_nocomments(fname);

subfun = strfind(s,'function');

if length(subfun)>1
  s(subfun(2):end) = '';
end

if nargout==0
  disp(s)
else
  varargout{1}=s;
end
