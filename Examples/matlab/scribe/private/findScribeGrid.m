function SG = findScribeGrid(fig)
% Given a figure, return the scribe grid associated with it.

%   Copyright 2010-2014 The MathWorks, Inc.

scribeunder = getDefaultCamera(fig,'underlay');
SG = getScribeGrid(scribeunder);
