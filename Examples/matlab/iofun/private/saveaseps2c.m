function saveaseps2c( h, name )
%SAVEASEPS2C Save Figure to color Encapsulated Postscript file with TIFF preview.
%   Uses level 2 PostScript operators.

%   Copyright 1984-2002 The MathWorks, Inc. 

print( h, name, '-deps2c', '-tiff' )
