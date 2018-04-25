function str = dimensionString(inp)
    sz = size(inp);
    ndims = length(sz);
    str = num2str(sz(1));
    dimStr = char(215);   
    
    if ~matlab.internal.display.isDesktopInUse
        dimStr = char(120);
    end        
    
    if ndims <=4
        for i=2:ndims
            str = [str,dimStr,num2str(sz(i))];  %#ok<AGROW>
        end
    else
        str = [num2str(ndims) '-D'];
    end
end