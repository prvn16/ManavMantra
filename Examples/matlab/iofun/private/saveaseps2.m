function saveaseps2( h, name )
%SAVEASEPS2 Save Figure to Encapsulated Postscript file with TIFF preview.
%   Uses level 2 PostScript operators.

%   Copyright 1984-2002 The MathWorks, Inc. 

print( h, name, '-deps2', '-tiff' )
