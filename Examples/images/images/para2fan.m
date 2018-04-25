function [F,ogamma,otheta] = para2fan(varargin)
%PARA2FAN Convert parallel-beam projections to fan-beam.
%   F = PARA2FAN(P,D) converts the parallel-beam data P to the fan-beam data
%   F. D is the distance in pixels from the fan-beam vertex to the center of
%   rotation that was used to obtain the projections. 
%
%   F = PARA2FAN(...,PARAM1,VAL1,PARAM2,VAL2,...) specifies parameters that
%   control various aspects of the PARA2FAN conversion. Parameter names can
%   be abbreviated, and case does not matter.
%
%   Parameters include:
%
%   'FanCoverage'            String specifying the range of rotation 
%                            angles used to calculate the projection 
%                            data F.
%                            'cycle'   - [0,360)
%                            'minimal' - Input rotation angle range is 
%                                        the minimum necessary to fully
%                                        represent the object.
%
%                            Default value: 'cycle'
%
%   'FanRotationIncrement'   Positive real scalar specifying the 
%                            increment of the rotation angle of the
%                            fan-beam projections. Measured in degrees.
%
%                            If 'FanCoverage' is set to 'cycle' the value of
%                            'FanRotationIncrement' must be a factor of 360.
%
%                            If 'FanRotationIncrement' is not specified,
%                            then it is set to the same increment as the
%                            parallel-beam rotation angles.
%
%   'FanSensorGeometry'      String or character vector specifying how 
%                            sensors are positioned.
%                            'arc'  -   Sensors are spaced equally along
%                                       a circular arc.
%                            'line' -   Sensors are spaced equally along
%                                       a line.
%                            
%                            Default value: 'arc'
%
%   'FanSensorSpacing'       Positive real scalar specifying the spacing
%                            of the fan-beam sensors. Interpretation of 
%                            the value depends on the setting of
%                            'FanSensorGeometry'.
%
%                            If 'FanSensorGeometry' is set to 'arc' (the
%                            default), the value defines the angular
%                            spacing in degrees.
%                            
%                            If 'FanSensorGeometry' is set to 'line', the
%                            value specifies the linear spacing.
%                            
%                            NOTE: This linear spacing is measured on
%                            the x-prime axis. The x-prime axis for each
%                            column, COL, of F is oriented at
%                            FAN_ROTATION_ANGLES(COL) degrees
%                            counterclockwise from the x-axis. The
%                            origin of both axes is the center pixel of
%                            the image.
%                           
%                            If 'FanSensorSpacing' is not specified, the
%                            default is the smallest value implied by
%                            'ParallelSensorSpacing' such that:
%                            
%                               If 'FanSensorGeometry' is 'arc' then
%                               'FanSensorSpacing' is
%                               
%                                  ASIN(PSPACE/D)*180/pi 
%                               
%                               where PSPACE is the value of the
%                               'ParallelSensorSpacing'.
%                               
%                               If 'FanSensorGeometry' is 'line' then
%                               'FanSensorSpacing' is 
%                               
%                                  D*ASIN(PSPACE/D).
%
%   'Interpolation'          String or character vector specifying the 
%                            type of interpolation used between the 
%                            parallel-beam and fan-beam data.
%
%                            'nearest'   - nearest neighbor
%                            'linear'    - linear
%                            'spline'    - piecewise cubic spline
%                            'pchip'     - piecewise cubic Hermite (PCHIP)
%
%                            Default value: 'linear'
%
%   'ParallelCoverage'       String or character vector specifying the 
%                            range of rotation angles of the parallel-beam 
%                            projection data.
%
%                            'cycle'      - Parallel data covers 360 degrees
%                            'halfcycle'  - Parallel data covers 180 degrees
%
%                            Default value: 'halfcycle'
%
%   'ParallelSensorSpacing'  Positive real scalar specifying the spacing
%                            of the parallel-beam sensors in pixels.
%
%                            Default value: 1
%
%   [F,FAN_SENSOR_POSITIONS,FAN_ROTATION_ANGLES] = PARA2FAN(...)  If
%   'FanSensorGeometry' is 'arc', FAN_SENSOR_POSITIONS contains the fan-beam
%   sensor measurement angles. If 'FanSensorGeometry' is 'line',
%   FAN_SENSOR_POSITIONS contains the fan-beam sensor positions along the line
%   of sensors. FAN_ROTATION_ANGLES contains rotation angles.
%
%   Class Support
%   -------------    
%   P and D can be double or single, and must be nonsparse. The other numeric
%   input arguments must be double.  The output arguments are double.
%
%   Remarks
%   -------
%   D must be greater than or equal to PSPACE*(size(P,1)-1)/2 where PSPACE is
%   the value of the 'ParallelSensorSpacing'.
%
%   Example
%   -------
%       % Generate parallel-beam projections
%       ph = phantom(128);
%       theta = 0:180;
%       [P,xp] = radon(ph,theta);
%       imshow(P,[],'XData',theta,'YData',xp,'InitialMagnification','fit')
%       axis normal
%       title('Parallel-Beam Projections')
%       xlabel('\theta (degrees)')
%       ylabel('x''')
%       colormap(gca,hot), colorbar
%
%       % Convert to fan-beam projections
%       [F,Fpos,Fangles] = para2fan(P,100);  
%       figure
%       imshow(F,[],'XData',Fangles,'YData',Fpos,'InitialMagnification','fit')
%       axis normal
%       title('Fan-Beam Projections')
%       xlabel('\theta (degrees)')
%       ylabel('Sensor Locations (degrees)')
%       colormap(gca,hot), colorbar
%
%   See also FAN2PARA, FANBEAM, IRADON, IFANBEAM, PHANTOM, RADON.

