%GCO Get handle to current object.
%   OBJECT = GCO returns the current object in the current figure.
%
%   OBJECT = GCO(FIG) returns the current object in the figure FIG.
%
%   The current object is the last object clicked on, excluding
%   uimenus.  If the click was not over a figure child, the
%   figure itself will be the current object.
%
%   The handle of the current object is stored in the figure
%   property CurrentObject, and can be accessed directly using GET
%   and SET.
%
%   Use GCO in a callback to obtain the handle of the object that
%   was clicked on.  MATLAB updates the current object before
%   executing each callback, so the current object may change if
%   one callback is interrupted by another.  To obtain the right
%   handle during a callback, get the current object early, before
%   any calls to DRAWNOW, WAITFOR, PAUSE, FIGURE, or GETFRAME which
%   provide opportunities for other callbacks to interrupt.
%
%   If no figures exist, GCO returns an empty GraphicsPlaceholder.
%
%   See also GCBO, GCF, GCA, GCBF.

%   Copyright 1984-2015 The MathWorks, Inc. 
