function [names,wereModified] = genvalidnames(names,allowMods)
%GENVALIDNAMES Construct valid identifiers from a list of names.
%   This function is unsupported and might change or be removed without
%   notice in a future version.

%   NAMES = GENVALIDNAMES(CANDIDATES) returns NAMES, a copy of the cell
%   array of strings CANDIDATES, where strings have been modified if
%   necessary to make them valid MATLAB identifiers.  GENVALIDNAMES does
%   not ensure that the strings in NAMES are unique.
%
%   A valid MATLAB identifier is a character string of letters, digits and
%   underscores, where the first character is a letter and the length of
%   the string is less than or equal to NAMELENGTHMAX.  GENVALIDNAMES
%   removes whitespace, replaces illegal characters with underscore, and
%   prepends an 'x' if a string does not begin with a letter or is a MATLAB
%   keyword.
%
%   NAMES = GENVALIDNAMES(CANDIDATES,FALSE) throws an error if any of the
%   strings in CANDIDATES are not valid MATLAB identifiers.
%   NAMES = GENVALIDNAMES(CANDIDATES,TRUE) is equivalent to the default
%   behavior.
%
%   [UNAMES,WEREMODIFIED] = GENVALIDNAMES(CANDIDATES,...) returns the
%   logical value WEREMODIFIED indicating if any of the strings in
%   CANDIDATES were modified.
%
%   See also NAMELENGTHMAX, INTERNAL.MATLAB.CODETOOLS.GENUNIQUENAMES.

%   Copyright 2006-2012 The MathWorks, Inc.

wereModified = false(size(names));
if nargin < 2, allowMods = true; end

% Loop over all names and make them valid identifiers.
for k = 1:numel(names)
    name = names{k};

    if ~isvarname(name)
        if allowMods
            wereModified(k) = true;
        else
            error(message('MATLAB:codetools:InvalidVariableName', name));
        end

        % Remove leading and trailing whitspace, and replace embedded
        % whitespace with camel/mixed casing.
        [~, afterSpace] = regexp(name,'\S\s+\S');
        if ~isempty(afterSpace)
            % Leave case alone except for chars after spaces
            name(afterSpace) = upper(name(afterSpace));
        end
        name = regexprep(name,'\s*','');
        if (isempty(name))
            name = 'x';
        end
        
        % Replace non-word character with underscore
        illegalChars = unique(name(regexp(name,'[^A-Za-z_0-9]')));
        for illegalChar=illegalChars
            replace = '_';
            name = strrep(name, illegalChar, replace);
        end

        % Insert x if the first column is non-letter.
        name = regexprep(name,'^\s*+([^A-Za-z])','x$1', 'once');

        % Prepend keyword with 'x' and camel case.
        if iskeyword(name)
            name = ['x' upper(name(1)) lower(name(2:end))];
        end

        % Truncate name to NAMLENGTHMAX
        name = name(1:min(length(name),namelengthmax));

        names{k} = name;
    end
end

if any(wereModified)
    warning(message('MATLAB:codetools:ModifiedVarnames'));
end
