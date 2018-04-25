%TYPE List program file.
%   TYPE foo.bar lists the ascii file called 'foo.bar'.
%   TYPE foo lists the ascii file called 'foo.m'. 
%
%   If files called foo and foo.m both exist, then
%      TYPE foo lists the file 'foo', and
%      TYPE foo.m lists the file 'foo.m'.
%
%   TYPE PATHNAME/FUN lists the contents of FUN (or FUN.m) 
%   given a full pathname or a MATLABPATH relative partial 
%   pathname (see PARTIALPATH).
%
%   See also DBTYPE, WHICH, HELP, PARTIALPATH, MORE.

%   Copyright 1984-2010 The MathWorks, Inc.
%   Built-in function.
