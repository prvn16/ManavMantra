function [P,oploc,optheta] = fan2para(varargin)
%FAN2PARA Convert fan-beam projections to parallel-beam.
%   P = FAN2PARA(F,D) converts the fan-beam data F to the parallel-beam data
%   P. D is the distance in pixels from the fan-beam vertex to the center of
%   rotation that was used to obtain the projections.
%
%   P = FAN2PARA(...,PARAM1,VAL1,PARAM2,VAL2,...) specifies parameters that
%   control various aspects of the FAN2PARA conversion. Parameter names can
%   be abbreviated, and case does not matter.
%
%   Parameters include:
%
%   'FanCoverage'                String or char vector specifying the range of rotation 
%                                angles used to calculate the projection 
%                                data F.
%                                'cycle'   - [0,360)
%                                'minimal' - Input rotation angle range is 
%                                            the minimum necessary to fully
%                                            represent the object.
%
%                                Default value: 'cycle'
%
%   'FanRotationIncrement'       Positive real scalar specifying the 
%                                increment of the rotation angle of the 
%                                fan-beam projections. Measured in degrees.
%
%                                Default value: 1
%
%   'FanSensorGeometry'          String or char vector specifying how sensors are positioned.
%                                'arc'  -   Sensors are spaced equally along
%                                           a circular arc.
%                                'line' -   Sensors are spaced equally along
%                                           a line.
%                                
%                                Default value: 'arc'
%                                
%   'FanSensorSpacing'           Positive real scalar specifying the spacing
%                                of the fan-beam sensors. Interpretation of 
%                                the value depends on the setting of
%                                'FanSensorGeometry'.
%                                  
%                                If 'FanSensorGeometry' is set to 'arc' (the
%                                default), the value defines the angular
%                                spacing in degrees.
%                                
%                                If 'FanSensorGeometry' is set to 'line', the
%                                value specifies the linear spacing.
%                                
%                                NOTE: This linear spacing is measured on
%                                the x-prime axis. The x-prime axis for each
%                                column, COL, of F is oriented at
%                                FAN_ROTATION_ANGLES(COL) degrees
%                                counterclockwise from the x-axis. The
%                                origin of both axes is the center pixel of
%                                the image.
%                                
%                                Default value: 1 (for both 'arc' and 'line')
%                               
%   'Interpolation'              String or char vector specifying the type 
%                                of interpolation used between the fan-beam
%                                and parallel-beam data.
%                                
%                                'nearest'   - nearest neighbor
%                                'linear'    - linear
%                                'spline'    - piecewise cubic spline
%                                'pchip'     - piecewise cubic Hermite (PCHIP)
%                                
%                                Default value: 'linear'
%                               
%   'ParallelCoverage'           String or char vector specifying the range
%                                of rotation angles of the parallel-beam 
%                                projection data.
%                                
%                                'cycle'      - Parallel data covers 360 degrees
%                                'halfcycle'  - Parallel data covers 180 degrees
%                                
%                                Default value: 'halfcycle'
%
%   'ParallelRotationIncrement'  Positive real scalar specifying the
%                                parallel beam rotation angle increment,
%                                measured in degrees. Parallel beam angles
%                                are calculated to cover [0,180) degrees
%                                with increment PAR_ROT_INC, where
%                                PAR_ROT_INC is the value of
%                                'ParallelRotationIncrement'.
%
%                                180/PAR_ROT_INC must be an integer.
%
%                                If 'ParallelRotationIncrement' is not
%                                specified, the increment is assumed to be
%                                the same as the increment of the fan-beam
%                                rotation angles.
%
%   'ParallelSensorSpacing'      Positive real scalar specifying the
%                                spacing of the parallel-beam sensors in
%                                pixels. The range of sensor locations is
%                                implied by the range of fan angles and is
%                                given by
%                               
%                                [D*SIN(MIN(FAN_ANGLES)),D*SIN(MAX(FAN_ANGLES))]
%                               
%                                If 'ParallelSensorSpacing' is not specified,
%                                the spacing is assumed to be uniform and
%                                is set to the minimum spacing implied by the
%                                fan angles and sampled over the range implied
%                                by the fan angles.
%                               
%   [P,PARALLEL_SENSOR_POSITIONS,PARALLEL_ROTATION_ANGLES] = FAN2PARA(...)
%   returns the parallel-beam sensor locations in PARALLEL_SENSOR_POSITIONS and
%   rotation angles in PARALLEL_ROTATION_ANGLES.
%
%   Class Support
%   -------------
%   F and D can be double or single, and they must be nonsparse. All
%   other numeric inputs are double. The output P is double.
%
%   Example
%   -------
%       % Create synthetic parallel-beam data, derive fan-beam data and 
%       % then use the fan-beam data to recover the parallel-beam data.
%       ph = phantom(128);
%       theta = 0:179;
%       [Psynthetic,xp] = radon(ph,theta);
%       imshow(Psynthetic,[],...
%              'XData',theta,'YData',xp,'InitialMagnification','fit') 
%       axis normal
%       title('Synthetic Parallel-Beam Data')
%       xlabel('\theta (degrees)')
%       ylabel('x''')
%       colormap(gca,hot), colorbar
%       Fsynthetic = para2fan(Psynthetic,100,'FanSensorSpacing',1);
%
%       % Recover original parallel-beam data
%       [Precovered,Ploc,Pangles] = fan2para(Fsynthetic,100,...
%                                            'FanSensorSpacing',1,...
%                                            'ParallelSensorSpacing',1);
%       figure
%       imshow(Precovered,[],...
%              'XData',Pangles,'YData',Ploc,'InitialMagnification','fit') 
%       axis normal
%       title('Recovered Parallel-Beam Data')
%       xlabel('Rotation Angles (degrees)')
%       ylabel('Parallel Sensor Locations (pixels)')
%       colormap(gca,hot), colorbar
%
%   See also FANBEAM, IFANBEAM, IRADON, PARA2FAN, PHANTOM, RADON.

