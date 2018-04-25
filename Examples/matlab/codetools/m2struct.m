function [out,copyright,revision] = m2struct(txt)
%M2STRUCT Break M-code into cells.
%   STRUCT = M2STRUCT(MCODE) breaks MCODE into cells and returns a structure
%   array STRUCT.

% Copyright 1984-2006 The MathWorks, Inc.

% if usejava('jvm') && ...
%         com.mathworks.services.Prefs.getBooleanPref('EditorFunctionPublishingBeta',false)
    isBeta = true;
% else
%     isBeta = false;
% end

% Normalize line endings to Unix-style.
newLine = char(10);
pcNewLine = char([13 10]);
macNewLine = char(13);
txt = strrep(txt,pcNewLine,newLine);
txt = strrep(txt,macNewLine,newLine);

% State is one of the following: {'inTopComment','inCellDelimiter','inCode'}.
state = 'inCode';
cellNum = 1;
out(1).title = '';
out(1).text = {};
out(1).code = '';
if isBeta
    out(1).start = 1;
    out(1).isCell = true;
end

copyright = '';
revision = '';

txt = [newLine txt newLine];
returns = find(txt==newLine);

% Special case Copyright and Revision lines.
% The parens on the next line around the "e" and the "a" are to keep CVS
% from messing with this line of M-code.
revisionPattern = '^\%\s*\$R(e)vision: .*?$(\s+\$D(a)te: .*$)?\s*$';
copyrightPattern = '^\%\s*Copyright.*The MathWorks, Inc.\s*$';

for i = 1:(length(returns)-1)
    % Get the next line
    txtLine = txt((returns(i)+1):(returns(i+1)-1));
    txtLine = deblank(txtLine);

    % Check if this line moves us to a new state.
    if strcmp(txtLine,'%%') || strncmp(txtLine,'%% ',3)
        state = 'inCellDelimiter';
    elseif isBeta && ~isempty(regexp(txtLine,'^\s*%{3}(?: .*)?\s*$','once'))
        state = 'inTextDelimiter';
    elseif strcmp(txtLine,'%') || strncmp(txtLine,'% ',2) || ...
            (isBeta && ~isempty(regexp(txtLine,'^\s*%(?: .*)?\s*$','once')))
        % Either a top comment or a code comment.  No change of state.
    else
        state = 'inCode';
    end

    % Special case Copyright and Revision lines.
    if ~isempty(regexp(txtLine,copyrightPattern,'once'))
        copyright = txtLine;
        copyright(1) = [];
        copyright = copyright(find(copyright ~= ' ',1,'first'):end);
        returnTo = state;
        state = 'skip';
    elseif ~isempty(regexp(txtLine,revisionPattern,'once'))
        revision = txtLine;
        revision(1) = [];
        revision = revision(find(revision ~= ' ',1,'first'):end);
        returnTo = state;
        state = 'skip';
    elseif strcmp(deblank(txtLine),'displayEndOfDemoMessage(mfilename)')
        % Leave this line out of the published HTML.
        returnTo = state;
        state = 'skip';
    end

    % Sort the line into the proper category
    switch state

        case 'inTopComment'
            if isBeta
                txtLine = fliplr(deblank(fliplr(txtLine)));
            end
            % Remove the initial "%"
            txtLine(1) = [];
            % And the space after it, if there is one
            if ~isempty(txtLine) && (txtLine(1) == ' ')
                txtLine(1) = [];
            end
            out(cellNum).text{end+1} = txtLine;
            state = 'inTopComment';

        case 'inCode'
            if ~isempty(out(cellNum).code)
                out(cellNum).code = [out(cellNum).code newLine txtLine];
            elseif ~isempty(txtLine)
                out(cellNum).code = txtLine;
            end

        case {'inCellDelimiter','inTextDelimiter'}
            % Extract the step title (if any)
            titleMatch = regexp(txtLine,'^\s*%{2,3}\s*(.*)$','tokens','once');
            cellTitle = deblank(titleMatch{1});
            % Remove leading spaces
            cellTitle = strtrim(cellTitle);
            % Increment cell counter and initialize cell contents
            if (~isempty(out(cellNum).text) || ...
                    ~isempty(out(cellNum).code) || ...
                    ~isempty(out(cellNum).title))
                cellNum = cellNum + 1;
                out(cellNum).title = '';
                out(cellNum).text = {};
                out(cellNum).code = '';
                if isBeta
                    out(cellNum).start = i;
                    switch state
                        case 'inCellDelimiter'
                            isCell = true;
                        case 'inTextDelimiter'
                            isCell = false;
                    end
                    out(cellNum).isCell = isCell;
                end
            end
            out(cellNum).title = cellTitle;
            state = 'inTopComment';

        case 'skip'
            % Ignore this line.
            state = returnTo;

    end
end

% Strip trailing newlines from code.
for i = 1:length(out)
    code = out(i).code;
    % Do this isempty check to be sure we don't end up with [1x0 char].
    if ~isempty(code)
        out(i).code = code(1:find(code ~= 10,1,'last'));
    end
end
