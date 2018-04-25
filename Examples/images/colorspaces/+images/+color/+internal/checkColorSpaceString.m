function [color_space,num_components] = checkColorSpaceString(str)
% checkColorSpaceString Validate color space string inputs
%
%    [color_space,num_components] = images.color.internal.checkColorSpaceString(str)
%
%    Checks that the input string is one of the valid set of color space strings. Returns the color
%    space string in canonical form. Returns the number of color components ('any' for the color
%    space 'generic').

%    Copyright 2014 The MathWorks, Inc.

try
    color_space = validatestring(str,{'generic','RGB','XYZ','Lab','CMYK','CMY','gray'});
catch e
    throwAsCaller(e);
end

switch color_space
    case 'generic'
        num_components = 'any';
    case {'RGB','XYZ','Lab','CMY'}
        num_components = 3;
    case 'CMYK'
        num_components = 4;
    case 'gray'
        num_components = 1;
end

