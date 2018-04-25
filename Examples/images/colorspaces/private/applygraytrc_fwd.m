function out = applygraytrc_fwd(in, GrayTRC, ConnectionSpace)
%APPLYGRAYTRC_FWD converts from monochrome device space to ICC PCS.
%   OUT = APPLYGRAYTRC_FWD(IN, GRAYTRC, CONNECTIONSPACE) converts 
%   data from a single-channel device space ('gray') to an ICC 
%   Profile Connection Space, using a Tone Reproduction Curve (TRC).  
%   The outputs from the TRC mapping are used to multiply the PCS 
%   coordinates of the D50 white point.  GRAYTRC is a substructure 
%   of a MATLAB representation of an ICC profile (see ICCREAD). 
%   CONNECTIONSPACE can be either 'Lab' or 'XYZ'.  IN is an n x 1 
%   vector, and OUT is an n x 3 vector, of class 'double'.  

%   Copyright 2005-2015 The MathWorks, Inc.
%      Poe
%   Original author:  Robert Poe 08/16/05


validateattributes(in, {'double'}, {'real', '2d', 'nonsparse', 'finite'}, ...
              'applygraytrc_fwd', 'IN', 1);
if size(in, 2) ~= 1
    error(message('images:applygraytrc_fwd:inColumns'))
end

% Check the GrayTRC
validateattributes(GrayTRC, {'uint16', 'struct'}, {'nonempty'}, ...
              'applygraytrc_fwd', 'GRAYTRC', 2);
if size(GrayTRC, 2) ~= 1
    error(message('images:applygraytrc_fwd:grayTrcColumns'))
end
validateattributes(ConnectionSpace, {'char'}, {'nonempty'}, ...
              'applygraytrc_fwd', 'CONNECTIONSPACE', 3);

% Remap input data through TRC
gray = applycurve(in, GrayTRC, 0, 'spline');

% Construct output PCS array (3 columns):
if strcmp(ConnectionSpace, 'XYZ')
    white = whitepoint;       % XYZ of D50
else  % 'Lab'
    white = [100.0 0.0 0.0];  % L*a*b* of D50
end
out = gray * white;
