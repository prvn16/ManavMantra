function [hRequire, hProvide] = getVariableUsage(hTextLine)
%getVariableUsage Return the required and provided variables
%
%  [hRequired, hProvided] = getVariableUsage(hFunc) returns the set of
%  inputs that are required and the set of outputs that this tex block
%  will provide.  Empty 1x0 matrix is returned for each if there are no
%  required or provided variables.

%  Copyright 2012-2014 The MathWorks, Inc.

hRequire = zeros(1,0);
hProvide = zeros(1,0);

TextElements = hTextLine.Text;
[IsChar, IsArg] = cellfun(@localClassifyItem, TextElements);

if any(IsArg)
    % Check whether this looks like a comment line
    IsComment = IsChar(1) && ~isempty(regexp(TextElements{1}, '^\s*%', 'once'));
    
    if ~IsComment
        % Look for an "=" sign in the set of char elements.  If it is present
        % then we will treat all argument items before it as being provided and
        % all after it as being required.  If there is no equals sign then all
        % argument items are required.
        
        HasEquals = ~cellfun('isempty', strfind(TextElements(IsChar), '='));
        EqualsIndex = 0;
        if sum(HasEquals)==1
            % Only split into required and provided if we find just one
            % equals sign.
            CharIndices = find(IsChar);
            EqualsIndex = CharIndices(HasEquals); 
        end
        
        if EqualsIndex>1
            % Grab variables that are before the equals sign
            PreEqualsElements = TextElements(1:(EqualsIndex-1));
            hProvide = [PreEqualsElements{IsArg(1:(EqualsIndex-1))}];
        end
        
        if EqualsIndex<numel(TextElements)
            % Grab variables that are after the equals sign
            PostEqualsElements = TextElements((EqualsIndex+1):end);
            hRequire = [PostEqualsElements{IsArg((EqualsIndex+1):end)}];
        end
    else
        % Comments can't ever provide items, and don't need the variable to
        % exist, just have a name
    end
end



function [IsChar, IsArg] = localClassifyItem(item)

IsChar = ischar(item);
IsArg = ~IsChar && isa(item, 'codegen.codeargument');
