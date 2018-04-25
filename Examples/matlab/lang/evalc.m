%EVALC Evaluate MATLAB expression with capture.
%   T = EVALC(S) is the same as EVAL(S) except that anything that would
%   normally be written to the command window, except for error messages,
%   is captured and returned in the character array T (lines in T are 
%   separated by '\n' characters).  
%
%   [T,X,Y,Z,...] = EVALC(S) is the same as [X,Y,Z,...] = EVAL(S) except
%   that any output is captured into T.
%
%   Note: While in evalc, DIARY, MORE and INPUT are disabled.
%
%   See also EVAL, EVALIN, DIARY, MORE, INPUT.

%   Copyright 1984-2007 The MathWorks, Inc.
