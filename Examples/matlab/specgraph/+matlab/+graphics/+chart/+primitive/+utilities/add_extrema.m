function [xbounds_out, ybounds_out, zbounds_out] = add_extrema(xbounds_in, ybounds_in, zbounds_in, xp, yp, zLevel)

%   Copyright 2013-2015 The MathWorks, Inc.

    [~,xmin] = min(xp);
    [~,xmax] = max(xp);
    [~,ymin] = min(yp);
    [~,ymax] = max(yp);
    indices = unique([xmin,ymin,xmax,ymax]);
    xbounds_out = [xbounds_in, xp(indices)];
    ybounds_out = [ybounds_in, yp(indices)];
    if isempty(zLevel)
        zbounds_out = zbounds_in;
    else
        zbounds_out = [zbounds_in, zLevel+zeros(1,numel(indices))];
    end
end
