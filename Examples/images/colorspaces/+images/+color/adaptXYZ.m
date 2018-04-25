function xyz_out = adaptXYZ(xyz_in, WPs, WPd)
% adaptXYZ Chromatic adaption of XYZ color values
%
%    xyz_out = images.color.adaptXYZ(xyz_in,WPs,WPd)
%
%    Chromatically adapts XYZ color values based on a source white point and a destination white
%    point. xyz_in and xyz_out are P-by-3 matrices. WPs and WPd are 1-by-3 vectors.
%
%    Reference: Chromatic Adaptation, Bruce Lindbloom,
%    www.brucelindbloom.com/index.html?Eqn_ChromAdapt.html

%    Copyright 2014 The MathWorks, Inc.

% Bradford cone response model matrix
Ma = [ ...
    0.8951   0.2664  -0.1614
    -0.7502  1.7135   0.0367
    0.0389  -0.0685   1.0296 ];

% Source white point cone response
CRs = Ma * WPs';

% Destination white point cone response
CRd = Ma * WPd';

% Cone response domain scaling matrix
S = diag(CRd ./ CRs);

% Linear adaptation transform matrix
M = Ma\(S * Ma);

xyz_out = xyz_in * M';
