function out = applymattrc_inv(in, MatTRC)
%APPLYMATTRC_INV converts from device space to ICC profile connection space
%   OUT = APPLYMATTRC_INV(IN, MATTRC) converts from ICC profile space
%   to device space, i.e., B to A, using the Matrix-based model.  The only 
%   Profile Connection Space supported by this model type is 16-bit XYZ.
%   MATTRC is a substructure of a MATLAB representation of an ICC
%   profile (see ICCREAD). Both IN and OUT are n x 3 vectors.  OUT is
%   a uint16 encoding of RGB.  IN is a uint16 encoding of ICC CIEXYZ.

%   Copyright 2002-2015 The MathWorks, Inc.
%   Original author:  Scott Gregory 10/20/02

validateattributes(in,{'double'},{'real','2d','nonsparse','finite'},...
              'applymattrc_inv','IN',1);
if size(in,2) ~= 3
    error(message('images:applymattrc_inv:invalidInputData'))
end

% Check the MatTRC
validateattributes(MatTRC,{'struct'},{'nonempty'},'applymattrc_inv','MATTRC',2);

% construct matrix and evaluate
mat = [MatTRC.RedColorant;
       MatTRC.GreenColorant;
       MatTRC.BlueColorant];
rgb = in / mat;  % equivalent to "in * inv(mat)"

% apply RGB non-linearity
TRC = cell(1, 3);
TRC{1} = MatTRC.RedTRC;
TRC{2} = MatTRC.GreenTRC;
TRC{3} = MatTRC.BlueTRC;
for i = 1 : 3
    out(:, i) = applycurve(rgb(:, i), TRC{i}, 1, 'spline'); %#ok<AGROW>
end
