function A = editmoveresize(A, varargin)
%AXISOBJ/EDITMOVERESIZE Move and resize axisobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

newDrag = ~get(A,'Draggable');
A = set(A,'Draggable', newDrag);
A = set(A,'IsSelected', newDrag);


