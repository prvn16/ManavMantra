function  N = getpartnames(Set_of_Part)
%GETPARTNAMES Get partition names in an array of WPARTOBJ objects.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 31-May-2006.
%   Last Revision: 26-Sep-2006.
%   Copyright 1995-2006 The MathWorks, Inc.

N = struct(Set_of_Part(:));
N = {N(:).Name}';