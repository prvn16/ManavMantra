function [uniqueStrings, modified] = makeUniqueStrings(inStr, excludes, maxStringLength)
%MATLAB.LANG.MAKEUNIQUESTRINGS Constructs unique strings from input strings
%   U = MATLAB.LANG.MAKEUNIQUESTRINGS(S) constructs unique elements,
%   U, from S by appending an underscore and a number to duplicates. S
%   is a character vector (i.e. a 1xN character array or ''), a cell array
%   of character vectors, or a string array.
%
%   U = MATLAB.LANG.MAKEUNIQUESTRINGS(S, EXCLUDED) makes the elements
%   in S unique among themselves and unique with respect to EXCLUDED.
%   MAKEUNIQUESTRINGS does not check EXCLUDED for uniqueness.
%
%   U = MATLAB.LANG.MAKEUNIQUESTRINGS(S, WHICHSTRINGS) makes the elements
%   in S(WHICHSTRINGS) unique among themselves and with respect to the
%   remaining elements. WHICHSTRINGS is a logical vector or a vector of
%   indices. MAKEUNIQUESTRINGS does not check the remaining elements for
%   uniqueness, and returns them unmodified in U. Use this syntax when you
%   have a cell or string array and need to check that only some elements
%   of the array are unique.
%
%   U = MATLAB.LANG.MAKEUNIQUESTRINGS(S, ___, MAXSTRINGLENGTH)
%   specifies the maximum strlength, MAXSTRINGLENGTH, of the elements in U.
%   If MAKEUNIQUESTRINGS cannot make elements in S unique without exceeding
%   MAXSTRINGLENGTH, it throws an error.
%
%   [U, MODIFIED] = MATLAB.LANG.MAKEUNIQUESTRINGS(S, ___) also returns a
%   logical array the same size as S to denote modified elements.
%
%   Examples
%   --------
%   Make unique character vectors with respect to workspace variable names
%
%       var3 = 0;
%       varNames = MATLAB.LANG.MAKEUNIQUESTRINGS({'var' 'var2' 'var' 'var3'}, who)
%
%   returns the cell array {'var' 'var2' 'var_1' 'var3_1'}
%
%   Make unique character vectors by checking only some elements of the array
%
%       names = {'Peter' 'Jeremy' 'Campion' 'Nick' 'Nick'};
%       names = MATLAB.LANG.MAKEUNIQUESTRINGS(names, [2 4])
%
%   returns the cell array {'Peter' 'Jeremy' 'Campion' 'Nick_1' 'Nick'}
%
%   See also MATLAB.LANG.MAKEVALIDNAME, NAMELENGTHMAX, WHO.

%   Copyright 2013-2017 The MathWorks, Inc.

% Validate number of inputs.
narginchk(1,3);

% Validate input string.
inputIsChar = false;
inputIsCell = false;
if matlab.internal.datatypes.isCharString(inStr)
    inputIsChar = true;
elseif matlab.internal.datatypes.isCharStrings(inStr, true)
    inputIsCell = true;
elseif ~isstring(inStr)
    error(message('MATLAB:makeUniqueStrings:InvalidInputStrings'))
elseif any(ismissing(inStr(:)))
    error(message('MATLAB:makeUniqueStrings:MissingNames', ...
                  getString(message('MATLAB:string:MissingDisplayText'))));
end

if isempty(inStr)
    uniqueStrings = inStr;
    if inputIsChar
        modified = false;
    else
        modified = false(size(inStr));
    end
    return;
end
inStr = string(inStr);

% Set/validate EXCLSTRORELEMTOCHK and MAXSTRINGLENGTH.
[~, maxArraySize] = computer;
if nargin < 3
    maxStringLength = maxArraySize;
else
    maxStringLength = validateMaxStringLength(maxStringLength, maxArraySize);
end

if nargin < 2
    exclStrOrElemToChk = string({});
else
    exclStrOrElemToChk = validateExclStrOrElemToChk(excludes, inStr);
end

