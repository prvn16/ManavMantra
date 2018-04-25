function rev = reverse(s)
%REVERSE Reverse the order of characters in string
%   NEWSTR = REVERSE(STR) reverses the order of the characters in each
%   element of STR and returns the reversed elements as NEWSTR. STR can be
%   a string array, character vector, or cell array of character vectors.
%   NEWSTR is the same type as STR.
%
%   REVERSE does not reverse the order of code units within Unicode
%   characters.
%
%   Example:
%       STR = ["airport","control tower","radar","runway"];
%       reverse(STR)
%
%       returns
%
%           "tropria"    "rewot lortnoc"    "radar"    "yawnur"
%
%       STR = 'Hello World';
%       reverse(STR)
%
%       returns
%
%           'dlroW olleH'
%
%   See also FLIP, FLIPLR, RESHAPE, UPPER, LOWER

%   Copyright 2015-2017 The MathWorks, Inc.

    narginchk(1, 1);

    try
        if iscell(s)
            rev = cell(size(s));
            for idx = 1:numel(s)
                rev{idx} = charReverse(s{idx});
            end
        else
            rev = charReverse(s);
        end
    catch E
        throw(E)
    end
end

function crev = charReverse(s)

    if ~ischar(s) || (~isempty(s) && ~isrow(s))
        firstInput = getString(message('MATLAB:string:FirstInput'));
        error(message('MATLAB:string:MustBeCharCellArrayOrString', firstInput));
    end
    crev = fliplr(s);

end
