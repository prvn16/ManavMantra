function s=str2mat(varargin)
%STR2MAT Form blank padded character array from text representations of numbers
%   S = STR2MAT(T1,T2,T3,..) forms the character array S containing the text
%   from T1,T2,T3,... as rows.  STR2MAT automatically pads each row with
%   space in order to form a valid character array.  Each text parameter, Ti,
%   can itself be a character array or a string scalar.  This allows the creation of
%   arbitrarily large character arrays.  If Ti has no characters, the
%   corresponding row of S is filled with spaces.
%
%   STR2MAT differs from STRVCAT in that input arguments that contain no characters 
%   produce blank rows in the output.  STRVCAT ignores input arguments that contain no
%   characters.
%
%   STR2MAT is not recommended. Use CHAR instead.
%
%   See also CHAR, STRVCAT.

%   Clay M. Thompson  3-20-91, 5-16-95
%   Copyright 1984-2016 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

s = char(varargin{:});
