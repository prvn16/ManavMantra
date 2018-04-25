function tokens = tokenize( input_string, delimiters )
%TOKENIZE  Divide a string into tokens.
%   TOKENS = TOKENIZE(STRING, DELIMITERS) divides STRING into tokens
%   using the characters in the string DELIMITERS. The result is stored
%   in a single-column cell array of strings.
%
%   Examples: 
%
%   tokenize('The quick fox jumped',' ') returns {'The'; 'quick'; 'fox'; 'jumped'}.
%
%   tokenize('Ann, Barry, Charlie',' ,') returns {'Ann'; 'Barry'; 'Charlie'}.
%
%   tokenize('George E. Forsyth,Michael A. Malcolm,Cleve B. Moler',',') returns
%   {'George E. Forsyth'; 'Michael A. Malcolm'; 'Cleve B. Moler'}

%   Copyright 1993-2015 The MathWorks, Inc.

if (~isempty(input_string))
    C = textscan(input_string,'%s',-1,'delimiter',delimiters);
    tokens = C{1};
else
    tokens = {};
end
