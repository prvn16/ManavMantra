function s = replaceBetween(str, start, stop, value, varargin)
% REPLACEBETWEEN Replace bounded substring in string elements
%    S = REPLACEBETWEEN(STR, START_STR, END_STR, NEW_TEXT) replaces the
%    substring in STR that occurs between START_STR and END_STR with
%    NEW_TEXT but does not replace START_STR and END_STR themselves. If
%    multiple nonoverlapping START_STR and END_STR pairs are found, the
%    characters between each pair are replaced.
% 
%    S = REPLACEBETWEEN(STR, START_POS, END_POS, NEW_TEXT) replaces the
%    substrings in STR that occur between numeric positions START_POS and
%    END_POS, including the characters at those positions, with NEW_TEXT.
%    START_POS and END_POS must be integers between 1 and the number of
%    characters in STR. If START_POS and END_POS are the same number, then
%    REPLACEBETWEEN replaces the character at START_POS. If END_POS equals
%    START_POS - 1, then REPLACEBETWEEN does not replace any characters but
%    does insert NEW_TEXT between START_POS and END_POS.
%
%    NOTES: 
%    * STR, START_STR, END_STR, and NEW_TEXT can be string arrays, character vectors,
%      or cell arrays of character vectors. The output S has the same data
%      type as STR.
% 
%    * START_STR and END_STR are an open set (i.e., bounds
%      are included in the output) while the START_POS and END_POS numeric
%      positions are a closed set (i.e., bounds are not included in the
%      output).
%
%    * Position and string bounds can be mixed.  Their inclusivity persists
%      with the argument type.
%
%    S = REPLACEBETWEEN(..., 'Boundaries', B) forces the bounds to be
%    inclusive when B is 'inclusive' and forces the bounds to be exclusive
%    when B is 'exclusive'.
%
%    If B is 'exclusive' and you specify numeric bounds, then START_POS and
%    END_POS can be integers between 0 and strlength(STR) + 1.
%
%    Example:
%        str = "The quick brown fox jumps";
%        replaceBetween(str,'quick','fox', ' red ')
%
%        returns 
%
%            "The quick red fox jumps"
%
%        STR = 'The quick brown fox jumps over the lazy dog';
%        replaceBetween(STR,'jumps','lazy','sneaks by the sleeping',...
%                       'Boundaries','inclusive')
%
%        returns
%
%            'The quick brown fox sneaks by the sleeping dog'        
%
%    See also REPLACE, ERASE, ERASEBETWEEN, EXTRACTBETWEEN

%   Copyright 2016-2017 The MathWorks, Inc.

    narginchk(4, Inf);
    
    if ~isTextStrict(str)
        error(fillMessageHoles('MATLAB:string:MustBeCharCellArrayOrString',...
                               'MATLAB:string:FirstInput'));
    end

    try
        s = string(str);
        
        if nargin == 4
            s = s.replaceBetween(start, stop, value);
        else
            s = s.replaceBetween(start, stop, value, varargin{:});
        end
        
        s = convertStringToOriginalTextType(s, str);
        
    catch ex
        if strcmp(ex.identifier, 'MATLAB:string:CannotConvertMissingElementToChar')
            error(fillMessageHoles('MATLAB:string:CannotInsertMissingIntoChar',...
                                   'MATLAB:string:MissingDisplayText'));
        end
        ex.throw;
    end
end