%   Copyright 1993-2017 The MathWorks, Inc.

argin = matlab.images.internal.stringToChar(varargin);
args = parseInputs(argin{:});

P          = args.P;
d          = args.d;
dthetaDeg  = args.FanRotationIncrement;
interp     = args.Interpolation;

utils = fanUtils;
[P,m] = utils.padToOddDim(P);

dploc = args.ParallelSensorSpacing;
ploc = formPlocVector(m,dploc);

fanSpacing = args.FanSensorSpacing;
[gammaRad,floc] = formGammaVector(ploc,d,fanSpacing,args.FanSensorGeometry);
gammaDeg = gammaRad*180/pi;

isParallelCoverageCycle = strcmp(args.ParallelCoverage,'cycle');

n = size(P,2);
[pthetaDeg,dpthetaDeg] = formPthetaVector(n,isParallelCoverageCycle);

if isempty(dthetaDeg)
    dthetaDeg = dpthetaDeg; % The default FanRotationIncrement equals the
                            % ParallelRotation Increment
end

gammaMax = max(gammaDeg);
gammaMin = min(gammaDeg);

if strcmp(args.FanCoverage,'minimal')
    thetaDeg = utils.formMinimalThetaVector(n,dthetaDeg,gammaMin,gammaMax);
else
    thetaDeg = formCycleThetaVector(dthetaDeg);
end

numelGamma = numel(gammaDeg);

