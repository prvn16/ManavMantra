function [F,obeta,otheta] = fanbeam(varargin)
%FANBEAM Fan-beam transform.
%   F = FANBEAM(I,D) computes the fan-beam data (sinogram) F from the image
%   I. D is the distance in pixels from the fan-beam vertex to the center of
%   rotation. The center of rotation is the center pixel of the image,
%   defined as FLOOR((SIZE(I)+1)/2). D must be large enough to ensure that
%   the fan-beam vertex is outside of the image at all rotation angles. See
%   Remarks for guidelines on specifying D.
%
%   Each column of F contains the fan-beam sensor samples at one rotation
%   angle. The number of columns in F is determined by the fan rotation
%   increment such that the rotation angles span 360 degrees.
%
%   The number of rows in F is determined by the number of sensors. FANBEAM
%   determines the number of sensors by calculating how many beams are
%   required to cover the entire image for any rotation angle.
%
%   For information about how to specify the rotation increment and sensor
%   spacing, see the documentation for the FanRotationIncrement and
%   FanSensorSpacing parameters, below.
%
%   F = FANBEAM(...,PARAM1,VAL1,PARAM2,VAL2,...) specifies parameters that
%   control various aspects of the fan-beam projections. Parameter names can
%   be abbreviated, and case does not matter. 
%
%   Parameters include:
%
%   'FanRotationIncrement'  Positive real scalar specifying the increment 
%                           of the rotation angle of the fan-beam
%                           projections. Measured in degrees.
%
%                           Default value: 1
%
%   'FanSensorGeometry'     String or char vector specifying how sensors
%                           are positioned.
%                           'arc'  -   Sensors are spaced equally along
%                                      a circular arc.
%                           'line' -   Sensors are spaced equally along
%                                      a line.
% 
%                           Default value: 'arc'
%                           
%   'FanSensorSpacing'      Positive real scalar specifying the spacing
%                           of the fan-beam sensors. Interpretation of 
%                           the value depends on the setting of
%                           'FanSensorGeometry'.
%                             
%                           If 'FanSensorGeometry' is set to 'arc' (the
%                           default), the value defines the angular spacing
%                           in degrees.
%
%                           If 'FanSensorGeometry' is set to 'line', the
%                           value specifies the linear spacing.
%
%                           NOTE: This linear spacing is measured on the
%                           x-prime axis. The x-prime axis for each
%                           column, COL, of F is oriented at
%                           FAN_ROTATION_ANGLES(COL) degrees
%                           counterclockwise from the x-axis. The origin
%                           of both axes is the center pixel of the image.
%
%                           Default value: 1 (for both 'arc' and 'line')
% 
%   [F,FAN_SENSOR_POSITIONS,FAN_ROTATION_ANGLES] = FANBEAM(...) returns
%   the location of fan-beam sensors in FAN_SENSOR_POSITIONS and the
%   rotation angles where the fan-beam projections are calculated in
%   FAN_ROTATION_ANGLES.
%
%   If 'FanSensorGeometry' is 'arc' (the default), FAN_SENSOR_POSITIONS
%   contains the fan-beam spread angles. If 'FanSensorGeometry' is 'line',
%   FAN_SENSOR_POSITIONS contains the fan-beam sensor positions along the
%   x-prime axis. See 'FanSensorSpacing' for more information.
%
%   Class Support
%   -------------  
%   I can be logical or numeric.  All other numeric inputs and outputs can
%   be double. None of the inputs can be sparse.
%
%   Remarks
%   -------
%   As a guideline, try making D a few pixels larger than half the diagonal
%   image distance, where the diagonal image distance is sqrt(size(I,1)^2 +
%   size(I,2)^2).
%  
%   The values returned in F are a numerical approximation of the fan-beam
%   projections. The algorithm depends on the Radon transform, interpolated
%   to the fan-beam geometry. The results vary depending on the parameters
%   used. You can expect more accurate results when the image is larger, D
%   is larger, and for points closer to the middle of the image, away from
%   the edges.
%  
%   Example 1
%   ---------
%       iptsetpref('ImshowAxesVisible','on')
%       ph = phantom(128);
%       imshow(ph)
%       [F,Fpos,Fangles] = fanbeam(ph,250);
%       figure
%       imshow(F,[],'XData',Fangles,'YData',Fpos,'InitialMagnification','fit')
%       axis normal
%       xlabel('Rotation Angles (degrees)')
%       ylabel('Sensor Positions (degrees)')
%       colormap(gca,hot), colorbar
%
%   Example 2
%   ---------
%       % Compute Radon and fan-beam projections and compare the results.
%
%       I = ones(100);
%       D = 200;
%       dtheta = 45;
%       
%       % Compute fan-beam projections for 'arc' geometry
%       [Farc,FposArcDeg,Fangles] = fanbeam(I,D,...
%                                        'FanSensorGeometry','arc',...
%                                        'FanRotationIncrement',dtheta);
%       % Convert angular positions to linear distance along x-prime axis
%       FposArc = D*tan(FposArcDeg*pi/180);
%       
%       % Compute fan-beam projections for 'line' geometry
%       [Fline,FposLine] = fanbeam(I,D,...
%                                  'FanSensorGeometry','line',...
%                                  'FanRotationIncrement',dtheta);
%
%       % Compute the corresponding Radon transform
%       [R,Rpos] = radon(I,Fangles);
%       
%       % Display the three projections at one particular rotation angle.
%       % Note the three are very similar. Differences are due to the
%       % geometry of the sampling, and the numerical approximations used
%       % in the calculations. 
%       figure
%       idx = find(Fangles==45);
%       plot(Rpos,R(:,idx),...
%            FposArc,Farc(:,idx),...
%            FposLine,Fline(:,idx))
%       legend('Radon','Arc','Line')
%
%   See also FAN2PARA, IFANBEAM, IRADON, PARA2FAN, PHANTOM, RADON.

%   Copyright 1993-2016 The MathWorks, Inc.

narginchk(2,8);

I = varargin{1};
d = varargin{2};

validateattributes(I, {'numeric','logical'}, ...
              {'real', '2d', 'nonsparse'}, ...
              mfilename, 'I', 1);

validateattributes(d, {'double'},...
              {'real', '2d', 'nonsparse', 'positive'}, ...
              mfilename, 'D', 2);

% Default values
args.FanSensorGeometry     = 'arc';
args.FanSensorSpacing      = 1;
args.FanRotationIncrement  = 1;

valid_params = {'FanSensorGeometry',...
                'FanSensorSpacing',...
                'FanRotationIncrement'};

num_pre_param_args = 2;
args = check_fan_params(varargin(3:nargin),args,valid_params,...
                        mfilename,num_pre_param_args);

P = radon(I,0:0.5:179.5);

[F,obeta,otheta] = para2fan(P,d,...
                            'FanSensorSpacing',args.FanSensorSpacing,... 
                            'FanRotationIncrement',args.FanRotationIncrement,...
                            'FanSensorGeometry',args.FanSensorGeometry,...
                            'Interpolation','pchip'); 
