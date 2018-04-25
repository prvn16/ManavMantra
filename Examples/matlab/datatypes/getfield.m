function f = getfield(s,varargin)
%GETFIELD Get structure field contents.
%   F = GETFIELD(S,FIELD) returns the contents of the specified field. For
%   example, if S.a = 1, then getfield(S,'a') returns 1. FIELD can be a
%   character vector or string scalar.
%
%   This syntax is recommended only when S is a scalar structure. If S is a
%   structure array, then GETFIELD(S,FIELD) returns the contents of the
%   field from the first element of S only. For example, if S(1).a = 1 and
%   S(2).a = 2, then getfield(S,'a') returns 1.
%
%   F = GETFIELD(S,{i,j,...},FIELD) returns field contents from element
%   S(i,j,...). It is equivalent to the syntax F = S(i,j,...).FIELD.
%
%   For example, if S(1).a = 1 and S(2).a = [2 3 4], then getfield(S,{2},'a') 
%   returns the array [2 3 4].
%
%   F = GETFIELD(S,{i,j,...},FIELD,{k,l,...}) indexes into the specified
%   field of S(i,j,...). It is equivalent to the syntax F = S(i,j,...).FIELD(k,l,...).
%
%   For example, if S(1).a = 1 and S(2).a = [2 3 4], then getfield(S,{2},'a',{3})
%   returns 4.
%
%   F = GETFIELD(S,{i,j,...},FIELD,{k,l,...}, ...) indexes into S when
%   S is a nested structure array of arbitrary depth. You can specify
%   additional field names and indices to access contents at the level you
%   specify.
%
%   For example, specify a nested structure and access its contents.
%
%   S.a.c = 1;
%   S.b.d = 2;
%   S(2).a.c = 5;
%   S(2).b.d = [10 15 20];
%
%   You can access the third element of S(2).b.d using GETFIELD, which
%   returns 20.
%
%   getfield(S,{1,2},'b','d',{3})
%
%   For improved performance, when getting the value of a simple 
%   field, use <a href="matlab:helpview([docroot '/techdoc/matlab_prog/matlab_prog.map'],'dynamic_field_names')">dynamic field names</a>.
%
%   See also SETFIELD, ISFIELD, FIELDNAMES, ORDERFIELDS, RMFIELD.
 
%   Copyright 1984-2017 The MathWorks, Inc.

% Check for sufficient inputs
if (isempty(varargin))
    error(message('MATLAB:getfield:InsufficientInputs'))
end

% The most common case
field = convertStringsToChars(varargin{1});
if (length(varargin)==1 && ischar(field))
    field = deblank(field);
    f = s.(field);
    return
end

f = s;
for i = 1:length(varargin)
    subscript = convertStringsToChars(varargin{i});
    if (isa(subscript, 'cell')) % For getfield(S,{i,j},...) syntax
        f = f(subscript{:});
    elseif ischar(subscript)
        % Always return first element (even for comma separated list result)
        field = deblank(subscript);
        f = f.(field);
    else
        error(message('MATLAB:getfield:InvalidType'));
    end
end