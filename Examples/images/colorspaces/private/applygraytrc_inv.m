function out = applygraytrc_inv(in, GrayTRC, ConnectionSpace)
%APPLYGRAYTRC_INV converts from ICC PCS to monochrome device space.
%   OUT = APPLYGRAYTRC_INV(IN, GRAYTRC, CONNECTIONSPACE) converts 
%   data from an ICC Profile Connection Space to a single-channel 
%   device space ('gray'), using a Tone Reproduction Curve (TRC).  
%   The TRC is applied in the inverse direction to remap the neutral
%   component of the PCS (Y for XYZ and L* for L*a*b*) to produce
%   the device value. GRAYTRC is a substructure of a MATLAB 
%   representation of an ICC profile (see ICCREAD). CONNECTIONSPACE
%   can be either 'Lab' or 'XYZ'.  IN is an n x 3 vector, and 
%   OUT is an n x 1 vector, of class 'double'.

%   Copyright 2005-2015 The MathWorks, Inc.
%      Poe
%   Original author:  Robert Poe 08/18/05

validateattributes(in, {'double'}, {'real', '2d', 'nonsparse', 'finite'}, ...
              'applygraytrc_inv', 'IN', 1);
if size(in, 2) ~= 3
    error(message('images:applygraytrc_inv:inColumns'))
end

% Check the GrayTRC
validateattributes(GrayTRC, {'uint16', 'struct'}, {'nonempty'}, ...
              'applygraytrc_inv', 'GRAYTRC', 2);
if size(GrayTRC, 2) ~= 1
    error(message('images:applygraytrc_inv:grayTrcColumns'))
end
validateattributes(ConnectionSpace, {'char'}, {'nonempty'}, ...
              'applygraytrc_inv', 'CONNECTIONSPACE', 3);

% Select achromatic component of PCS and scale to [0, 1]
if strcmp(ConnectionSpace, 'XYZ')
    gray = in(:, 2);          % Y (luminance)
else % 'Lab'
    gray = 0.01 * in(:, 1);   % L* / 100
end

% Remap through TRC
out = applycurve(gray, GrayTRC, 1, 'spline');

