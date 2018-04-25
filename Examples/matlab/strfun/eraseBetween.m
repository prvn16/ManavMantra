function s = eraseBetween(str, start, stop, varargin)
% ERASEBETWEEN Remove substring from text
%    S = ERASEBETWEEN(STR, START_STR, END_STR) removes the substring of STR
%    that occurs between START_STR and END_STR but does not remove
%    START_STR and END_STR themselves. If multiple nonoverlapping
%    START_STR and END_STR pairs are found in STR, the characters between
%    each pair are removed.
% 
%    S = ERASEBETWEEN(STR, START_POS, END_POS) removes the substring of STR
%    from numeric position START_POS to numeric position END_POS, including
%    the characters at those positions. START_POS and END_POS must be
%    integers between 1 and the number of characters in STR. If START_POS
%    and END_POS are the same number, then ERASEBETWEEN removes the
%    character at START_POS. If END_POS equals START_POS - 1, then
%    ERASEBETWEEN does not remove any characters.
% 
%    NOTES:
%    * STR, START_STR, and END_STR can be string arrays, character vectors,
%      or cell arrays of character vectors. The output S has the same data
%      type as STR.
%
%    * START_STR and END_STR are an open set (i.e., bounds are
%      included in the output) while the START and END numeric positions
%      are a closed set (i.e., bounds are not included in the output).
% 
%    * Position and string bounds can be mixed. Their inclusivity persists
%      with the argument type.
%
%    S = ERASEBETWEEN(..., 'Boundaries', B) forces the bounds to be
%    inclusive when B is 'inclusive' and forces the bounds to be exclusive
%    when B is 'exclusive'.
%
%    If B is 'exclusive' and you specify numeric bounds, then START_POS and
%    END_POS can be integers between 0 and strlength(STR) + 1.
%
%    Examples:
%        STR = "The quick brown fox"; 
%        eraseBetween(STR,'quick',' fox')
%
%        returns
%
%            "The quick fox"
%
%        STR = 'The quick brown fox jumps over the lazy dog';
%        eraseBetween(STR,' brown','lazy','Boundaries','inclusive')
%
%        returns
%
%            'The quick dog'
%
%    See also ERASE, EXTRACTBETWEEN, REPLACEBETWEEN, EXTRACTBEFORE,
%    EXTRACTAFTER

%   Copyright 2016-2017 The MathWorks, Inc.

    narginchk(3, Inf);
    
    if ~isTextStrict(str)
        firstInput = getString(message('MATLAB:string:FirstInput'));
        error(message('MATLAB:string:MustBeCharCellArrayOrString', firstInput));
    end

    try
        s = string(str);
        
        if nargin == 3
            s = s.eraseBetween(start, stop);
        else
            s = s.eraseBetween(start, stop, varargin{:});
        end
        
        s = convertStringToOriginalTextType(s, str);
        
    catch E
        throw(E);
    end
end
