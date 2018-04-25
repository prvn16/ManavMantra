function h = openFigure(varargin)
%openFigure Open a MATLAB figure file
%
%  openFigure(FILENAME) loads handle graphics figures from the MATLAB
%  figure file called FILENAME.  Figure visibility and positions are
%  restored to the values they had when saved.  If FILENAME is not
%  specified then openFigure will attempt to load the file 'Untitled.fig'.
%  If FILENAME does not include an extension but a file with a .fig
%  extension exists, MATLAB appends .fig.
%
%  To load figures or other graphics objects from a MAT-file, use the LOAD
%  command.
%
%  openFigure(..., 'reuse') opens new figures from the figure file
%  only if there are no existing figures that were opened from the file
%  using openFigure.  If there are existing figures then the file is not
%  opened and the last-opened figure handle is reused instead.
%
%  openFigure(..., 'visible') forces the figure windows to be visible
%  and positioned on-screen.
%
%  openFigure(..., 'invisible') forces the figure windows to be invisible
%  but still positioned on-screen.
%
%  F = openFigure(...) returns an array containing handles to the figures.
%
%  When you load a fig file that was created in an earlier version of
%  MATLAB, it may contain graphics objects other than figures.  In this
%  case the returned array of handles will also contain these objects.
%
%  Example:
%    peaks;
%    saveFigure('PeaksFile');
%    close(gcf);
%    ...
%    % Create a new figure.
%    h = openFigure('PeaksFile');  
%
%    % Reuse and return the existing figure.
%    h = openFigure('PeaksFile', 'reuse') 
%
%    % Reuse the existing figure and make it invisible.
%    h = openFigure('PeaksFile', 'reuse', 'invisible')
%
%  See also saveFigure, open, load, save.

%  Copyright 2012-2015 The MathWorks, Inc.

warning(message('MATLAB:openFigure:FunctionToBeRemoved'));
h = openfig(varargin{:});

