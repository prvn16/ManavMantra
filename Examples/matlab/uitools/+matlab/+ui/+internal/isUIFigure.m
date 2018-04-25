function bool = isUIFigure(f)
%isUIFigure checks if the given figure is a java or web figure using 
% JavaFrame property.
% f is figure handle
% bool is output boolean value
%
% Copyright 2017 The MathWorks, Inc.

% if JavaFrame is empty, then this is a web figure.
if ~isempty(f) && isempty(get(f,'JavaFrame_I'))
    bool = true;
else
    bool = false;
end
end