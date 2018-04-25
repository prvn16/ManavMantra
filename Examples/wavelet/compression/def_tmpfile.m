function tmp_filename  = def_tmpfile(filename)
%DEF_TMPFILE Define a temporary filename for compression methods.
%

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jun-2004.
%   Last Revision: 05-Apr-2008.
%   Copyright 1995-2008 The MathWorks, Inc.

[pathSTR,nameSTR,extSTR] = fileparts(filename);
tmp_filename = ['TMP_WTC_' nameSTR , extSTR];
if ~isempty(pathSTR)
    tmp_filename = [pathSTR , filesep, tmp_filename];
end
