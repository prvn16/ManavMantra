function info = createStackInfo(stack)

% Copyright 2012-2016 The MathWorks, Inc.

import matlab.unittest.internal.diagnostics.CommandHyperlinkableString;
import matlab.unittest.internal.diagnostics.PlainString;

atText = getString(message('MATLAB:unittest:Diagnostic:At'));
inSpace = sprintf('%s ', getString(message('MATLAB:unittest:Diagnostic:In')));

info = repmat(PlainString, 1, numel(stack));
for idx = 1:length(stack)
    frame = stack(idx);
        
    % Handle the empty case
    if isempty(frame.file)
        info(idx) = sprintf('%s(%s)', inSpace, frame.name);
        continue;
    end
    
    fileThenNameAtLine = sprintf('%s (%s) %s %d', frame.file, frame.name, atText, frame.line);
    
    isMATLABFile = ~isempty(regexpi(frame.file,'\.m(lx)?$','once')); 
    if isMATLABFile
        % Make the stack frame hyperlinkable
        file = strrep(frame.file, '''', '''''');
        info(idx) = inSpace + CommandHyperlinkableString(fileThenNameAtLine, ...
            sprintf('opentoline(''%s'',%d,1)', file, frame.line));
        continue;
    end
    
    % Don't include a hyperlink
    info(idx) = sprintf('%s%s', inSpace, fileThenNameAtLine);
end

info = join([PlainString.empty(1,0), info], newline);

% LocalWords:  unhyperlinked lx Hyperlinkable hyperlinkable
