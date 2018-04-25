function [names, modified] = makeValidName(names, varargin)
%MATLAB.LANG.MAKEVALIDNAME constructs valid MATLAB identifiers from input S
%   N = MATLAB.LANG.MAKEVALIDNAME(S) returns valid identifiers, N,
%   constructed from the input S. S is specified as a character vector, a
%   cell array of character vectors, or a string array. The values in N are
%   NOT guaranteed to be unique.
%
%   A valid MATLAB identifier consists of alphanumerics and underscores,
%   such that the first character is a letter and the length is at most
%   NAMELENGTHMAX.
%   
%   MATLAB.LANG.MAKEVALIDNAME deletes whitespace characters prior to
%   replacing any characters that are not alphnumerics or underscores. If a
%   whitespace character is followed by a lowercase letter,
%   MATLAB.LANG.MAKEVALIDNAME converts the letter to the corresponding
%   uppercase character.
%
%   N = MATLAB.LANG.MAKEVALIDNAME(___, PARAM1, VAL1, PARAM2, VAL2, ...) 
%   constructs valid identifiers using additional options specified by one 
%   or more Name, Value pair arguments.
%
%   Parameters include:
%
%   'ReplacementStyle'         Controls how non-alphanumeric characters 
%                              are replaced. Valid values are 'underscore', 
%                              'hex', and 'delete'.
%
%                              'underscore' indicates non-alphanumeric
%                              characters are replaced with underscores.
%
%                              'hex' indicates each non-alphanumeric 
%                              character is replaced with a corresponding 
%                              hexadecimal representation.
%
%                              'delete' indicates all non-alphanumeric
%                              characters are deleted.
%
%                              The default 'ReplacementStyle' is 
%                              'underscore'.
%
%   'Prefix'                   Prepends the name when the first character 
%                              is not alphabetical. A valid prefix must
%                              start with a letter and contain only
%                              alphanumeric characters and underscores.
%
%                              The default 'Prefix' is 'x'.
%
%   [N, MODIFIED] = MATLAB.LANG.MAKEVALIDNAME(S, ___) also returns a
%   logical array the same size as S, MODIFIED, that denotes modified
%   elements.
%
%   Examples
%   --------
%   Make valid MATLAB identifiers from input character vectors
%
%       S = {'Item_#','Price/Unit','1st order','Contact'};
%       N = MATLAB.LANG.MAKEVALIDNAME(S)
%
%   returns the cell array {'Item__' 'Price_Unit' 'x1stOrder' 'Contact'}
%
%   Make valid MATLAB identifiers using specified replacement style
%
%       S = {'Item_#','Price/Unit','1st order','Contact'};
%       N = MATLAB.LANG.MAKEVALIDNAME(S, 'ReplacementStyle', 'delete')
%
%   returns the cell array {'Item_' 'PriceUnit' 'x1stOrder' 'Contact'}
%
%   See also MATLAB.LANG.MAKEUNIQUESTRINGS, ISVARNAME, ISKEYWORD, 
%            ISLETTER, NAMELENGTHMAX, WHO, STRREP, REGEXP, REGEXPREP

%   Copyright 2013-2017 The MathWorks, Inc.

% Parse optional inputs.
replacementStyle = "underscore";
prefix = 'x';
if nargin > 1
    [replacementStyle, prefix] = parseInputs(replacementStyle,prefix,varargin{:});
end

% NAMES must be char, cell array, or string array (with no missing values).
inputIsChar = false;
if ischar(names)
    inputIsChar = true;
    names = {names}; % Wrap char NAMES in a cell for algorithm convenience.
elseif iscell(names)
    % Deeper validation of each name is done below.
elseif ~isstring(names)
    error(message('MATLAB:makeValidName:InvalidCandidateNames'));
elseif any(ismissing(names(:)))
    error(message('MATLAB:makeValidName:MissingNames', ...
          getString(message('MATLAB:string:MissingDisplayText'))));
end

% Make all the names valid identifiers.
modified = false(size(names));
for idx = 1:numel(names)
    % NAMES is either a cell or string array by now. If it is a cell array,
    % we still need to verify that each name is a char row vector or ''.
    % In either case, extract one name with braces as a char row.
    name = names{idx};
    if iscell(names) && ~(ischar(name) && (isrow(name) || isequal(name,'')))
        error(message('MATLAB:makeValidName:InvalidCandidateNames'));
    end
    modified(idx) = ~isvarname(name);
end
if any(modified(:))
    % Get function handle to makeValid for the specified options.
    makeValidFcnHandle = getMakeValidFcnHandle(replacementStyle, prefix);
    names(modified) = makeValidFcnHandle(names(modified));
