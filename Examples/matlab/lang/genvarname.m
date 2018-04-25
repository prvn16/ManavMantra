function varname = genvarname(candidate, protected)
%GENVARNAME will be removed in a future release. Use MATLAB.LANG.MAKEVALIDNAME and MATLAB.LANG.MAKEUNIQUESTRINGS instead.
%GENVARNAME Construct a valid MATLAB variable name from a given candidate.
%   VARNAME = GENVARNAME(CANDIDATE) returns a valid variable name VARNAME
%   constructed from CANDIDATE.  CANDIDATE can be a character vector, a
%   cell array of character vectors, or a string array.
%
%   A valid MATLAB variable name consists of alphanumerics and underscores,
%   such that the first character is a letter and the length is at most
%   NAMELENGTHMAX.
%
%   If CANDIDATE is a cell or string array, the resulting elements of the
%   VARNAME array are guaranteed to be unique from one another.
%
%   VARNAME = GENVARNAME(CANDIDATE, PROTECTED) returns a valid variable
%   name that is different from any of the list of PROTECTED names.
%   PROTECTED can be a character vector, a cell array of character vectors,
%   or a string array.
%
%   Examples:
%       genvarname({'file','file'})     % returns {'file','file1'}
%       a.(genvarname(' field#')) = 1   % returns a.field0x23 = 1
%
%       okName = true;
%       genvarname('ok name',who)       % returns 'okName1'
%
%   See also MATLAB.LANG.MAKEVALIDNAME, MATLAB.LANG.MAKEUNIQUESTRINGS
%            ISVARNAME, ISKEYWORD, ISLETTER, NAMELENGTHMAX, WHO, REGEXP.

%   Copyright 1984-2016 The MathWorks, Inc.

% Argument validation.
narginchk(1, 2)

if isCharVector(candidate)
    returnConverter = @char;
elseif isCellString(candidate)
    returnConverter = @cellstr;
elseif ~isstring(candidate)
    error(message('MATLAB:genvarname:wrongVarnameType'));
elseif any(ismissing(candidate))
    error(message('MATLAB:genvarname:MissingNames', ...
                  getString(message('MATLAB:string:MissingDisplayText'))));
else
    returnConverter = @string;
end

% Set up protected list if it exists.
if nargin < 2
    protected = strings(0);
elseif isCharVector(protected)
    protected = string(protected);
elseif isCellString(protected)
    protected = string(protected);
elseif ~isstring(protected)
    error(message('MATLAB:genvarname:wrongProtectedType'));
end

if ~ischar(candidate) && isempty(candidate)
    varname = candidate;
    return;
end
varname = string(candidate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, ensure all candidates are valid variable names.
modified = ~arrayfun(@isvarname, varname);

% Insert x if the first column is non-letter.
varsToFormalize = varname(modified);
varsToFormalize = regexprep(varsToFormalize, '^\s*+([^A-Za-z])', 'x$1', 'once');

% Replace whitespace with camel casing.
varsToFormalize = regexprep(varsToFormalize, '(?<=\S)\s+([a-z])', '${upper($1)}');
varsToFormalize = regexprep(varsToFormalize, '\s+', '');
varsToFormalize(strlength(varsToFormalize) == 0) = "x";

% Replace non-word characters with HEXADECIMAL equivalents.
illegalStringChars = regexp(varsToFormalize, '[^A-Za-z_0-9]', 'match', 'forceCellOutput');
for elementIdx = 1:numel(illegalStringChars)
    illegalElementChars = unique(char(illegalStringChars{elementIdx}));
    illegalCharWidths = 2 + 2 * (illegalElementChars > intmax('uint8'));
    replacement = "0x" + arrayfun(@dec2hex, illegalElementChars, illegalCharWidths, 'UniformOutput', false);
    varsToFormalize(elementIdx) = replace(varsToFormalize(elementIdx), string(illegalElementChars), replacement);
end

% Prepend keyword names with "x" and camel case.
keywordIdx = arrayfun(@iskeyword, varsToFormalize);
varsToFormalize(keywordIdx) = "x" + upper(extractBefore(varsToFormalize(keywordIdx), 2)) ...
                                  + lower(extractAfter(varsToFormalize(keywordIdx), 1));

% Truncate varname to NAMLENGTHMAX.
tooLongIdx = (strlength(varsToFormalize) > namelengthmax);
varsToFormalize(tooLongIdx) = extractBefore(varsToFormalize(tooLongIdx), namelengthmax + 1);

varname(modified) = varsToFormalize;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Next, ensure the candidates are unique.
numPrecedingDups = zeros(numel(varname), 1);
% Update the protected to include other candidates that might clash
protectedAll = [varname(:); protected(:)];
for i = 1:numel(varname)
    currVarname = varname{i};
    
    % Calc number of dups within the candidates
    numPrecedingDups(i) = nnz(currVarname == varname(1:i-1));

    % Check if candidate dups with the protected
    if any(currVarname == protected)
        numPrecedingDups(i) = numPrecedingDups(i) + 1;
    end

    % See if unique candidate is indeed unique - if not up the
    % numPrecedingDups
    if numPrecedingDups(i) > 0 
        uniqueName = appendNumToName(currVarname, numPrecedingDups(i));
        while any(uniqueName == protectedAll)
            numPrecedingDups(i) = numPrecedingDups(i) + 1;
            uniqueName = appendNumToName(currVarname, numPrecedingDups(i));
        end

        % Replace the candidate with the unique string.
        varname(i) = uniqueName;
        protectedAll(i) = uniqueName;
    end
end

% Ensure return argument is the right type.
varname = returnConverter(varname);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions to make argument type checking more readable
function tf = isCharVector(content)
    tf = ischar(content) && (isrow(content) || isempty(content));
end
function tf = isCellString(argin)
    tf = false;
    if iscell(argin)
        for i = 1:numel(argin)
            if ~isCharVector(argin{i})
                return;
            end
        end
        tf = true;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper to append the unique number to varname
function uniqueName = appendNumToName(name, num)
    numStr = string(num);
    uniqueName = name + numStr;
    if strlength(uniqueName) > namelengthmax
        uniqueName = extractBefore(uniqueName, 1 + namelengthmax - strlength(numStr)) + numStr;
    end
end
