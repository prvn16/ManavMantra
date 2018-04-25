function c = cellstr(s)
%CELLSTR Create cell array of character vectors
%   C = CELLSTR(S) converts S to a cell array of character vectors.
%   If S is a string array, then CELLSTR converts each element of S.
%   If S is a character array, then CELLSTR places each row into a
%   separate cell of C. Any trailing spaces in the character vectors are 
%   removed.
%
%   Use STRING to convert C to a string array, or CHAR to convert C
%   to a character array.
%
%   Another way to create a cell array of character vectors is by using 
%   curly braces:
%      C = {'hello' 'yes' 'no' 'goodbye'};
%
%   See also STRING, CHAR, ISCELLSTR.

%   Copyright 1984-2016 The MathWorks, Inc.

if ischar(s)
    if isempty(s)
        c = {''};
    elseif ~ismatrix(s)
        error(message('MATLAB:cellstr:InputShape'))
    else
        numrows = size(s,1);
        c = cell(numrows,1);
        for i = 1:numrows
            c{i} = s(i,:);
        end
        c = deblank(c);
    end
elseif iscellstr(s)
    c = s;
elseif iscell(s)
    c = cell(size(s));
    for i=1:numel(s)
        if ischar(s{i}) || (isstring(s{i}) && isscalar(s{i}) && ~ismissing(s{i}))
            c{i} = char(s{i});
        else
            if (isstring(s{i}) && isscalar(s{i})) && ismissing(s{i})
                error(message('MATLAB:string:CannotConvertMissingElementToChar', i));
            else
                error(message('MATLAB:cellstr:MustContainText', i));
            end
        end
    end
else
    error(message('MATLAB:invalidConversion', 'cellstr', class(s)));
end
