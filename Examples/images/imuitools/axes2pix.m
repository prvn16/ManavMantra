function pixelx = axes2pix(dim, xdata, axesx)
%AXES2PIX Convert axes coordinate to pixel coordinate.  
%   PIXELX = AXES2PIX(DIM, XDATA, AXESX) converts an axes coordinate into a
%   pixel coordinate.  For example if pt = get(gca,'CurrentPoint') then AXESX
%   could be pt(1,1) or pt(1,2). AXESX must be in pixel coordinates. XDATA is
%   a two-element vector returned by get(image_handle, 'XData') or
%   get(image_handle,'YData').  DIM is the number of image columns for the x
%   coordinate, or the number of image rows for the y coordinate.
%
%   Class Support
%   -------------
%   DIM, XDATA, and AXESX can be double.  The output is double.
%  
%   Note
%   ----      
%   AXES2PIX performs minimal checking on the validity of AXESX, DIM, or
%   XDATA. For example, AXES2PIX returns a negative coordinate if AXESX is
%   less than XDATA(1). The function calling AXES2PIX bears responsibility for
%   error checking.
%
%   Examples
%   --------
%       % Example with default XData and YData.
%       h = imshow('pout.tif');
%       [nrows,ncols] = size(get(h,'CData'));
%       xdata = get(h,'XData')
%       ydata = get(h,'YData')
%       px = axes2pix(ncols,xdata,30)
%       py = axes2pix(nrows,ydata,30)
%
%       % Example with non-default XData and YData.
%       xdata = [10 100]
%       ydata = [20 90]
%       px = axes2pix(ncols,xdata,30)
%       py = axes2pix(nrows,ydata,30)

%   Copyright 1993-2015 The MathWorks, Inc.
%   


if (max(size(dim)) ~= 1)
    error(message('images:axes2pix:firstArgNotScalar'));
end

if (min(size(xdata)) > 1)
    error(message('images:axes2pix:xdataMustBeVector'));
end

xfirst = xdata(1);
xlast = xdata(max(size(xdata)));

if (dim == 1)
  pixelx = axesx - xfirst + 1;
  return;
end

delta = xlast - xfirst;
if delta == 0
  xslope = 1;
else
  xslope = (dim - 1) / delta;
end

if ((xslope == 1) && (xfirst == 1))
  pixelx = axesx;
else
  pixelx = xslope * (axesx - xfirst) + 1;
end
