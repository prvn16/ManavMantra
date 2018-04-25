%savefig Save figures to a MATLAB figure file
%  
%  savefig(FILENAME) saves the current figure to a file named FILENAME  
%
%  savefig(H, FILENAME) saves the figures identified by the graphics
%  handle array H to a MATLAB figure file called FILENAME.  MATLAB figure
%  files allow you to store entire figures and open them again later or
%  share them with others.  If H is not specified, the current figure is
%  saved.  If FILENAME is not specified, savefig saves to a file called
%  Untitled.fig.  If FILENAME does not include an extension, MATLAB appends
%  .fig.
%
%  savefig(H,FILENAME,'compact') saves the figures identified by the graphics 
%  handle array H to a MATLAB figure file called FILENAME. This MATLAB figure 
%  file can be opened only in R2014b or later version of MATLAB. Using the 
%  'compact' option reduces the size of the MATLAB figure file and the 
%  time required to create the file.
%
%  To save just a part of a figure (for example a specific axes), or to
%  save graphics handles alongside data, use the SAVE command to create a
%  MAT-file.
%
%  Example:
%    peaks;
%    savefig('PeaksFile');
%    close(gcf);
%    ...
%    openfig('PeaksFile');
%
%  See also openfig, open, save, load.

%  Copyright 2011-2014 The MathWorks, Inc.

