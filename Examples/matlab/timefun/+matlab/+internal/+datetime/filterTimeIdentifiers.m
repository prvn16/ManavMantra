function filteredFormat = filterTimeIdentifiers(format)
%FILTERTIMETOKENS This helper function will remove time related identifiers
%from a datetime style format string.  Literals will be preserved.  Single
%spaces will be removed in a pattern that is consistent with how an average
%person may react to the removal of the time identifier

FORMATBOUNDARYPLACEHOLDER = ' ';

validateattributes(format, ...
    {'char', 'string'}, ...
    {'scalartext'});

format = convertStringsToChars(format);
separatorIndicies = find(arrayfun(@(x)isequal(x, ''''), format));

if isempty(separatorIndicies)
    
    % format has no literals: 'dd-MMM-uuuu HH:mm:ss'
    filteredFormat = filterFormatWithoutLiterals([FORMATBOUNDARYPLACEHOLDER, format, FORMATBOUNDARYPLACEHOLDER]);
    filteredFormat = filteredFormat(2:end-1);
else
    % format has literals: '''The date is: ''dd-MMM-uuuu HH:mm:ss'
    filteredFormat = filterFormatWithLiterals(format, separatorIndicies);
end
end

function filteredFormat = filterFormatWithoutLiterals(format)

% Replace two time related identifiers separated by a single character with
% single space if there is a space on either side
% Examples: ' H ', ' HH:mm ', ' mm.ss ', ' HH:mm:ss '
expr = ' [ahHmsSZzxX]+([\W][ahHmsSZzxX]+)* ';
format =  regexprep(format,expr,' ');

% Remove time related identifiers separated by a single character
% Examples: 'H', 'HH:mm', 'mm.ss', 'HH:mm:ss'
expr = '[ahHmsSZzxX]+([\W][ahHmsSZzxX]+)*';
filteredFormat =  regexprep(format,expr,'');

end

function filteredFormat = filterFormatWithLiterals(format, separatorIndicies)

TOKENBOUNDARYPLACEHOLDER = 'P';
FORMATBOUNDARYPLACEHOLDER = ' ';

% Check if there is an unmatched literal.  Unmatched literals are
% ignored in datetime Format (they are not rendered as a single quote)
hasUnmatchedLiteral = true(rem(numel(separatorIndicies), 2));
if hasUnmatchedLiteral
    % Remove Index from separatorIndies
    separatorIndicies(end) = [];
end

filteredFormat = '';

if separatorIndicies(1) > 1
    
    firstSegment = format(1:(separatorIndicies(1)-1));
    % filter first section for time data.  Use placeholder 'P' to mock
    % the Literals that would be there in the full format.
    filteredFormat = filterFormatWithoutLiterals([FORMATBOUNDARYPLACEHOLDER, firstSegment, TOKENBOUNDARYPLACEHOLDER]);
    % remove leading space and placeholder 'P'
    filteredFormat = filteredFormat(2:end-1);
end

% These will be matched pairs of indicies because any unmatched
% indicies have been removed manually
lastPairedIndex = numel(separatorIndicies) - rem(numel(separatorIndicies), 2);
for index = 1:lastPairedIndex-1
    
    % odd indicies are start of literal
    if rem(index, 2) == 1
        % Preserve literal before separator in full
        filteredFormat = [filteredFormat, format(separatorIndicies(index):separatorIndicies(index+1))];
        
    else
        % even indicies are start of nonliterals that may contain time
        % Add placeholders to mock literals
        segment = format((separatorIndicies(index)+1):(separatorIndicies(index+1)-1));
        segment = filterFormatWithoutLiterals([TOKENBOUNDARYPLACEHOLDER, segment, TOKENBOUNDARYPLACEHOLDER]);
        % remove Placeholders before adding the text to the filtered format
        filteredFormat = [filteredFormat, segment(2:end-1)];
    end
end

% Handle time related format after last separator
if separatorIndicies(end) < numel(format)
    
    lastSegment = format((separatorIndicies(end)+1):end);
    % filter first section for time data.  Use placeholder 'P' to mock
    % the Literals that would be there in the full format.
    filteredSegment = filterFormatWithoutLiterals([TOKENBOUNDARYPLACEHOLDER, lastSegment, FORMATBOUNDARYPLACEHOLDER]);
    % remove placeholder
    filteredFormat = [filteredFormat, filteredSegment(2:end-1)];
end
end