%   Copyright 1993-2017 The MathWorks, Inc.
varargin = matlab.images.internal.stringToChar(varargin);
args = parseInputs(varargin{:});

F = args.F;
d = args.d;

fanSensorGeometry = args.FanSensorGeometry;

utils = fanUtils;
[F,m] = utils.padToOddDim(F);

checkFanSensorSpacing(fanSensorGeometry, args.FanSensorSpacing, m, d)

if isempty(args.ParallelSensorSpacing)
    args.ParallelSensorSpacing = getDefaultParallelSensorSpacing(...
        fanSensorGeometry,...
        args.FanSensorSpacing, m, d);
end

fanSpacing = args.FanSensorSpacing;
gammaDeg  = formGammaVector(m,d,fanSpacing,fanSensorGeometry);

n = size(F,2);
if strcmp(args.FanCoverage,'minimal')
    isFanCoverageCycle = false;
    
    dthetaDeg = args.FanRotationIncrement;
    thetaDeg = formMinimalThetaVector(m,n,dthetaDeg,gammaDeg);
    F = F(2:end-1,:);
    gammaDeg = gammaDeg(2:end-1);

else
    isFanCoverageCycle = true;
    thetaDeg =(0:n-1)*360/n;

end
    
ploc = formPlocVector(d,gammaDeg,args.ParallelSensorSpacing);

dpthetaDeg = args.ParallelRotationIncrement;
pthetaDeg = formPthetaVector(dpthetaDeg);

if ~isFanCoverageCycle
    checkAngles(pthetaDeg,thetaDeg,gammaDeg)
end

P = fan2paraInterp(F,d,...
                   gammaDeg,thetaDeg,ploc,pthetaDeg,...
                   args.Interpolation,...
                   isFanCoverageCycle);

oploc = ploc';
optheta = pthetaDeg;