% Process differently for 2nd option as checkElements or stringsToProtect.
if isnumeric(exclStrOrElemToChk) || islogical(exclStrOrElemToChk) % checkElements
    
    % Construct stringsToCheck from STRINGS that need to be made unique.
    stringsToCheck = inStr(exclStrOrElemToChk);
    
    % Truncate only the stringsToCheck.
    if nargout > 1
        truncated = false(size(inStr));
    end
    if maxStringLength < maxArraySize
        [stringsToCheck, truncated(exclStrOrElemToChk)] = truncateString(stringsToCheck, maxStringLength);
    end
    
    % Construct stringsToProtect from STRINGS that should not be modified.
    if islogical(exclStrOrElemToChk)
        stringsToProtect = inStr(~exclStrOrElemToChk);
    else % exclStrOrElemToChk is indices
        stringsToProtect = inStr(setdiff(1:numel(inStr),exclStrOrElemToChk));
    end
    
    % Make stringsToCheck unique against itself and stringsToProtect.
    [stringsChecked, modifiedInStringsChecked] = ...
        makeUnique(stringsToCheck, stringsToProtect, maxStringLength);
    
    % Combine the protected subset of strings with the checked subset.
    uniqueStrings = inStr;
    uniqueStrings(exclStrOrElemToChk) = stringsChecked;
    
    % Compute the positions of modified strings in the now completed set.
    if nargout > 1
        uniquified = false(size(inStr));
        uniquified(exclStrOrElemToChk) = modifiedInStringsChecked;
    end
else % stringsToProtect
    if maxStringLength < maxArraySize
        [inStr, truncated] = truncateString(inStr, maxStringLength);
    elseif nargout > 1
        truncated = false(size(inStr));
    end    
    [uniqueStrings, uniquified] = ...
        makeUnique(inStr, exclStrOrElemToChk, maxStringLength);
end

if maxStringLength == 0 && inputIsChar
    uniqueStrings = char(zeros(1, 0));
    modified = true;
    return;
end

if inputIsChar
    uniqueStrings = char(uniqueStrings);
elseif inputIsCell
    uniqueStrings = cellstr(uniqueStrings);
end

if nargout > 1
    modified = truncated | uniquified;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  HELPERS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [str, uniquified] = makeUnique(str, stringsToProtect, maxStringLength)
szStrings = size(str);
numStrings = numel(str);
uniquified = false(1, numStrings);
[str, sortIdx] = sort(reshape(str, 1, []));
stringsToProtect = reshape(stringsToProtect, 1, []);

% Find where there are groups of duplicates by comparing two sorted strings
% having a one-element shift.
isDuplicateOfPrevious = [false(min(1, numStrings)), strcmp(str(1:end-1), str(2:end))];
isDuplicateOfPreviousDiff = diff([isDuplicateOfPrevious, false]);
isDuplicateStart = (isDuplicateOfPreviousDiff > 0);
isDuplicateStopIdx = find(isDuplicateOfPreviousDiff < 0);

% Find where groups of protected strings start.
% For performance, only call ismember when there are both elements in
% stringsToProtect and duplicates to compare. This is important for the
% case when maxStringLength is needed but the second input is {}.
isProtectedStart = false(1, numStrings);
if ~isempty(stringsToProtect) && any(~isDuplicateOfPrevious)
    isProtectedStart(~isDuplicateOfPrevious) = ismember(str(~isDuplicateOfPrevious), stringsToProtect);
end

duplicateNum = 1;
for changeIdx = find(isDuplicateStart | isProtectedStart)
    if isDuplicateStart(changeIdx) && isProtectedStart(changeIdx)
        startIdx = changeIdx;
        stopIdx = isDuplicateStopIdx(duplicateNum);
        duplicateNum = duplicateNum + 1;
    elseif isDuplicateStart(changeIdx)
        startIdx = changeIdx + 1;
        stopIdx = isDuplicateStopIdx(duplicateNum);
        duplicateNum = duplicateNum + 1;
    else % isProtectedStartIdx(changeIdx)
        startIdx = changeIdx;
        stopIdx = changeIdx;
    end
    try
        str(startIdx:stopIdx) = makeNameUnique(str, startIdx, stopIdx, stringsToProtect, maxStringLength);
    catch ex
        throwAsCaller(ex);
    end
    uniquified(startIdx:stopIdx) = true;
end

% Unsort and reshape the now unique STRINGS and MODIFIED to match how
% STRINGS was input.
inverseSortIdx(sortIdx) = 1:numStrings;
str = reshape(str(inverseSortIdx), szStrings);
uniquified = reshape(uniquified(inverseSortIdx), szStrings);
end

function stringsToChange = makeNameUnique(str, startIdx, stopIdx, stringsToProtect, maxStringLength)
stringsToChange = str(startIdx:stopIdx);
stringsToKeep = str;
stringsToKeep(startIdx:stopIdx) = [];
namesToCheck = [stringsToChange, stringsToKeep(startIdx:end), stringsToProtect];

