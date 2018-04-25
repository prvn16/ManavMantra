function h = fighandle(HG)
%FIGHANDLE/FIGHANDLE Make fighandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2005 The MathWorks, Inc. 

if nargin==0
   h.Class = 'fighandle';
   h.figStoreHGHandle = [];
   h = class(h,'fighandle');
   return
end

h.Class = 'fighandle';
h.figStoreHGHandle = HG;
h = class(h,'fighandle');