if strcmp(args.ParallelCoverage,'cycle')
    [P, optheta] = utils.repPforCycleCoverage(P,optheta);
end

%------------------------------------------------------------------------------------
function P = fan2paraInterp(F,d,gammaDeg,thetaDeg,ploc,pthetaDeg,interp,isFanCoverageCycle)

[m,n] = size(F);

if isFanCoverageCycle
    % use full 360-deg fan-beam set to get 180-deg p-beam
    
    n4 = ceil(n/4);

    % first reconstruction
    Fpad = [ F(:,end-n4+1:end) F ];   % exploit periodicity of sinogram
    thetapad = [ thetaDeg(end-n4+1:end)-360 thetaDeg ];    
    P = fan2paraInterp(Fpad,d,gammaDeg,thetapad,...
                       ploc,pthetaDeg,interp,false);

else
    
    numelPtheta = numel(pthetaDeg);
    
    % shift to correct for fan-beam angles and interp to desired p-beam angles
    Fsh = zeros(m,numelPtheta);
    for i=1:m
        Fsh(i,:) = interp1(thetaDeg-gammaDeg(i),F(i,:),pthetaDeg,interp);        
    end

    % interpolate to get desired p-beam sample locations
    %    t = d*sin(gammaRad) = distance of projection sample (beam) to iso-center
    %    See: Kak and Slaney, Fig. 3.19 on page 80, eqn 127 on page 92.
    %    Also see: Hsieh, Fig 3.40 on page 77, eqn 3.47 on page 79.
    numelPloc = numel(ploc);
    P = zeros(numelPloc,numelPtheta);
    t = d*sin(gammaDeg*pi/180); % t approximates fan beam as parallel beam.
    for i=1:numelPtheta
        P(:,i) = interp1(t,Fsh(:,i)',ploc,interp)';
    end

end

utils = fanUtils;
P = utils.setNaNsToZero(P);

%------------------------------------------------
function checkAngles(pthetaDeg,thetaDeg,gammaDeg)

isMaxPthetaTooBig = max(pthetaDeg) > max(thetaDeg) + min(gammaDeg); 
isMinPthetaTooSmall = min(pthetaDeg) < min(thetaDeg) + max(gammaDeg);

if isMaxPthetaTooBig || isMinPthetaTooSmall
    error(message('images:fan2para:cannotComputePtheta'))
end

isAnyThetaTooSmall = any(thetaDeg < floor(min(gammaDeg)));     
isAnyThetaTooBig   = any(thetaDeg >= 360);

if isAnyThetaTooSmall || isAnyThetaTooBig     
    error(message('images:fan2para:illegalTheta'))
end

%-------------------------------------------------------------------
function gammaDeg = formGammaVector(m,d,fanSpacing,fanSensorGeometry)

m2cn = floor((m-1)/2);
m2cp = floor(m/2);
g = (-m2cn:m2cp)*fanSpacing;
if strcmp(fanSensorGeometry,'line')
    % g represents linear spacing along the line perpendicular to central beam
    % so the set of angles gammaDeg must be calculated using ATAN.
    gammaDeg = atan(g/d)*180/pi;
else % strcmp(fanSensorGeometry,'arc')
    gammaDeg = g;
end

%----------------------------------------------------------
function theta = formMinimalThetaVector(m,n,dthetaDeg,gammaDeg)
% Calculate theta for 'FanCoverage','minimal'

if mod(m,2) == 0
    ibegin = 3;
else
    ibegin = 2;
end

gammaMin = min(gammaDeg(ibegin:end));
gammaMax = max(gammaDeg(1:end-1));

utils = fanUtils; % load utility functions
theta = utils.formMinimalThetaVector(n,dthetaDeg,gammaMin,gammaMax);

if length(theta) ~= n
    error(message('images:fan2para:badThetaLength'))
end

%--------------------------------------------
function ploc = formPlocVector(d,gamma,dploc)

% divide total range by dploc
gammaRangeRad = [min(gamma) max(gamma)]*pi/180;

% See: Kak and Slaney, page 80:
% "ASIN(tm/D) is equal to the value of gamma for the extreme ray SE in Fig. 3.19."
% Here we need tm (ploc) in terms of gamma: tm = D*SIN(gamma)
plocRange = d*sin(gammaRangeRad);

plocMin = plocRange(1);
plocMax = plocRange(2);
utils = fanUtils; % load utility functions
ploc = utils.formVectorCenteredOnZero(dploc,plocMin,plocMax);

%------------------------------------------
function ptheta = formPthetaVector(dptheta)

ptheta = 0:dptheta:(180-dptheta);    

%------------------------------------------------------------------------
function checkFanSensorSpacing(fanSensorGeometry, fanSensorSpacing, m, d)

if strcmp(fanSensorGeometry,'line')
    maxFloc = fanSensorSpacing*(m-1)/2;
    
else % fanSensorGeometry=='arc'
    max_fan_angle = fanSensorSpacing*(m-1)/2;   

    if max_fan_angle>90
        error(message('images:fan2para:maxAngleTooBig'))
    end 

   % See: Kak and Slaney, page 80:
   % "ASIN(tm/D) is equal to the value of gamma for the extreme ray SE in Fig. 3.19."
   % Here we need tm (Floc) in terms of gamma (max_fan_angle): tm = D*SIN(gamma)    
    maxFloc = d*sin(max_fan_angle*pi/180);
end

if d < maxFloc 
    error(message('images:fan2para:dTooSmall', ceil( maxFloc )))
end

%-----------------------------------------------------------------------------
function parallelSensorSpacing = ...
    getDefaultParallelSensorSpacing(fanSensorGeometry,fanSensorSpacing, m, d)

% smallest spacing implied by FanSensorSpacing 
if strcmp(fanSensorGeometry,'line')
    parallelSensorSpacing = fanSensorSpacing;
else
    term1 = (fanSensorSpacing*(m-1)/2)*pi/180;
    term2 = (fanSensorSpacing*(m-3)/2)*pi/180;        
    parallelSensorSpacing = d*(sin(term1) - sin(term2));
end

%-------------------------------------
function args = parseInputs(varargin)

narginchk(2,18);

F = varargin{1};
d = varargin{2};

validateattributes(F, {'double','single'}, ...
              {'real', '2d', 'nonsparse'}, ...
              mfilename, 'F', 1);

validateattributes(d, {'double','single'},...
              {'real', '2d', 'nonsparse', 'positive'}, ...
              mfilename, 'D', 2);

% Default values
args.FanSensorSpacing          = 1;
args.ParallelRotationIncrement = [];
args.ParallelSensorSpacing     = [];
args.ParallelCoverage          = 'halfcycle';
args.FanSensorGeometry         = 'arc';
args.Interpolation             = 'linear';
args.FanCoverage               = 'cycle';
args.FanRotationIncrement      = [];

valid_params = {'FanSensorSpacing',...          
                'ParallelRotationIncrement',...                
                'ParallelSensorSpacing',...
                'ParallelCoverage',...
                'FanSensorGeometry',...
                'Interpolation',...
                'FanCoverage',...
                'FanRotationIncrement'};

num_pre_param_args = 2;
args = check_fan_params(varargin(3:nargin),args,valid_params,...
                        mfilename,num_pre_param_args);

if strcmp(args.FanCoverage,'minimal')
    args.ParallelCoverage = 'halfcycle';
    
    if isempty(args.FanRotationIncrement)
        error(message('images:fan2para:mustSpecifyDtheta'))
    end
end

if isempty(args.ParallelRotationIncrement)
    % default spacing same as THETA
    if strcmp(args.FanCoverage,'minimal')
        args.ParallelRotationIncrement = args.FanRotationIncrement;
    else
        n = size(F,2);
        args.ParallelRotationIncrement = 360/n;
    end
end

args.F = F;
args.d = d;