end

% Return NAMES as a char if it was input as one.
if inputIsChar
    names = names{1};
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%  Make Strings Valid  %%%%%%%%%%%%%%%%%%%%%%%%%%%
function makeValidFcnHandle = getMakeValidFcnHandle(replacementStyle, prefix)

invalidCharsRegExp = '[^a-zA-Z_0-9]';

    function name = replaceWithUnderscore(name)
        % Replace invalid characters with underscores.
        name = regexprep(name, invalidCharsRegExp, '_');
    end

    function name = deleteInvalidChars(name)
        % Delete invalid characters.
        name = regexprep(name, invalidCharsRegExp, '');
    end

    function name = replaceWithHex(name)
        % Replace invalid characters with their hex equivalent, 0x1234,
        % for compatibility with legacy GENVARNAME conversion scheme.
        illegalStringChars = regexp(name, invalidCharsRegExp, 'match', 'forceCellOutput');
        for elementIdx = 1:numel(illegalStringChars)
            illegalElementChars = unique(char(illegalStringChars{elementIdx}));
            illegalCharWidths = 2 + 2 * (illegalElementChars > intmax('uint8'));
            replacement = "0x" + arrayfun(@dec2hex, illegalElementChars, illegalCharWidths, 'UniformOutput', false);
            name(elementIdx) = replace(name(elementIdx), string(illegalElementChars), replacement);
        end
    end

    function name = makeValid(name, invalidReplacementFun)
        % Remove leading and trailing whitespace and
        % replace embedded whitespace with camel/mixed casing.
        whitespace = compose([" ", "\f", "\n", "\r", "\t", "\v"]);
        if any(contains(name, whitespace))
            name = regexprep(name, '(?<=\S)\s+([a-z])', '${upper($1)}');
            name = erase(name, whitespace);
        end
        
        % Replace invalid characters as specified by ReplacementStyle.
        name = invalidReplacementFun(name);
        
        % Prepend keyword with PREFIX and camel case.
        for keywordIdx = 1:numel(name)
            if iskeyword(name(keywordIdx))
                name{keywordIdx} = [prefix, upper(name{keywordIdx}(1)), ...
                                            lower(name{keywordIdx}(2:end))];
            end
        end
        
        % Insert PREFIX if the first column is non-letter.
        name = regexprep(name,'^(?![a-z])', prefix, 'emptymatch', 'ignorecase');
        
        % Truncate NAME to NAMLENGTHMAX.
        isTooLong = (strlength(name) > namelengthmax);
        if any(isTooLong)
            for isTooLongIdx = reshape(find(isTooLong), 1, [])
                name{isTooLongIdx} = name{isTooLongIdx}(1:namelengthmax);
            end
        end
    end

switch(replacementStyle)
case "underscore"
    makeValidFcnHandle = @(n)makeValid(n, @replaceWithUnderscore);
case "delete"
    makeValidFcnHandle = @(n)makeValid(n, @deleteInvalidChars);
otherwise
    assert(replacementStyle == "hex");
    makeValidFcnHandle = @(n)makeValid(n, @replaceWithHex);
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  INPUT PARSING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [replacementStyle, prefix] = parseInputs(defaultReplacementStyle, defaultPrefix, varargin)

persistent parser;
if isempty(parser)
    tParser = inputParser;
    tParser.FunctionName = 'matlab.lang.makeValidName';
    tParser.addParameter('ReplacementStyle', defaultReplacementStyle, @validateReplacementStyle);
    tParser.addParameter('Prefix', defaultPrefix, @validatePrefix);
    parser = tParser;
end

% Avoid error call stack into validator functions.
try
    parser.parse(varargin{:});
catch ME
    throwAsCaller(ME);
end

% Get input parameters from parser object.
replacementStyle = lower(parser.Results.ReplacementStyle);
prefix = char(parser.Results.Prefix);
end

function validateReplacementStyle(replacementStyle)
% ReplacementStyle can only be one of the three values.
if ~((ischar(replacementStyle) && isrow(replacementStyle)) || ...
     (isstring(replacementStyle) && isscalar(replacementStyle))) || ...
   ~any(lower(replacementStyle) == ["delete", "hex", "underscore"])
    error(message('MATLAB:makeValidName:InvalidReplacementStyle'));
end
end

function validatePrefix(prefix)
% Prefix itself has to be valid MATLAB identifiers.
if strlength(prefix) > namelengthmax
    error(message('MATLAB:makeValidName:TooLongPrefix'));
elseif ~isvarname(prefix)
    error(message('MATLAB:makeValidName:InvalidPrefix'));
end
end
