function disp(t,bold,indent,fullChar,nestedLevel)
%DISP Display a table.
%   DISP(T) prints the table T, including variable names and row names (if
%   present), without printing the table name.  In all other ways it's the
%   same as leaving the semicolon off an expression.
%
%   For numeric or categorical variables that are 2-dimensional and have 3 or
%   fewer columns, DISP prints the actual data using either short g, long g,
%   or bank format, depending on the current command line setting.  Otherwise,
%   DISP prints the size and type of each table element.
%
%   For character variables that are 2-dimensional and 10 or fewer characters
%   wide, DISP prints quoted strings.  Otherwise, DISP prints the size and
%   type of each table element.
%
%   For cell variables that are 2-dimensional and have 3 or fewer columns,
%   DISP prints the contents of each cell (or its size and type if too large).
%   Otherwise, DISP prints the size of each tabble element.
%
%   For other types of variables, DISP prints the size and type of each
%   table element.
%
%   See also TABLE, DISPLAY, FORMAT.

%   Copyright 2012-2017 The MathWorks, Inc.

if nargin < 2, bold = true; end
if nargin < 3, indent = 4; end
if nargin < 4, fullChar = false; end
if nargin < 5, nestedLevel = 1; end
between = 4;
betweenColSpaces = 2;
maxNumVarColsToDisp = 5;
maxCharWidthToDisp = 10;

% Follow the cmd window's format settings as possible
isLoose = strcmp(matlab.internal.display.formatSpacing,'loose');
if isLoose
    looseline = newline;
else
    looseline = '';
end
[dblFmt,snglFmt] = getFloatFormats();

bold = matlab.internal.display.isHot() && bold;
strongBegin = '';strongEnd = '';
if bold
    strongBegin = getString(message('MATLAB:table:localizedStrings:StrongBegin'));
    strongEnd = getString(message('MATLAB:table:localizedStrings:StrongEnd'));
end
strongTagsLength = strlength(strongBegin) + strlength(strongEnd);

