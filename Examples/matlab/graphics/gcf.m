%GCF Get handle to current figure.
%   H = GCF returns the handle of the current figure. The current
%   figure is the window into which graphics commands like PLOT,
%   TITLE, SURF, etc. will draw.
%
%   The handle of the current figure is stored in the root
%   property CurrentFigure, and can be queried directly using GET,
%   and modified using FIGURE or SET.
%
%   Clicking on uimenus and uicontrols contained within a figure,
%   or clicking on the drawing area of a figure cause that
%   figure to become current.
%
%   The current figure is not necessarily the frontmost figure on
%   the screen.
%
%   GCF should not be relied upon during callbacks to obtain the
%   handle of the figure whose callback is executing - use GCBO
%   for that purpose.
%
%   See also FIGURE, CLOSE, CLF, GCA, GCBO, GCO, GCBF.

%   Copyright 1984-2015 The MathWorks, Inc.
