function [I,H] = ifanbeam(varargin)
%IFANBEAM Inverse fan-beam transform.
%   I = ifanbeam(F,D) reconstructs the image I from fan-beam projection data
%   in the matrix F. D is the distance in pixels from the fan-beam vertex to
%   the center of rotation that was used to obtain the projections.
%
%   In order to perform an inverse fan-beam reconstruction, you must give
%   IFANBEAM the same parameters that were used to calculate the projection
%   data F. If you used FANBEAM to calculate F, make sure the parameters
%   are consistent when calling IFANBEAM.
%
%   I = IFANBEAM(...,PARAM1,VAL1,PARAM2,VAL2,...) specifies parameters that
%   control various aspects of the inverse fan-beam reconstruction.
%   Parameter names can be abbreviated, and case does not matter.
%
%   Parameters include:
%
%   'FanCoverage'           String or char vector specifying the range of rotation angles
%                           used to calculate the projection data F.
%                           'cycle'   - [0,360)
%                           'minimal' - Input rotation angle range is the
%                                       minimum necessary to fully represent the
%                                       object.
%
%                           Default value: 'cycle'
%                        
%   'FanRotationIncrement'  Positive real scalar specifying the increment 
%                           of the rotation angle of the fan-beam
%                           projections. Measured in degrees.
%
%                           Default value: 1
%
%   'FanSensorGeometry'     String or char vector specifying how sensors are positioned.
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
%   'Filter'                String or char vector specifying filter.
%                           'Ram-Lak', 'Shepp-Logan', 'Cosine', 'Hamming',
%                           'Hann', 'None'
%                           See IRADON for details.
%
%                           Default value: 'Ram-Lak'
%                           
%   'FrequencyScaling'      Positive scalar.
%                           See IRADON for details.
%                           
%   'Interpolation'         String or char vector specifying interpolation method.
%
%                            'nearest'   - nearest neighbor
%                            'linear'    - linear
%                            'spline'    - piecewise cubic spline
%                            'pchip'     - piecewise cubic Hermite (PCHIP)
%
%                           Default value: 'linear'
%                                                      
%   'OutputSize'            Positive scalar specifying the number of rows 
%                           and columns in the reconstructed image. 
%                           
%                           If 'OutputSize' is not specified, IFANBEAM 
%                           determines the size automatically. 
%                           
%                           If you specify 'OutputSize', IFANBEAM
%                           reconstructs a smaller or larger portion of the
%                           image, but does not change the scaling of the
%                           data.
%                           
%                           Note: If the projections were calculated with the
%                           FANBEAM function, the reconstructed image may not
%                           be the same size as the original image.  
%                           
%   [I,H] = IFANBEAM(...) returns the frequency response of the filter
%   in the vector H.
%
%   Notes
%   -----
%   IFANBEAM converts the fan-beam data to parallel-beam projections
%   and then uses the filtered backprojection algorithm to perform
%   the inverse Radon transform.  The filter is designed directly 
%   in the frequency domain and then multiplied by the FFT of the 
%   projections.  The projections are zero-padded to a power of 2 
%   before filtering to prevent spatial domain aliasing and to 
%   speed up the FFT.
%
%   Class Support
%   -------------
%   F and D can be double or single. All other numeric input arguments must be
%   double.  The output arguments are double.
%
%   Example 1
%   ---------
%       ph = phantom(128);
%       d = 100;
%       F = fanbeam(ph,d);
%       I = ifanbeam(F,d);
%       imshow(ph), figure, imshow(I);
%
%   Example 2
%   ---------
%       ph = phantom(128); 
%       P = radon(ph); 
%       [F,obeta,otheta] = para2fan(P,100,... 
%                                   'FanSensorSpacing',0.5,... 
%                                   'FanCoverage','minimal',... 
%                                   'FanRotationIncrement',1); 
%       phReconstructed = ifanbeam(F,100,... 
%                                  'FanSensorSpacing',0.5,... 
%                                  'Filter','Shepp-Logan',... 
%                                  'OutputSize',128,... 
%                                  'FanCoverage','minimal',... 
%                                  'FanRotationIncrement',1); 
%        imshow(ph), figure, imshow(phReconstructed)
%
%   See also FAN2PARA, FANBEAM, IRADON, PARA2FAN, PHANTOM, RADON.

%   Copyright 1993-2017 The MathWorks, Inc.

%   References: 
%      A. C. Kak, Malcolm Slaney, "Principles of Computerized Tomographic
%      Imaging", IEEE Press 1988.

narginchk(2,18);

F = varargin{1};
d = varargin{2};

validateattributes(F, {'double','single'}, ...
              {'real', '2d', 'nonsparse'}, ...
              mfilename, 'F', 1);

validateattributes(d, {'double','single'},...
              {'real', '2d', 'nonsparse', 'positive'}, ...
              mfilename, 'D', 2);

% defaults
args.FanSensorGeometry    = 'arc';
args.FanSensorSpacing     = 1;
args.Interpolation        = [];
args.Filter               = [];
args.FrequencyScaling     = [];
args.OutputSize           = [];
args.FanCoverage          = 'cycle';
args.FanRotationIncrement = [];

valid_params = {'FanSensorGeometry',...
                'FanSensorSpacing',...
                'Filter',...       
                'Interpolation',...
                'FrequencyScaling',...
                'OutputSize',...      
                'FanCoverage',...
                'FanRotationIncrement'};

num_pre_param_args = 2;
args = check_fan_params(varargin(3:nargin),args,valid_params,...
                        mfilename,num_pre_param_args);

fanRotIncNeeded = strcmp(args.FanCoverage,'minimal') && ...
                         isempty(args.FanRotationIncrement);
if fanRotIncNeeded
    error(message('images:ifanbeam:mustSpecifyDtheta'))
end

[P,oploc,optheta] = fan2para(F,d,...
                             'FanSensorSpacing',args.FanSensorSpacing,...
                             'ParallelSensorSpacing',1,...
                             'FanSensorGeometry',args.FanSensorGeometry,...
                             'Interpolation','spline',...
                             'FanCoverage',args.FanCoverage,...
                             'FanRotationIncrement',args.FanRotationIncrement); %#ok

optional_args = {args.Interpolation, args.Filter, args.FrequencyScaling,...
                 args.OutputSize};
optional_args(cellfun('isempty',optional_args)) = [];

[I,H] = iradon(P,optheta,optional_args{:});