lostWidth = zeros(t.rowDim.length,1);
marginChars = nSpaces(indent);
if (t.rowDim.length > 0) && (t.varDim.length > 0)
    if t.rowDim.hasLabels
        rownameChars = string(t.rowDim.textLabels());
        for i=1:t.rowDim.length
            rownameChars{i} = matlab.internal.display.truncateLine(rownameChars{i});
        end
        [rownameChars,rownameWidth,lostWidth] = alignTabularContents(rownameChars,lostWidth);
        if t.dispRowLabelsHeader
            rowDimName = t.metaDim.labels{1};
            if rownameWidth < length(rowDimName)
                rownameChars = rownameChars + nSpaces(length(rowDimName)-rownameWidth);
                rownameWidth = length(rowDimName);
            end
        end
        if bold
            hasLinks = contains(rownameChars,'<a href=');
            if any(hasLinks)
                rownameChars(hasLinks) = boldifyLinks(rownameChars(hasLinks));
            end
            rownameChars(~hasLinks) = strongBegin + rownameChars(~hasLinks) + strongEnd;
        else
            rownameChars = strongBegin + rownameChars + strongEnd;
        end
        marginChars = marginChars + rownameChars + nSpaces(between);
    end
    varDispWidths = zeros(1,t.varDim.length);
    numNestedVars = zeros(1,t.varDim.length);
    nestedVarnameStrs = strings(1,t.varDim.length);
    haveNestedTable = false;
    
    tblChars = strings(t.rowDim.length,t.varDim.length);
    for ivar = 1:t.varDim.length
        varName = t.varDim.labels{ivar};
        var = t.data{ivar};

        if ischar(var)
            if ismatrix(var) && (fullChar || (size(var,2) <= maxCharWidthToDisp))
                % Display individual strings for a char variable that is 2D and no
                % more than 10 chars.
                varStr = string(var);
            else
                % Otherwise, display a description of the chars.
                varStr = getInfoDisplay(var);
            end
            [varStr,maxVarLen,lostWidth] = alignTabularContents(varStr,lostWidth);
        else
            % Display the individual data if the var is 2D and no more than 5 columns.
            if ~isempty(var) && ismatrix(var) && (size(var,2) <= maxNumVarColsToDisp)
                if isnumeric(var) && ~isenum(var)
                    if isa(var,'double')
                        varChars = num2str(var,dblFmt);
                    elseif isa(var,'single')
                        varChars = num2str(var,snglFmt);
                    elseif isa(var,'uint8') || isa(var,'uint16') || isa(var,'uint32') || isa(var,'uint64')
                        varChars = num2str(var,'%u    ');
                    else % signed integer types
                        varChars = num2str(var,'%d    ');
                    end
                    varStr = string(varChars);
                    maxVarLen = max(strlength(varStr));
                elseif islogical(var)
                    % Display the logical values using meaningful names.
                    tf = ["false" "true "];
                    s = reshape(tf(1+var),size(var));
                    varStr = s.join(nSpaces(betweenColSpaces),2);
                    maxVarLen = max(strlength(varStr));
                elseif isa(var,'categorical') || isa(var,'datetime') || isa(var,'duration') || isa(var,'calendarDuration')
                    if isa(var,'categorical')
                        checkChars = categories(var);
                        padSide = 'right';
                    else
                        checkChars = {var.Format};
                        padSide = 'left';
                    end
                    
                    % Convert values to a string array. String is a data
                    % conversion, so missing values need to be handled
                    % specially.
                    varStr = string(var);
                    miss = var(1); miss(1) = missing; miss = char(miss);
                    varStr(ismissing(varStr)) = miss;
                    
                    tagged = contains(checkChars,{'<a href=','<strong>'});
                    if any(any(char(checkChars) > 127)) || any(tagged(:))                        
                        % Align the var data display accounting for wide chars
                        % or markup in a category name or a date/time format.
                        [varStr, ~, ~] = alignTabularContents(varStr);
                        varStr = varStr.join(nSpaces(betweenColSpaces),2);
                        [varStr,maxVarLen,lostWidth] = alignTabularContents(varStr,lostWidth);
                    else
                        % Otherwise, no wide chars or markup, just pad to equal
                        % number of chars.
                        varStr = pad(varStr,padSide,' ');
                        varStr = varStr.join(nSpaces(betweenColSpaces),2);                        
                        maxVarLen = max(strlength(varStr));
                    end
                elseif iscell(var) || isstring(var)
                    isScalar = isscalar(var);

                    if isScalar 
                        % scalars display without quotes, we want to add
                        % them
                        if isstring(var) && ~ismissing(var)
                            % truncates strings with newlines, or replaces
                            % char(10) and char(13) with "knuckle".
                            var = matlab.internal.display.truncateLine(var{1},10000);
                            var = '"' + string(var) + '"';
                        elseif iscell(var) && ischar(var{1}) % must be a cell if not string
                            var = {matlab.internal.display.truncateLine(var{1},10000)};
                        end
                    end
                    varStr = getStrOutput(var);
                    if isScalar && iscell(var) && isequal(size(var{1}),[0 0])
                        % Work around a special case that the command line
                        % needs but we don't: curly braces around a scalar
                        % cell containing a 0x0
                        varStr = removeBraces(varStr);
                    end 
                    
                    [varStr,maxVarLen,lostWidth] = alignTabularContents(varStr,lostWidth);
                elseif isenum(var)
                    % Convert enum values to strings. value names don't contain
                    % wide chars or markup, just pad to equal number of chars.
                    varStr = pad(getStrOutput(var),' ');
                    maxVarLen = max(strlength(varStr));
                elseif isa(var,'tabular') && (nestedLevel == 1)
                    haveNestedTable = true;
                    % Get the nested table's disp, bold per caller, no indent, and
                    % whatever char disp setting our caller gave us. Tell the nested
                    % table that it's one level deeper than we are.
                    varChars = evalc('disp(var,bold,0,fullChar,nestedLevel+1)');
                    assert(sum(varChars==newline) == t.rowDim.length+2+2*isLoose) % a table's disp should never have embedded newlines
                    varStr = splitlines(string(varChars));
                    
                    % Save the first line of the nested table's display, that's
                    % its var names, then chop off the first two lines and any
                    % trailing blank lines, leaving just the data display.
                    nestedVarnameStrs(ivar) = varStr(1);
                    numNestedVars(ivar) = var.varDim.length + (var.rowDim.hasLabels && var.dispRowLabelsHeader);
                    varStr(1:2) = [];
                    varStr(varStr == "") = [];
                    
                    % Find the maximum width of the nested table's data display.
                    % This accounts for any wide chars in the nested table's
                    % data or row names. It does not explicitly account for the
                    % width of the nested table's var names, which will become
                    % an extra header line for the outer table. But tabular/disp
                    % creates (approx) equal-length lines of text for the nested
                    % table, including its var names header line, so their width
                    % need not be accounted for separately.
                    [varStr,maxVarLen,lostWidth] = alignTabularContents(varStr,lostWidth);
                else
                    % Display a description of each table element.
                    varStr = getInfoDisplay(var);
                    maxVarLen = max(strlength(varStr));
                end
                
                % Either the variable is not 2D, or it's empty, or it's too wide
                % to show. Display a description of each table element.
            else
                varStr = getInfoDisplay(var);
                maxVarLen = max(strlength(varStr));
            end
        end
        
        if maxVarLen < length(varName)
            % If the var name is wider than the var's data display, pad the
            % latter with spaces to center the var name over the data. Need to
            % do this explicitly, because while each line has (approx) the same
            % display width, they may have different numbers of chars due to wide
            % chars and markup, and pad requires a common target width.
            varDataPad = length(varName) - maxVarLen;
            numRightSpaces = ceil(varDataPad/2);
            numLeftSpaces = varDataPad - numRightSpaces;
            varStr = nSpaces(numLeftSpaces) + varStr + nSpaces(numRightSpaces);
            maxVarLen = length(varName);
        end
        varDispWidths(ivar) = maxVarLen;
        
        tblChars(:,ivar) = varStr;
    end
    [varChars,nestedVarChars,underlines] = getVarNamesDispLines();