% interpolate to get desired t sample locations
%    t = d*sin(gammaRad) = distance of projection sample (beam) to iso-center
%    See: Kak and Slaney, Fig. 3.19 on page 80, eqn 127 on page 92.
%    Also see: Hsieh, Fig 3.40 on page 77, eqn 3.47 on page 79.
% interpolate in ploc domain, since this represents actual spacing
Pint = zeros(numelGamma,n);
t = d*sin(gammaRad); % t approximates fan beam as parallel beam.
for i = 1:numel(pthetaDeg)
    Pint(:,i) = interp1(ploc,P(:,i)',t,interp)';      
end

% build padded Pint
if isParallelCoverageCycle
    Ppad = Pint;
    pthetapad = pthetaDeg;
else
    [Ppad, pthetapad] = utils.repPforCycleCoverage(Pint,pthetaDeg);
end
gammaRange = gammaMax - gammaMin;
ptmask = (pthetapad >= 360 - gammaRange);
ptmask2 = (pthetapad <= gammaRange);
Ppad = [Ppad(:,ptmask) Ppad Ppad(:,ptmask2)];
pthetapad = [pthetapad(ptmask)-360 pthetapad pthetapad(ptmask2)+360];

F = shiftAndInterpRotationAngles(gammaDeg,thetaDeg,pthetapad,Ppad,interp);

if isParallelCoverageCycle
    Ppad2 = flipud(Ppad);
    pthetapad2 = pthetapad - 180;
    theta2 = mod(thetaDeg+180,360) - 180;

    F2 = shiftAndInterpRotationAngles(gammaDeg,theta2,pthetapad2,Ppad2,interp);

    % Average results
    F = (F+F2)/2;
end

otheta = thetaDeg;
if strcmp(args.FanSensorGeometry,'line')
    ogamma = floc;
else
    ogamma = gammaDeg;
end
ogamma = ogamma';

F = utils.setNaNsToZero(F);

%---------------------------------------------------------------------------
function F = shiftAndInterpRotationAngles(gamma,theta,pthetapad,Ppad,interp)
% shift to correct for fan-beam angle offsets and interpolate

numelGamma = numel(gamma);
F = zeros(numelGamma,numel(theta));
for i=1:numelGamma
    F(i,:) = interp1(pthetapad+gamma(i),Ppad(i,:),theta,interp);
end

%--------------------------------------
function ploc = formPlocVector(m,dploc)

m2cn = floor((m-1)/2);
m2cp = floor(m/2);
ploc = dploc *(-m2cn:m2cp);

%----------------------------------------------------------------------------------
function [gammaRad,floc] = formGammaVector(ploc,d,fanSpacing,fanSensorGeometry)

utils = fanUtils;
floc = [];

plocMax = max(ploc);
plocMin = min(ploc);
if strcmp(fanSensorGeometry,'line')
    floc = utils.formVectorCenteredOnZero(fanSpacing,plocMin,plocMax);
    % floc represents linear spacing along the line perpendicular to central beam
    % so the set of angles gammaRad must be calculated using ATAN.    
    gammaRad = atan(floc/d); 
else  
    % See: Kak and Slaney, page 80:
    % "ASIN(tm/D) is equal to the value of gamma for the extreme ray SE in Fig. 3.19."    
    gammaRad = utils.formVectorCenteredOnZero(fanSpacing*pi/180,...
                                              asin(plocMin/d),...
                                              asin(plocMax/d));
end

%-------------------------------------------------------------------------
function [ptheta,dpthetaDeg] = formPthetaVector(n,isParallelCoverageCycle)

if isParallelCoverageCycle
    dpthetaDeg = 360/n;
else 
    dpthetaDeg = 180/n;
end
ptheta = dpthetaDeg * (0:n-1);    

%---------------------------------------------------------
function theta = formCycleThetaVector(dthetaDeg)
    
if mod(360,dthetaDeg) ~= 0    
    error(message('images:para2fan:dthetaNotFactorOf360'));
end
theta = 0:dthetaDeg:(360-dthetaDeg);

%-------------------------------------
function args = parseInputs(varargin)

narginchk(2,16);

P = varargin{1};
d = varargin{2};

validateattributes(P, {'double','single'}, ...
              {'real', '2d', 'nonsparse'}, ...
              mfilename, 'P', 1);

validateattributes(d, {'double','single'},...
              {'real', '2d', 'nonsparse', 'positive'}, ...
              mfilename, 'D', 2);

% Default values
args.ParallelSensorSpacing = [];
args.FanSensorSpacing      = [];
args.FanRotationIncrement  = [];
args.ParallelCoverage      = 'halfcycle';
args.FanSensorGeometry     = 'arc';
args.FanCoverage           = 'cycle';
args.Interpolation         = 'linear';

valid_params = {'ParallelSensorSpacing',...
                'FanSensorSpacing',...
                'FanRotationIncrement',...
                'ParallelCoverage',...
                'FanSensorGeometry',...
                'FanCoverage',...
                'Interpolation'};

num_pre_param_args = 2;
args = check_fan_params(varargin(3:nargin),args,valid_params,...
                        mfilename,num_pre_param_args);

if isempty(args.ParallelSensorSpacing)
    args.ParallelSensorSpacing = 1;
end

% compute maxPloc and make sure D is large enough
m = size(P,1);
maxPloc = args.ParallelSensorSpacing*(m-1)/2;
if d < maxPloc 
    error(message('images:para2fan:dTooSmall', ceil( maxPloc )))
end

if isempty(args.FanSensorSpacing)
    % FanSensorSpacing is smallest implied by ParallelSensorSpacing
    if strcmp(args.FanSensorGeometry,'line')
        args.FanSensorSpacing = d*sin(args.ParallelSensorSpacing/d);                
    else
        args.FanSensorSpacing = asin(args.ParallelSensorSpacing/d)*180/pi;
    end
end

args.P = P;
args.d = d;
