function out = fieldnames(obj, ~)
%FIELDNAMES Get timer object property names.
%
%    NAMES = FIELDNAMES(OBJ) returns a cell array of character vectors containing the
%    names of the properties associated with timer object, OBJ. OBJ must be a 1-by-1
%    timer object.
%
%    NAMES = FIELDNAMES(OBJ, FLAG) returns the same cell array as the previous syntax
%    and is provided for backwards compatibility.

%    Copyright 2001-2016 The MathWorks, Inc.

% Error checking.
if ~isa(obj, 'timer')
    error(message('MATLAB:timer:noTimerObj'));
end

% Ignore the FLAG input for now until we decide what to do 
% for the '-full' option.
out = fieldnames(obj.getJobjects);
