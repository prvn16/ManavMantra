function s = strip(str, varargin)
%STRIP Remove leading and trailing whitespaces
%   NEWSTR = STRIP(STR) removes all consecutive whitespace characters from
%   the beginning and the end of STR. Whitespace is defined as any sequence
%   of whitespace characters such as spaces, tabs, and newlines.
%
%   STR can be a string array, character vector, or cell array of character
%   vectors. If STR is a string array or cell array, then STRIP removes
%   leading and trailing whitespace from each element of STR.
%
%   NEWSTR = STRIP(STR,SIDE) removes whitespace characters from the
%   specified SIDE. SIDE can be 'left', 'right', or 'both'.  The default
%   value of SIDE is 'both'.
%
%   NEWSTR = STRIP(STR,PAD_CHARACTER) removes PAD_CHARACTER from STR.
%   PAD_CHARACTER must be exactly one character.
% 
%   NEWSTR = STRIP(STR,SIDE,PAD_CHARACTER) removes PAD_CHARACTER from the
%   specified SIDE.
% 
%   Example:
%
%       STR = ["moustache "; 
%              "   goatee";
%              "   beard    "];
%       strip(STR)
%
%       returns
%
%           "moustache"
%           "goatee"
%           "beard"
%
%   Example:
%       strip("C:\Temp\Files\",'right','\')
%
%       returns
%
%           "C:\Temp\Files"
%       
%   See also PAD, STRING, REPLACE

%   Copyright 2016 The MathWorks, Inc.

    narginchk(1, 3);
    
    if ~isTextStrict(str)
        firstInput = getString(message('MATLAB:string:FirstInput'));
        error(message('MATLAB:string:MustBeCharCellArrayOrString', firstInput));
    end

    try
        s = string(str);
        
        if nargin == 1
            s = s.strip();
        else
            s = s.strip(varargin{:});
        end
        
        s = convertStringToOriginalTextType(s, str);
        
    catch E
        throw(E)
    end
end
