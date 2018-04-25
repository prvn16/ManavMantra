function xyz = uvl2xyz(uvl)
%UVL2XYZ Converts CIE u,v and Luminance to CIEXYZ 
%   xyz = UVL2XYZ(uvl) converts to 1931 CIE Chromaticity and Luminance
%   1931 CIEXYZ tristimulus values scaled to 1.0
%   Both xyz and uvl are n x 3 vectors
%
%   Example:
%       xyz = uvl2xyz([0.2092    0.3254    1.0000])
%       xyz =
%           0.9644    1.0000    0.8248

%   Copyright 1993-2015 The MathWorks, Inc.
%   
%   Author:  Scott Gregory, 10/18/02
%   Revised: Toshia McCabe, 12/06/02


validateattributes(uvl,{'double'},{'real','2d','nonsparse','finite'},...
              'uvl2xyz','UVL',1);
if size(uvl,2) ~= 3
    error(message('images:uvl2xyz:invalidUvlData'))
end

xyz = zeros(size(uvl));
xyz(:,1) =  clipdivide(uvl(:,3) * 3 .* uvl(:,1), 2 * uvl(:,2));
xyz(:,2) = uvl(:,3);
xyz(:,3) = clipdivide(4 - 10 * uvl(:,2) - uvl(:,1),  ...
                      2 * uvl(:,2)) .*  uvl(:,3);
