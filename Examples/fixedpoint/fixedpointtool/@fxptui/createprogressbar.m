function pb = createprogressbar(varargin)
%CREATEPROGRESSBAR

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.

if length(varargin) > 1
    h = varargin{1};
    title = varargin{2};
elseif (length(varargin) == 1) && isa(varargin{1},'fxptui.explorer') 
    h = varargin{1};
    title = 'Fixed-Point Tool'; % product title should not be translated/localized. 
else
    h = [];
    title = varargin{1};
end

pb  = com.mathworks.toolbox.simulink.progressbar.SLProgressBar.CreateProgressBar(title);
pb.setCircularProgressBar(1);
if ~isempty(h)
    %p = x0, y0, width, height
    p = h.position;
    %find the center of me
    x = round(p(1) + p(3)/2);
    y = round(p(2) + p(4)/2);
    %get pb rectangle
    r = pb.getBounds;
    w = r.getWidth;
    %adjust x and so me center == pb center
    h = r.getHeight;
    x = round(x-w/2);
    y = round(y-h/2);
    %position pb
    pb.setLocation(x,y)
end
pb.show;

% [EOF]