while true
    baseName = stringsToChange(1);
    candidateVarNums = findNumbersToAppend(baseName, namesToCheck, numel(stringsToChange));
    baseNameLength = strlength(baseName);
    appendLength = 1 + strlength(string(candidateVarNums(end)));
    if appendLength > (maxStringLength - min(1, baseNameLength))
        % The append itself violates the limit imposed by maxStringLength.
        % Note that, if the name is not empty, its first character must be
        % preserved.
        error(message('MATLAB:makeUniqueStrings:CannotMakeUnique'));
    elseif appendLength > (maxStringLength - baseNameLength)
        % The name must be truncated.
        % This invalidates the previous calculation, since the new name
        % will likely conflict with a different set of names, some of
        % which might be lexigraphically less than the old name.
        stringsToChange = truncateString(stringsToChange, maxStringLength - appendLength);
        namesToCheck = [stringsToChange, stringsToKeep, stringsToProtect];
    else
        % Append can be done without needing to truncate.
        stringsToChange = baseName + "_" + candidateVarNums;
        break;
    end
end
end

function [str, truncateIdx] = truncateString(str, maxStringLength)
truncateIdx = (strlength(str) > maxStringLength);
str(truncateIdx) = extractBefore(str(truncateIdx), 1 + maxStringLength);
end

function appendValues = findNumbersToAppend(baseName, namesToCheck, numAppendValues)
namesToGuard = startsWith(namesToCheck, baseName + "_");
protectedNums = double(extractAfter(namesToCheck(namesToGuard), strlength(baseName)+1));
protectedNums(isnan(protectedNums)) = [];
appendValues = setdiff(1:numel(namesToCheck), protectedNums);
appendValues(numAppendValues+1:end) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%  INPUT VALIDATION HELPERS %%%%%%%%%%%%%%%%%%%%%%%%
function exclStrOrElemToChk = validateExclStrOrElemToChk(exclStrOrElemToChk, inputStr)
% Validate EXCLUDEDSTRINGS or ELEMENTSTOCHECK.
if matlab.internal.datatypes.isCharString(exclStrOrElemToChk) ...
        || ((isvector(exclStrOrElemToChk) || isempty(exclStrOrElemToChk)) ...
             && matlab.internal.datatypes.isCharStrings(exclStrOrElemToChk,true))
    % exclStrOrElemToChk is a (potentially empty) char vector or cellstr.
    exclStrOrElemToChk = string(exclStrOrElemToChk);
elseif isnumeric(exclStrOrElemToChk) && isequaln(floor(exclStrOrElemToChk),exclStrOrElemToChk)
    % Assume exclStrOrElemToChk is checkElements intended to be a range or
    % linear indices into STRINGS.
    exclStrOrElemToChk = reshape(exclStrOrElemToChk, 1, []);
    if isempty(exclStrOrElemToChk)
        % Nothing to check for uniqueness.
        exclStrOrElemToChk = false(size(inputStr));
    elseif min(exclStrOrElemToChk) <= 0 || ~isreal(exclStrOrElemToChk) ...
           || any(isnan(exclStrOrElemToChk))
        % Elements of the range must be positive.
        error(message('MATLAB:makeUniqueStrings:NonPositiveRange'));
    elseif max(exclStrOrElemToChk) > numel(inputStr)
        % checkElements exceed the range of STRINGS number of elements.
        error(message('MATLAB:makeUniqueStrings:OutOfBoundRange'));
    end
elseif islogical(exclStrOrElemToChk)
    % Assume exclStrOrElemToChk is checkElements when exclStrOrElemToChk is
    % a logical array; the logical indices array must be the same length as
    % STRINGS.
    if ~isequal(numel(exclStrOrElemToChk), numel(inputStr))
        error(message('MATLAB:makeUniqueStrings:BadLengthLogicalMask'));
    end
elseif ~isstring(exclStrOrElemToChk)
    % Though they are useless here, <missing> string values are allowed.
    error(message('MATLAB:makeUniqueStrings:InvalidFirstOptionalArg'));
end
end

function maxStringLength = validateMaxStringLength(maxStringLength, maxArraySize)
% Validate MAXSTRINGLENGTH, which must be a scalar, non-negative integer.
if ~isnumeric(maxStringLength) || ~isscalar(maxStringLength) ...
   || ~isreal(maxStringLength) || isnan(maxStringLength) ...
   || floor(maxStringLength) ~= maxStringLength || maxStringLength < 0
    error(message('MATLAB:makeUniqueStrings:BadMaxStringLength'));
end
% Cap maxStringLength at maxArraySize.
maxStringLength = min(maxStringLength, maxArraySize);
end
