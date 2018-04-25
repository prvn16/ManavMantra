function out = getCellDisplayOutput(inp)
    % This function returns the display of the input cell array, without
    % the header added
    
    % Copyright 2017 The MathWorks, Inc.
    assert(iscell(inp), 'Input is not a cell');
    out = evalc('feature(''hotlinks'',''off'');display(inp,inputname(1));');
    
    % Removing header
    expr = regexprep(['.*?' matlab.internal.display.getHeader(inp) '\n{1,2}'], '</?a(|\s+[^>]+)>', '');
    
    out = regexprep(out,expr,'');
    
    % If N dimensional, we have to remove the variable name around the
    % individual pages
    if numel(size(inp)) > 2
        expr1 = [inputname(1) '(\(:.*?\))'];
        out = regexprep(out, expr1,'$1');
    end
end