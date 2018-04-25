% Two dimensional graphs.
% 
% Elementary X-Y graphs.
%   plot      - Linear plot.
%   loglog    - Log-log scale plot.
%   semilogx  - Semi-log scale plot.
%   semilogy  - Semi-log scale plot.
%   polar     - Polar coordinate plot.
%   plotyy    - Graphs with y tick labels on the left and right.
%
% Axis control.
%   axis       - Control axis scaling and appearance.
%   zoom       - Zoom in and out on a 2-D plot.
%   grid       - Grid lines.
%   box        - Axis box.
%   rbbox      - Rubberband box.
%   hold       - Hold current graph.
%   axes       - Create axes in arbitrary positions.
%   subplot    - Create axes in tiled positions.
%
% Graph annotation.
%   plotedit  - Tools for editing and annotating plots.
%   title     - Graph title.
%   xlabel    - X-axis label.
%   ylabel    - Y-axis label. 
%   texlabel  - Produces the TeX format from a character string.
%   text      - Text annotation.
%   gtext     - Place text with mouse.
%
% Hardcopy and printing.
%   print      - Print graph or Simulink system; or save graph to MATLAB file.
%   printopt   - Printer defaults.
%   orient     - Set paper orientation. 
%
% See also GRAPH3D, SPECGRAPH.

% Utilities
%   lscan     - Scan for good legend location.
%   moveaxis  - Used by LEGEND to enable dragging of legend.
%
% Scribe utilties.
%   doclick       - Processes ButtonDown on MATLAB objects.
%   dokeypress    - Handle key press functions for plot editor figures
%   domymenu      - handle menus for Plot editor
%   doresize      - Calls figobj doresize function.
%   enddrag       - Plot Editor helper function.
%   getobj        - Retrieve Scribe Object from Handle Graphics handle.
%   middrag       - Plot Editor helper function.
%   prepdrag      - Plot Editor helper function.
%   putdowntext   - Plot Editor helper function.
%   scribeaxesdlg - Axes property dialog helper function for Plot Editor
%   scribelinedlg - Line property dialog helper function for Plot Editor
%   scribeclearmode       - Plot Editor helper function.
%   scribeeventhandler    - Plot Editor helper function.
%   scriberestoresavefcns - Plot Editor helper function.
%   scribetextdlg - Edit Text and Font Properties in Plot Editor.
%
% Other utilities.
%   basicfitdatastat 	- switchyard for Basic Fitting and Data Statistics.
%   figtoolset 		- CreateFcns for figure toolbar toggles
%   getcolumn		- Get a column of data
%   getorcreateobj	- Plot Editor helper function
%   getscribecontextmenu - Get the scribe uicontextmenu object
%   getscribeobjectdata	- Return the scribe object data
%   jpropeditutils     - a utility function for PropertyEditor.java 
%   lineseries		- Line plot helper function
%   pan			- Interactively pan the view of a plot
%   setscribecontextmenu - Set the scribe uicontextmenu object
%   setscribeobjectdata	- Set the scribe object data

%   Copyright 1984-2017 The MathWorks, Inc.
