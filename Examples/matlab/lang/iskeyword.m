function L = iskeyword(s)
%ISKEYWORD Check if input is a keyword.
%   ISKEYWORD(S) returns one if S is a MATLAB keyword,
%   and 0 otherwise.  MATLAB keywords cannot be used 
%   as variable names.
%
%   ISKEYWORD used without any inputs returns a cell array containing
%   the MATLAB keywords.
%
%   See also ISVARNAME, MATLAB.LANG.MAKEVALIDNAME

%   Copyright 1984-2016 The MathWorks, Inc.

L = {...
    'break'
    'case'
    'catch'
    'classdef'
    'continue'
    'else'
    'elseif'
    'end'
    'for'
    'function'
    'global'
    'if'
    'otherwise'
    'parfor'
    'persistent'
    'return'
    'spmd'
    'switch'
    'try'
    'while'
    };

if nargin==0
    %  Return the list only
    return
else
    try
        L = any(strcmp(s,L));
    catch
        L = false;
    end
end
