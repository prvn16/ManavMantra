function out = getEmptyRepresentationOfContainedData(inp, displayFlag)
    % This returns the representation of an empty data in a cell array
    % inp - The contained value
    % displayFlag - Logical flag to determine whether or not this is a
    % disp/display invocation
    out = '';
    openDelim = '';
    closeDelim = '';
    
    if displayFlag
        openDelim = '{';
        closeDelim = '}';
    else
        openDelim = '[';
        closeDelim = ']';
    end
    
    if isempty(inp)
        out = [openDelim matlab.internal.display.dimensionString(inp) char(32) matlab.internal.display.getDisplayClassName(inp) closeDelim];
    end
end