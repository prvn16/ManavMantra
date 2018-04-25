function updateColorMap(this, eventStruct) %#ok
%UPDATECOLORMAP Set new color map and scaling parameters into scope
%  Sets image datatype conversion handler, and colormap scaling.

%   Copyright 2007-2015 The MathWorks, Inc.

this.VideoInfo.DisplayDataType = this.ColorMap.DisplayDataType;

% [EOF]