disp(char(varChars));
    if haveNestedTable, disp(char(nestedVarChars)); end
disp(char(underlines));
    tblChars = marginChars + tblChars.join('    ',2);
for row = 1:t.rowDim.length
    disp(char(tblChars(row,:)))
end
fprintf(looseline);
end

%-----------------------------------------------------------------------
    function [s, maxVarLen, colWidth] = alignTabularContents(s, colWidth)
        % When the variables in a table are strings or chars, there is a
        % possibility for them to be misaligned. For instance, strings
        % containing hyperlinks will show up on the command window as
        % possibly a different character width than what strlength()
        % returns. Same for <strong> text. International characters also
        % pose this problem, since the widths of Unicode characters cannot
        % be guaranteed to be the same, usually causing strings containing
        % international characters to be wider than ASCII text with the
        % same number of characters.
        
        % The purpose of alignTabularContents is to check for these
        % potential cases of misalignment and adjust the strings properly
        % so they are as close to even as possible. wrappedLength() is used
        % to accurately obtain the display width of each line of text. For
        % the case of international characters, it is impossible to line
        % them up exactly due to them being non-integral character lengths.
        % Thus, the remainder is tracked to ensure they are aligned within
        % 1 character of other ASCII lines.
        
        % alignTabularContents is used to align table variables that are
        % nx1 strings or multi-column table variables to ensure that each
        % sub-column of a table variable is aligned properly, before that
        % variable is aligned with other variables in the table.

        if nargin < 2
            [rows, cols] = size(s);
            colWidth = zeros(rows,1);
        else
            rows = size(s,1);
            cols = 1;
        end
        
        tagged = contains(s,{'<a href=','<strong>'});
        varLengthM = strlength(s);
        for idx = 1:numel(s)
            tagged(idx) = tagged(idx) || any(s{idx} > char(128));
        end 
        varLengthM(tagged) = vectorizedWrappedLength(s(tagged));
        for c=1:cols
            varLength = varLengthM(:,c);
            maxVarLen = max(ceil(varLength));
            postPadLen = maxVarLen - varLength;
            colWidth = colWidth + (postPadLen - floor(postPadLen));
            tooLong = colWidth > 1;
            colWidth(tooLong) = colWidth(tooLong) - 1;
            postPadLen(tooLong) = postPadLen(tooLong) +1;
            ppI = floor(postPadLen);
            for r = 1:max(ppI)
                % add the spaces in place to improve performance
                s(ppI >= r,c) = s(ppI >= r,c) + " ";
            end
        end
    end
    
