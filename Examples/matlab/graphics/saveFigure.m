function saveFigure(varargin)
%saveFigure Save figures to a MATLAB figure file
%  
%  saveFigure(H, FILENAME) saves the figures identified by the graphics
%  handle array H to a MATLAB figure file called FILENAME.  MATLAB figure
%  files allow you to store entire figures and open them again later or
%  share them with others.  If H is not specified, the current figure is
%  saved.  If FILENAME is not specified, saveFigure saves to a file called
%  Untitled.fig.  If FILENAME does not include an extension, MATLAB appends
%  .fig.
%
%  To save just a part of a figure (for example a specific axes), or to
%  save graphics handles alongside data, use the SAVE command to create a
%  MAT-file.
%
%  Example:
%    peaks;
%    saveFigure('PeaksFile');
%    close(gcf);
%    ...
%    openFigure('PeaksFile');
%
%  See also openFigure, open, save, load.

%  Copyright 2011-2012 The MathWorks, Inc.


warning(message('MATLAB:saveFigure:FunctionToBeRemoved'));
savefig(varargin{:});


