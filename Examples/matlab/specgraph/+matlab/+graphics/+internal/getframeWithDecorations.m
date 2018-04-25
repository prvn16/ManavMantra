function X = getframeWithDecorations(f, withDecorations, doDrawnow)
% GETFRAMEWITHDECORATIONS(f) Capture the whole figure including window decorations.
% GETFRAMEWITHDECORATIONS(f, withDecorations) Capture the whole figure, including decorations if the flag is true

% Copyright 1984-2016 The MathWorks, Inc.
    
if nargin < 2
    withDecorations = true;
end

if nargin < 3
   doDrawnow = true;
end

% some clients may have done preemptive drawnow on their own
% avoiding calls here may save a little time 
if doDrawnow
   drawnow
   drawnow
end

jf = matlab.graphics.internal.getFigureJavaFrame(f); 
c = jf.getAxisComponent();

try
    u = getFrameImage(c, withDecorations);
    if isempty(u)
        % Try again, one time
        opts.fig = f;
        opts.Visible = get(f, 'Visible');
        cleanupHandler = onCleanup(@() doCleanup(opts));
        set(f,'Visible','on')
        drawnow
        drawnow
        u = getFrameImage(c, withDecorations);
    end
catch e
    matlab.graphics.internal.processPrintingError(e);
    rethrow(e);
end

% Need to initialize fields in this order
X.cdata = u;
X.colormap = [];
end

%===============================================================================
function doCleanup(opts)
set(opts.fig, 'Visible', opts.Visible);
drawnow;
end

% LocalWords:  recalc yoffset