%-----------------------------------------------------------------------
    function out = getStrOutput(v)
        % Let the built-in cell display method show the contents
        % of each cell however it sees fit.  For example, it will
        % display only a size/type if the contents are large.  It
        % puts quotes around char contents, which char wouldn't.                
        % Any newlines in the data are replaced with arrows, so
        % splitlines is guaranteed to split on elements as
        % opposed to newlines within the data. Therefore,
        % deleting empty newlines should not change underlying
        % data.
        out = strip(splitlines(string(evalc('disp(v)'))));
        out(out == "") = [];
        
        % If the command window is narrow, this will "unfold" the paged
        % display. 
        if length(out) ~= t.rowDim.length
            if isstring(v)
                quoteChar = """";
                missingString = "<missing>";
            else
                quoteChar = "'";
                missingString = "''";
            end
            final = strings(size(v));
            % Get an estimate of the command window width by truncating a
            % long character array
            winLenEstimate = strlength(matlab.internal.display.truncateLine(nUnder(100000)));
            missingVals = ismissing(v);
            final(~missingVals) = quoteChar + vectorizedTruncateLine(v(~missingVals),winLenEstimate/size(v,2)) + quoteChar;
            final(missingVals) = missingString;
            final = alignTabularContents(final);
            out = join(final,'    ',2);
        end
    end

%-----------------------------------------------------------------------
    function [varnames,nestedVarnames,underlines] = getVarNamesDispLines()
 
        varStrs = strings(1,t.varDim.length);
        ulStrs = strings(1,t.varDim.length);
        
        for ii = 1:t.varDim.length
            varname = string(t.varDim.labels{ii});
            % Bold each variable name and put pad out if necessary to match the
            % data display width.
            varStrs(ii) = pad(strongBegin + varname + strongEnd, ... % wrap tightly with strong tags
                              varDispWidths(ii) + strongTagsLength,'both',' ');
            if haveNestedTable
                % Pad the nested var names out to the full data display width,
                % accounting for bold markup tags around each nested name.
                nestedVarnameStrs(ii) = pad(nestedVarnameStrs(ii), ...
                                            varDispWidths(ii) + numNestedVars(ii)*strongTagsLength,'both',' ');
            end
            % Create underlines under each variable name to the full data
            % display width.
            ulStrs(ii) = nUnder(varDispWidths(ii));
        end
        
        if t.dispRowLabelsHeader
            % Need to print the name of the rowDim; add it to the beginning
            % of the array
            rowDimName = string(t.metaDim.labels{1});
            
            ulStrs = [nUnder(rownameWidth), ulStrs];        
            varStrs = [pad(strongBegin + rowDimName + strongEnd, ... % wrap tightly with strong tags
                           rownameWidth + strongTagsLength,'both',' '), varStrs];
            nestedVarnameStrs = [nSpaces(rownameWidth), nestedVarnameStrs];
        end
        
        % Join all the variable names and underlines with spaces.
        spacesBetween = string(nSpaces(between));
        if ~t.dispRowLabelsHeader && t.rowDim.hasLabels
            % table doesn't print a header (dimname) for rownames, but we
            % still have to account for the width with additional spaces.
            leadingSpaces = nSpaces(indent + rownameWidth + between);
        else
            % timetables always wind up here, and tables without rownames
            leadingSpaces = nSpaces(indent);
        end
        
        varnames = leadingSpaces + join(varStrs,spacesBetween);
        nestedVarnames = leadingSpaces + join(nestedVarnameStrs,spacesBetween);
        underlines = leadingSpaces + join(strongBegin + ulStrs + strongEnd, spacesBetween) + looseline;
    end

end % main function

%-----------------------------------------------------------------------
function [dblFmt,snglFmt] = getFloatFormats()
% Display for double/single will follow 'format long/short g/e' or 'format bank'
% from the command window. 'format long/short' (no 'g/e') is not supported
% because it often needs to print a leading scale factor.
switch lower(matlab.internal.display.format)
case {'short' 'shortg' 'shorteng'}
    dblFmt  = '%.5g    ';
    snglFmt = '%.5g    ';
case {'long' 'longg' 'longeng'}
    dblFmt  = '%.15g    ';
    snglFmt = '%.7g    ';
case 'shorte'
    dblFmt  = '%.4e    ';
    snglFmt = '%.4e    ';
case 'longe'
    dblFmt  = '%.14e    ';
    snglFmt = '%.6e    ';
case 'bank'
    dblFmt  = '%.2f    ';
    snglFmt = '%.2f    ';
otherwise % rat, hex, + fall back to shortg
    dblFmt  = '%.5g    ';
    snglFmt = '%.5g    ';
end
end


%-----------------------------------------------------------------------
function str = removeBraces(str)
str = regexprep(str,'\{(.*)\}','$1');
end

function strs = boldifyLinks(strs)
    % adds the bold to hyperlinks
    hotlinkPattern = "(<a\s+href\s*=\s*""[^""]*""[^>]*)(>.*?</a>)";
    strs = regexprep(strs, hotlinkPattern, "$1 style=""font-weight:bold""$2");
    % break each string into non-anchor, and anchor parts, then bold the
    % non-anchor parts
    [nonLinkText,links] = regexp(strs, hotlinkPattern, 'split', 'match');
    if iscell(nonLinkText)
        for i = 1:numel(strs)
            strs(i) = boldNonLinkAndJoin(nonLinkText{i},links{i});
        end
    else
        strs = boldNonLinkAndJoin(nonLinkText,links);
    end
end

function str = boldNonLinkAndJoin(nonLink,Link)
    needsTags = (strlength(strtrim(nonLink)) > 0);
    nonLink(needsTags) = "<strong>" + nonLink(needsTags) + "</strong>";
    if ~isempty(Link)
        str = join(nonLink,Link);
    else
        str = nonLink;
    end
end

%-----------------------------------------------------------------------
function varStr = getInfoDisplay(var)
sz = size(var);
szStr = "[1" + join(compose("x%d",sz(2:end)),"");
varStr = repmat(compose("%s %s]",szStr, class(var)),sz(1),1);
end

function len = vectorizedWrappedLength(s)
len = zeros(size(s));
for i = 1:numel(s)
    len(i) = matlab.internal.display.wrappedLength(s(i));
end
end

function s = vectorizedTruncateLine(s,scale)
for i = 1:numel(s)
    s{i} = matlab.internal.display.truncateLine(s{i},scale);
end
end

function sp = nSpaces(n)
    sp = string(repmat(' ',1,n));
end

function ul = nUnder(n)
    ul = string(repmat('_',1,n));
end