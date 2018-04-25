function helpStr = extractH1Line(fullHelp)
    % extractH1Line - extracts the H1-line from the input help string.

    % Copyright 2009 The MathWorks, Inc.
    helpStr = regexp(fullHelp,'.*','dotexceptnewline', 'match', 'once');
end