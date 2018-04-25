function line = createLineForStairsStruct(hStairs)
% convert x/y/ values into the line data
% needed by the older graphics system lines. This is required to be able
% to create a .FIG file that is compatible with older versions of MATLAB.

%   Copyright 2013-2017 The MathWorks, Inc.
    
    [x,y] = deal(hStairs.XData,hStairs.YData);
    x = x(:);
    y = y(:);

    [n,nc] = size(y); 
    ndx = [1:n;1:n];
    y2 = y(ndx(1:2*n-1),:);
    if size(x,2)==1
      x2 = x(ndx(2:2*n),ones(1,nc));
    else
      x2 = x(ndx(2:2*n),:);
    end
    
    line=matlab.graphics.primitive.Line('XData',x2,...
                                        'YData',y2,...
                                        'Color',hStairs.Color,...
                                        'LineWidth',hStairs.LineWidth,...
                                        'LineStyle',hStairs.LineStyle,...
                                        'Marker',hStairs.Marker,...
                                        'MarkerSize',hStairs.MarkerSize,...
                                        'HitTest','off');
end
