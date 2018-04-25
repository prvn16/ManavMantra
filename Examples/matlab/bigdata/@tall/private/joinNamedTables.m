function C = joinNamedTables(fcn, dummyA, dummyB, Aname, Bname, varargin)
% Apply a join function to two named tables.
%
% Syntax:
%  C = joinNamedTables(fcn,A,B,Aname,Bname,name1,value1,name2,value2,...)
%
% This exists to work-around the usage of inputname in tabular join
% methods. It works by using variables named 'dummyA' and 'dummyB', these
% names are used as proxies for the actual table names and replaced later.

%   Copyright 2017 The MathWorks, Inc.

if isempty(Aname)
    Aname = getString(message('MATLAB:table:uistrings:JoinLeftVarSuffix'));
end
if isempty(Bname)
    Bname = getString(message('MATLAB:table:uistrings:JoinRightVarSuffix'));
end

% We have to escape any usage of the word 'dummy' to ensure we don't modify
% any actual table variable names containing 'dummyA' or 'dummyB'.
dummyA.Properties.VariableNames = iEscapeDummy(dummyA.Properties.VariableNames);
dummyA.Properties.DimensionNames = iEscapeDummy(dummyA.Properties.DimensionNames);
dummyB.Properties.VariableNames = iEscapeDummy(dummyB.Properties.VariableNames);
dummyB.Properties.DimensionNames = iEscapeDummy(dummyB.Properties.DimensionNames);
Aname = iEscapeDummy(Aname);
Bname = iEscapeDummy(Bname);
varargin = cellfun(@iEscapeDummy, varargin, 'UniformOutput', false);

try
    C = fcn(dummyA, dummyB, varargin{:});
catch err
    % Variable names might show up in error messages, we need to undo any
    % escape of word 'dummy'.
    if contains(err.message, 'dummy')
        err = MException(err.identifier, iUnescapeDummy(err.message));
    end
    throw(err);
end

varNames = C.Properties.VariableNames;
isModifiedFromA = contains(varNames, 'dummyA');
isModifiedFromB = contains(varNames, 'dummyB');

% First undo all string manipulation we did to the input.
varNames = strrep(varNames, 'dummyA', Aname);
varNames = strrep(varNames, 'dummyB', Bname);
varNames = iUnescapeDummy(varNames);
% Now deal with the fallout. There is a rare chance of duplicate variable
% names at this point because 'var_Aname' or 'var_Bname' already existed.
% Join deals with this using the standard uniquify tools.
varNames = matlab.lang.makeUniqueStrings(varNames, isModifiedFromA);
varNames = matlab.lang.makeUniqueStrings(varNames, isModifiedFromB);
C.Properties.VariableNames = varNames;
C.Properties.DimensionNames = iUnescapeDummy(C.Properties.DimensionNames);
end

function str = iEscapeDummy(str)
% Escape all usage of the word 'dummy' in the input. This ignores
% non-strings in-case any of the varargin input contains those.
if ischar(str) || isstring(str) || iscellstr(str)
    str = strrep(str, 'dummy', 'dummyEscape');
end
end

function str = iUnescapeDummy(str)
% Undo any escape of the word 'dummy'.
str = strrep(str, 'dummyEscape', 'dummy');
end
