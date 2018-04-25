function resetVisual(this)
%RESETVISUAL Blank out the image on the visual.

%   Copyright 2011-2015 The MathWorks, Inc.

hImage = this.Image;
set(hImage, 'CData', zeros(size(get(hImage, 'CData'))));

% [EOF]