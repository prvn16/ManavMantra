function [names,wereModified] = genuniquenames(names,startLoc)
%GENUNIQUENAMES Construct unique identifiers from a list of strings.
%   This function is unsupported and might change or be removed without
%   notice in a future version.

%   UNAMES = GENUNIQUENAMES(NAMES) returns UNAMES, a copy of the cell array
%   of strings NAMES, where duplicate strings have been modified to make
%   them unique.
%
%   GENUNIQUENAMES appends strings of the form '_1', '_2', etc. to any
%   duplicate strings in NAMES.  GENUNIQUENAMES ensures that the strings in
%   UNAMES are no longer than NAMELENGTHMAX, but does not otherwise check
%   that the strings in NAMES are valid MATLAB identifiers.
%
%   UNAMES = GENUNIQUENAMES(NAMES,STARTLOC) specifies the starting element
%   in NAMES at which to begin checking for duplicates.  STARTLOC is an
%   integer from 1 to LENGTH(NAMES)+1.
%
%   UNAMES = GENUNIQUENAMES(NAMES,LOCS) specifies the elements in NAMES to
%   check for duplicates.  LOCS is a logical vector the same size as NAMES.
%
%   [UNAMES,WEREMODIFIED] = GENUNIQUENAMES(NAMES,...) returns the logical
%   value WEREMODIFIED indicating if any of the strings in NAMES were
%   modified.
%
%   See also NAMELENGTHMAX, INTERNAL.MATLAB.CODETOOLS.GENVALIDNAMES.

%   Copyright 2006-2012 The MathWorks, Inc. 

if nargin < 2 % check all names
    numKnownUnique = 0;
elseif islogical(startLoc) % check the specified names
    locs = startLoc;
    numKnownUnique = length(names) - sum(locs);
else % check names beginning at startLoc
    startLoc = max(min(startLoc,length(names)+1),1);
    if startLoc == 1 % check all names
        numKnownUnique = 0;
    elseif startLoc <= length(names) % check some names
        numKnownUnique = startLoc - 1;
        locs = false(1,length(names)); locs(startLoc:end) = true;
    else % startloc > length(names), don't need to check any names
        numKnownUnique = length(names);
    end
end

% wasRow = isrow(names);
sizeOut = size(names);
names = names(:);

if numKnownUnique == 0
    [unames,inames,iu] = unique(names,'stable'); % implies 'first'
    iu = iu(:);
    isDup = true(size(names)); isDup(inames) = false;
elseif numKnownUnique < length(names)
    unames = names(~locs);
    namesNew = names(locs);
    % Find names that are duplicates within the set of names being checked.
    [unamesWithin,inamesWithin,iuWithin] = unique(namesNew,'stable'); % implies 'first'
    iuWithin = iuWithin(:);
    isDupWithin = true(size(namesNew)); isDupWithin(inamesWithin) = false;
    % Of those, find names that are duplicates of the known unique names
    [isDupBetween,iuBetween] = ismember(unamesWithin,unames,'R2012a'); % implies 'first'
    % Gather the unique names across the complete set
    unames = [unames; unamesWithin(~isDupBetween)];
    iuBetween(~isDupBetween) = (numKnownUnique+1):length(unames);
    isDup = false(size(names)); isDup(locs) = isDupBetween(iuWithin) | isDupWithin;
    iu = zeros(size(names)); iu(locs) = iuBetween(iuWithin);
else % numKnownUnique == length(names)
    unames = names;
    iu = zeros(0,1);
    isDup = false(0,1);
end

dupCnts = accumarray(iu(isDup,:),1,size(unames));
hasDups = find(dupCnts>0)'; % unique names that have duplicates
wereModified = ~isempty(hasDups);
for i = hasDups
    % Find all the names in this group of duplicates
    j = find(isDup & (iu==i));
    lastSuffixTried = 0;
    baseName = names{j(1)};
    appendLen = ceil(log10(2*length(names))) + 1; % worst-case number of chars that will be added
    while ~isempty(j)
        % Shorten the names if necessary, cutting from the middle, leaving the end intact
        if size(baseName,2) > namelengthmax-appendLen
            cut = namelengthmax - appendLen - 8;
            baseName = [baseName(1:cut) '_' baseName((end-6):end)];
        end
        % Create new names for the current group of duplicates by adding a
        % suffix that makes it unique within this group (but may still conflict
        % with an existing name)
        suffixNums = lastSuffixTried+(1:length(j))';
        newNames = num2str(suffixNums,[baseName '_%-d']);
        % Check if the new names conflict with any existing names
        keep = ~ismember(newNames,unames);
        % Keep the names that didn't conflict, and try again for any that did
        if any(keep) % cellstr would mess up the empty case
            newNames = cellstr(newNames(keep,:)); % trims trailing whitespace
            names(j(1:length(newNames))) = newNames;
            unames = [unames; newNames];
            j = j((length(newNames)+1):end);
        end
        lastSuffixTried = suffixNums(end);
    end
end

% if wasRow, names = names'; end
names = reshape(names,sizeOut);
