function s = rmfield(s,field)
%RMFIELD Remove fields from a structure array.
%   S = RMFIELD(S,FIELD) removes the field specified by FIELD from the 
%   m x n structure array S. For example, S = RMFIELD(S,'a') removes the field
%   'a' from S. The size of input S is preserved.
%
%   S = RMFIELD(S,FIELDS) removes more than one field at a time when FIELDS
%   is a string, character array or cell array of character vectors. The
%   changed structure is returned. The size of input S is preserved.
%
%   See also SETFIELD, GETFIELD, ISFIELD, FIELDNAMES.

%   Copyright 1984-2017 The MathWorks, Inc.

%--------------------------------------------------------------------------------------------
% handle input arguments


if ~isa(s,'struct')
    error(message('MATLAB:rmfield:Arg1NotStructArray'));
end

field = convertStringsToChars(field);

if iscell(field) && isempty(field)
    % No fields to remove
    return
end

if ~ischar(field) && ~iscellstr(field)
    error(message('MATLAB:rmfield:FieldnamesNotStrings'));
end

if ischar(field) && ~isrow(field)
    % converts char matrix to cell-str but leave char vector alone
    field = cellstr(field);
end

% get fieldnames of struct
f = fieldnames(s);
% Determine which fieldnames to delete.
if ischar(field) || isscalar(field)
    % shortcut for single field.
    nonexistent = [];
    toRemove = strcmp(deblank(field),f);
    if ~any(toRemove)
        nonexistent = find(~toRemove,1);
    end
elseif numel(f) < 100 && numel(field) < 10
    % faster for small number of fields
    [toRemove,nonexistent] = smallcase(f,field);
else
    % faster for large number of fields.
    [toRemove,nonexistent] = generalcase(f,field);
end

% If any given fields were not found, throw an error
if ~isempty(nonexistent)
    field = cellstr(field);
    name = field{nonexistent};
    % Make sure the given non-existent field name does not exceed max length
    if length(name) > namelengthmax
        error(message('MATLAB:rmfield:FieldnameTooLong', name));
    else
        error(message('MATLAB:rmfield:InvalidFieldname', name));
    end
end

% convert struct to cell array
c = struct2cell(s);

% find size of cell array
sz = size(c);

% adjust size for fields to be removed
sz(1) = sz(1) - nnz(toRemove);

% rebuild struct
s = cell2struct(reshape(c(~toRemove,:),sz),f(~toRemove));
%--------------------------------------------------------------------------------------------
end

function [toRemove,nonexistent] = smallcase(f,field)
field = deblank(field);
nonexistent = [];
toRemove = false(size(f));
for j = 1:numel(field)
    match = strcmp(field{j},f);
    if ~any(match(:))
        nonexistent = j;
        break;
    end
    toRemove(match) = true;
end
end

function [toRemove,nonexistent] = generalcase(f,field)
field = deblank(field);
nonexistent = [];
[~,idx] = ismember(field,f);
toRemove = false(size(f));
if any(idx==0)
    % used in the error case
    nonexistent = find(idx==0,1);
else
    toRemove(idx) = true;
end
end