function s = extractBetween(str, start, stop, varargin)
% EXTRACTBETWEEN Extract substring from text
%    S = EXTRACTBETWEEN(STR, START_STR, END_STR) returns the substring of
%    STR that occurs between START_STR and END_STR but does not include
%    either START_STR and END_STR. If multiple nonoverlapping START_STR
%    END_STR pairs are found in STR, S grows along the first trailing
%    dimension whose size is 1 and the text between each pair is returned.
% 
%    S = EXTRACTBETWEEN(STR, START_POS, END_POS) returns a substring of STR
%    that starts at numeric position START_POS and ends at numeric position
%    END_POS. START_POS and END_POS must be integers between 1 and the
%    number of characters in STR. The substring S includes the characters
%    at those positions. If START_POS and END_POS are the same number, then
%    S contains the character at START_POS. If END_POS equals START_POS - 1,
%    then S is the empty string.
% 
%    NOTES:
%    * STR, START_STR, and END_STR can be string arrays, character vectors,
%      or cell arrays of character vectors. If STR is a string array, then
%      so is the output S. Otherwise, S is a cell array of character
%      vectors.
%
%    * START_STR and END_STR are an open set (i.e., bounds
%      are not included in the output) while the START_POS and END_POS
%      numeric positions are a closed set (i.e., bounds are included in the
%      output).
% 
%    * Position and string bounds can be mixed. Their inclusivity persists
%      with the argument type.
%
%    S = EXTRACTBETWEEN(..., 'Boundaries', B) forces the bounds to be
%    inclusive when B is 'inclusive' and forces the bounds to be exclusive
%    when B is 'exclusive'.
%
%    If B is 'exclusive' and you specify numeric bounds, then START_POS and
%    END_POS can be integers between 0 and strlength(STR) + 1.
%
%    Example:
%        STR = "The quick brown fox"; 
%        extractBetween(str,'quick ',' fox')
%
%        returns
%
%            "brown"
%
%        STR = 'The quick brown fox jumps over the lazy dog';
%        extractBetween(STR,'brown','lazy','Boundaries','inclusive')
%
%        returns
%
%            'brown fox jumps over the lazy'
%
%    See also ERASEBETWEEN, REPLACEBETWEEN, EXTRACTBEFORE, EXTRACTAFTER

%   Copyright 2016-2017 The MathWorks, Inc.

    narginchk(3, Inf);
    if ~isTextStrict(str)
        firstInput = getString(message('MATLAB:string:FirstInput'));
        error(message('MATLAB:string:MustBeCharCellArrayOrString', firstInput));
    end

    try
        s = string(str);
        s = s.extractBetween(start, stop, varargin{:});
        
        if ~isstring(str)
            s = cellstr(s);
        end
        
    catch E
        throw(E);
    end
end
