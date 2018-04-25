function s = join(str, varargin)
% JOIN Append elements of a string array together
%    NEWSTR = JOIN(STR) appends the elements of STR, placing a space
%    character between consecutive strings, and returns the result as the
%    output array NEWSTR. JOIN combines strings along the last dimension of
%    STR not equal to 1. STR can be a string array, a character vector, or
%    a cell array of character vectors. NEWSTR has the same data type as
%    STR. If STR is a character vector, then STR and NEWSTR are identical.
%
%    NEWSTR = JOIN(STR,DELIMITER) appends the elements of STR and places
%    elements of DELIMITER between them. If STR and DELIMITER are string
%    arrays or cell arrays, then DELIMITER must have one element less than
%    STR along the dimension being joined. The size of every other
%    dimension of DELIMITER either must be 1 or must match the size of the
%    corresponding dimension of STR. The space character is the default
%    value of DELIMITER.
% 
%    NEWSTR = JOIN(STR,DIM) appends the elements of STR along the dimension
%    DIM. The default value of DIM is the last dimension of STR with a size
%    that does not equal 1.
% 
%    NEWSTR = JOIN(STR,DELIMITER,DIM) appends the elements of STR along
%    the dimension DIM and places elements of DELIMITER between the
%    strings.
%
%    Example:
%        STR = ["John","Smith";"Mary","Jones"];
%        join(STR)
%    
%    returns
%
%        "John Smith"
%        "Mary Jones"
%
%    Example:
%        STR = {'John','Smith';'Mary','Jones'};
%        join(STR,1)
%
%    returns
%
%        'John Mary'    'Smith Jones'
%
%    Example:
%        STR = ["x","y","z";"a","b","c"];
%        DELIMITER = {' + ',' = ';' - ',' = '};
%        join(STR,DELIMITER)
%
%    returns
%
%        "x + y = z"
%        "a - b = c"    
%
%    See also SPLIT, STRING/PLUS, COMPOSE

%   Copyright 2015-2017 The MathWorks, Inc.

    narginchk(1, 3);
    if ~isTextStrict(str)
        firstInput = getString(message('MATLAB:string:FirstInput'));
        error(message('MATLAB:string:MustBeCharCellArrayOrString', firstInput));
    end
    
    try
        if ischar(str)
            s = str;
        else
            s = string(str);
            s = s.join(varargin{:});

            if ~isstring(str)
                s = cellstr(s);
            end
        end
        
    catch E
        throw(E);
    end
end
