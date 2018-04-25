function [str,msg] = variableEditorSetDataCode(a,varname,row,col,rhs)
% These functions are for internal use only and will change in a
% future release.  Do not use this function.

% Generate MATLAB command to edit the content of a cell to the specified
% rhs.

%   Copyright 2013-2015 The MathWorks, Inc.

msg = '';
if col>size(a,2)+1
    msg = getString(message('MATLAB:categorical:VarEditorIndexOverFlow'));
    % msg = Categorical arrays may not have empty columns, so data may only be added immediately to the right of existing variables.\nA new categorical variable will be added in the next available column.
    col = size(a,2)+1;
end
% Double any quotes so they act as single quotes when rhs is itself put between
% quotes in the generated code.
rhs = strrep(rhs,'''','''''');
str =  [varname '(' num2str(row) ',' num2str(col) ') = ''' rhs ''';'];
