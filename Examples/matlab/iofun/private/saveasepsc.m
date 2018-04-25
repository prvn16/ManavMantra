function saveasepsc( h, name )
%SAVEASEPSC Save Figure to color Encapsulated Postscript file with TIFF preview.

%   Copyright 1984-2002 The MathWorks, Inc. 

print( h, name, '-depsc', '-tiff' )
