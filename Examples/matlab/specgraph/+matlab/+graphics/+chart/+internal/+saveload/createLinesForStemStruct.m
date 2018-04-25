function lines = createLinesForStemStruct(hStem)
% convert x/y/ values into the line data
% needed by the older graphics system lines. This is required to be able
% to create a .FIG file that is compatible with older versions of MATLAB.

%   Copyright 2013-2015 The MathWorks, Inc.
    
    is3D = ~isempty(hStem.ZData);
    
    % force data to be column vector
    [x,y] = deal(hStem.XData,hStem.YData);
    x = x(:); y = y(:);
    if is3D
        z = hStem.ZData; z = z(:);
    end
    
    % Create data for plotting stem marker and stem line.
    % NaNs are used to make non-continuos line segments.
    m = length(x);
    xx = zeros(3*m,1);
    xx(1:3:3*m) = x;
    xx(2:3:3*m) = x;
    xx(3:3:3*m) = NaN;
    
    if is3D
        yy = zeros(3*m,1);
        yy(1:3:3*m) = y;
        yy(2:3:3*m) = y;
        yy(3:3:3*m) = NaN;
        
        zz = hStem.BaseValue*ones(3*m,1);
        zz(1:3:3*m) = z;
        zz(3:3:3*m) = NaN;
    else
        yy = hStem.BaseValue*ones(3*m,1);
        yy(2:3:3*m) = y;
        yy(3:3:3*m) = NaN;
        
        zz = [];
    end
    
    markerFaceColor = hStem.MarkerFaceColor;
    if (strcmp(markerFaceColor, 'auto'))
        markerFaceColor = hStem.Color;
    end
    
    lines(1) = matlab.graphics.primitive.Line('Color',hStem.Color,...
                                              'LineStyle','none',...
                                              'Marker',hStem.Marker,...
                                              'MarkerFaceColor',markerFaceColor,...
                                              'XData',hStem.XData,...
                                              'YData',hStem.YData,...
                                              'ZData',hStem.ZData,...
                                              'HitTest','off');
    lines(2) = matlab.graphics.primitive.Line('Color',hStem.Color,...
                                              'XData',xx,...
                                              'YData',yy,...
                                              'ZData',zz,...
                                              'HitTest','off');

end
