function lines = createLinesForErrorBarStruct(hErrorBar)
% convert x/y/ values into the line data
% needed by the older graphics system lines. This is required to be able
% to create a .FIG file that is compatible with older versions of MATLAB.

%   Copyright 2013-2015 The MathWorks, Inc.
    
    [x,y,l,u] = deal(hErrorBar.XData,hErrorBar.YData,abs(hErrorBar.LData),abs(hErrorBar.UData));
    
    if isempty(l)
        l = NaN(size(x));
    end
    
    if isempty(u)
        u = NaN(size(x));
    end

    x = x(:);
    y = y(:);
    u = u(:);
    l = l(:);
    hAx = ancestor(hErrorBar,'Axes');
    if strcmpi(get(hAx,'XScale'),'Linear')
        tee = (max(x(:))-min(x(:)))/100;  % make tee .01 x-distance for error bars
        if tee == 0, tee = abs(x)/100; end
        xl = x - tee;
        xr = x + tee;
    else
        % In log scale, we need to scale the error bars
        % The following line is equivalent to
        % teeX = log(x); tee = (max(teeX(:))-min(teeX(:)))/100;
        % projected back into log space
        tee = (max(x(:))-min(x(:)))^.01;  % make tee .01 x-distance for error bars
        if tee == 0, tee = abs(x).^.01; end
        % The following line is equivalent to
        % xl = 10.^(teeX - tee)
        xl = x ./ tee;
        % The following line is equivalent to
        % xr = 10.^(teeX + tee)
        xr = x .* tee;
    end
    ytop = y + u;
    ybot = y - l;
    n = 1;
    npt = length(y);

    % build up nan-separated vector for bars
    xb = zeros(npt*9,n);
    xb(1:9:end,:) = x;
    xb(2:9:end,:) = x;
    xb(3:9:end,:) = NaN;
    xb(4:9:end,:) = xl;
    xb(5:9:end,:) = xr;
    xb(6:9:end,:) = NaN;
    xb(7:9:end,:) = xl;
    xb(8:9:end,:) = xr;
    xb(9:9:end,:) = NaN;

    yb = zeros(npt*9,n);
    yb(1:9:end,:) = ytop;
    yb(2:9:end,:) = ybot;
    yb(3:9:end,:) = NaN;
    yb(4:9:end,:) = ytop;
    yb(5:9:end,:) = ytop;
    yb(6:9:end,:) = NaN;
    yb(7:9:end,:) = ybot;
    yb(8:9:end,:) = ybot;
    yb(9:9:end,:) = NaN;

    lines(1)=matlab.graphics.primitive.Line('XData',xb,...
                                            'YData',yb,...
                                            'Color',hErrorBar.Color,...
                                            'LineWidth',hErrorBar.LineWidth,...
                                            'LineStyle',hErrorBar.LineStyle,...
                                            'HitTest','off');
    
    lines(2)=matlab.graphics.primitive.Line('XData',x,...
                                            'YData',y,...
                                            'Color',hErrorBar.Color,...
                                            'LineWidth',hErrorBar.LineWidth,...
                                            'LineStyle',hErrorBar.LineStyle,...
                                            'HitTest','off');


end
