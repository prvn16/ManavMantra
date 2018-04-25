function B = imrotate3(varargin)
%IMROTATE3 Rotate 3-D grayscale image
%
%   B = IMROTATE3(V, ANGLE, W) rotates the 3-D grayscale image V by ANGLE
%   degrees counterclockwise around an axis passing through the origin
%   [0 0 0]. W is a vector which specifies the direction of the axis of
%   rotation in 3-D space.
%
%   To rotate the volume clockwise, specify a negative value for ANGLE.
%   IMROTATE3 makes the output volume B large enough to contain the entire
%   rotated 3-D image. By default, IMROTATE3 uses nearest neighbor
%   interpolation and sets the values of voxels in B that are outside the
%   boundaries of the rotated image to zero.
%
%   B = IMROTATE3(V, ANGLE, W, METHOD) rotates volumetric image V using the
%   interpolation method specified by METHOD. METHOD is a char array with
%   one of the following values:
%
%     'nearest'  -  Nearest neighbor interpolation.
%
%     'linear'   -  Trilinear interpolation.
%                   This is the default.
%
%     'cubic'    -  Tricubic interpolation. Note: This interpolation method
%                   can produce voxel values outside the original range.
%
%   B = IMROTATE3(V, ANGLE, W, METHOD, BBOX) rotates volume V, where BBOX
%   controls the size of the output image B. BBOX is a char array with one
%   of the following values:
%
%     'loose'  -  Make output image B large enough to contain the entire
%                 rotated image. B is generally larger than V.
%                 This is the default.
%
%     'crop'   -  Make output image B the same size as the input image V,
%                 cropping the rotated image to fit.
%
%   B = IMROTATE3(...,Name,Value) specifies additional parameters that
%   control various aspects of the geometric transformation. Parameter
%   names can be abbreviated. Parameters include:
%
%     'FillValues'  -  Numeric scalar value used to fill voxels in the
%                      output volume B that are outside the limits of the
%                      rotated volume.
%                      Default: 0.
%
%   Notes
%   -----
%   [1] If you wish to specify the direction W of the axis of rotation in
%       spherical coordinates, use the SPH2CART function to convert it to
%       Cartesian coordinates before passing it to IMROTATE3.
%   [2] IMROTATE3 assumes that the input volume V is centered on the origin
%       [0 0 0]. Use the IMTRANSLATE function to translate V to [0 0 0]
%       before using IMROTATE3. The output volume B can be translated back
%       to the original position of V with the opposite translation vector.
%
%   Class Support
%   -------------
%   The input image V can be numeric or logical. The output image B is of
%   the same class as the input image. ANGLE and W can be numeric.
%
%   Example
%   -------
%
%     % Load input image
%     s = load('mri');
%     V = squeeze(s.D);
%     sizeO = size(V);
% 
%     % Specify angle of rotation around the axis of rotation in degrees
%     ANGLE = 180;
% 
%     % Specify axis of rotation
%     W = [2 3 1];
% 
%     % Display the original volume
%     figure;
%     slice(double(V), sizeO(2)/2, sizeO(1)/2, sizeO(3)/2);
%     shading interp, colormap gray;
%     title('Original');
% 
%     % Perform 3-D image rotation around specified axis by a specified angle
%     B = imrotate3(V, ANGLE, W, 'nearest', 'loose', 'FillValues', 0);
%     
%     sizeR = size(B);
%     % Visualize the rotated volume
%     figure;
%     slice(double(B), sizeR(2)/2, sizeR(1)/2, sizeR(3)/2);
%     shading interp, colormap gray;
%     title('Rotated');
%
%   See also IMRESIZE, IMROTATE, IMTRANSLATE, IMWARP, volumeViewer.

%   Copyright 2016-2017 The MathWorks, Inc.

% Parse inputs
varargin = matlab.images.internal.stringToChar(varargin);
[V,ANGLE,W,METHOD,BBOX,FILLVAL] = parse_inputs(varargin{:});

% Convert angle to radians
ANGLE = deg2rad(ANGLE);

if isempty(V) || all(W==0)
    
    B = V; % No rotation needed
    
else
    
    % Get unit direction vector
    unit_W = W/norm(W);
    
    % Quaternion rotation matrix
    t_quat = quat_matrix(unit_W,ANGLE);
    
    % Quaternion rotation
    tf = affine3d(t_quat);
    
    RA = imref3d(size(V));
    Rout = images.spatialref.internal.applyGeometricTransformToSpatialRef(RA,tf);
    
    if strcmp(BBOX,'crop')
        % Trim Rout, preserve center and resolution.
        Rout.ImageSize = RA.ImageSize;
        xTrans = mean(Rout.XWorldLimits) - mean(RA.XWorldLimits);
        yTrans = mean(Rout.YWorldLimits) - mean(RA.YWorldLimits);
        zTrans = mean(Rout.ZWorldLimits) - mean(RA.ZWorldLimits);
        Rout.XWorldLimits = RA.XWorldLimits+xTrans;
        Rout.YWorldLimits = RA.YWorldLimits+yTrans;
        Rout.ZWorldLimits = RA.ZWorldLimits+zTrans;
    end
    
    B = imwarp(V,tf,METHOD,'OutputView',Rout,'FillValues',FILLVAL);
    
end
end

function t = quat_matrix(W, ANGLE)

a_x = W(1,1);
a_y = W(1,2);
a_z = W(1,3);

c = cos(ANGLE);
s = sin(ANGLE);

t1 = c + a_x^2*(1-c);
t2 = a_x*a_y*(1-c) - a_z*s;
t3 = a_x*a_z*(1-c) + a_y*s;
t4 = a_y*a_x*(1-c) + a_z*s;
t5 = c + a_y^2*(1-c);
t6 = a_y*a_z*(1-c)-a_x*s;
t7 = a_z*a_x*(1-c)-a_y*s;
t8 = a_z*a_y*(1-c)+a_x*s;
t9 = c+a_z^2*(1-c);

t = [t1 t2 t3 0
    t4 t5 t6 0
    t7 t8 t9 0
    0  0  0  1];
end

function [V,ang,W,method,bbox,fillval] = parse_inputs(varargin)

% Specify minimum and maximum number of arguments
narginchk(3,7);

% validate image
V = varargin{1};
validateattributes(V,{'numeric','logical'},{'ndims',3},mfilename,'V',1);

% validate angle
ang = double(varargin{2});
validateattributes(ang,{'numeric'},{'real','scalar'},mfilename,'ANGLE',2);

% validate axis of rotation
W = double(varargin{3});
attributes = {'size',[1,3],'real','finite'};
validateattributes(W,{'numeric'},attributes,mfilename,'W',3);

% Default interpolation method, bounding box and fill values
method = 'linear';
bbox   = 'loose';
fillval = 0;

% If number of arguments is 4
if nargin==4
    
    % Get fourth argument
    arg = varargin{4};
    [method, bbox] = getArgVal(arg,4,nargin,method,bbox,fillval,varargin{:});
    
end

if nargin==5
    
    % Parse the fourth argument
    arg = varargin{4};
    [method, bbox, fillval, fill_flag] = getArgVal(arg,4,nargin,method,bbox,fillval,varargin{:});
    
    % If the fourth argument is not Fillvalues, parse the fifth argument
    if fill_flag == 0
        
        arg = varargin{5};
        [method, bbox] = getArgVal(arg,5,nargin,method,bbox,fillval,varargin{:});
        
    end
    
end

if nargin==6
    
    % Parse the fourth argument
    arg = varargin{4};
    
    % "getArgVal" will error out if the 4th argument is 'FillValues' or any
    % invalid 'method'/'bbox'
    [method, bbox] = getArgVal(arg,4,nargin,method,bbox,fillval,varargin{:});
    
    % --------------------------------------------------------------------
    % Parse the fifth argument. "getArgVal" will error out if the 5th
    % argument is not 'FillValues'. If the 5th argument is 'FillValues', "getArgVal"
    % will parse the 6th argument to extract the scalar value.
    arg = varargin{5};
    [method, bbox, fillval] = getArgVal(arg,5,nargin,method,bbox,fillval,varargin{:});
    
end

if nargin==7
    
    % Parse the fourth argument
    arg = varargin{4};
    
    % "getArgVal" will error out if the 4th argument is 'FillValues' or any
    % invalid 'method'/'bbox'
    [method, bbox] = getArgVal(arg,4,nargin,method,bbox,fillval,varargin{:});
    
    % --------------------------------------------------------------------
    
    arg = varargin{5};
    
    % "getArgVal" will error out if the 5th argument is 'FillValues' or any
    % invalid 'method'/'bbox'
    [method, bbox] = getArgVal(arg,5,nargin,method,bbox,fillval,varargin{:});
    
    % --------------------------------------------------------------------
    
    arg = varargin{6};
    
    % Parse the sixth argument. "getArgVal" will error out if the 6th
    % argument is not 'FillValues'. If the 6th argument is 'FillValues', "getArgVal"
    % will parse the 7th argument to extract the scalar value.
    [method, bbox, fillval] = getArgVal(arg,6,nargin,method,bbox,fillval,varargin{:});
    
end

end

function [met, bb, fill, f_flag] = getArgVal(arg,argnum,argcount,method,bbox,fillval,varargin)

% Error if argument is not string
if ~ischar(arg)
    error(message('images:imrotate3:expectedString'));
end

% Default interpolation method, bounding box and fill values
met = method;
bb   = bbox;
fill = fillval;
f_flag = 0;

strs  = {'nearest','linear','cubic','crop','loose','fillvalues'};
interpBboxFill   = [ 0 ,0 ,0 ,1 ,1, 2];

idx = stringmatch(lower(arg),strs);
checkStringValidity(idx,arg);
arg = strs{idx};

% Error out when secondlast argument is not 'FillValues' when
% total number of arguments is 6 or 7
if argcount == 6
    if ~strcmp(arg,'fillvalues') && argnum == 5
        error(message('images:imrotate3:invalidParameterLocation'));
    elseif strcmp(arg,'fillvalues') && argnum ~= 5
        error(message('images:imrotate3:invalidParameterLocation'));
    end
    
elseif argcount == 7
    if ~strcmp(arg,'fillvalues') && argnum == 6
        error(message('images:imrotate3:invalidParameterLocation'));
    elseif strcmp(arg,'fillvalues') && argnum ~= 6
        error(message('images:imrotate3:invalidParameterLocation'));
    end
end

% Identify if the argument is interpolation method, bounding box or
% fill values.
if interpBboxFill(idx) == 0
    met = arg;
elseif interpBboxFill(idx) == 1
    bb = arg;
    % If argument is 'fillvalues', parse the next next argument for fill value
elseif interpBboxFill(idx) == 2
    f_flag = 1;
    if(argnum+1 <= argcount)
        arg2 = varargin{argnum+1};
        if ~isscalar(arg2)
            error(message('images:imrotate3:expectedScalarFillValue'));
        end
        fill = arg2;
    else
        error(message('images:imrotate3:specifyFillvalue'));
    end
end
end

function idx = stringmatch(str,cellOfStrings)
idx = find(strcmp(str, cellOfStrings));
end

function checkStringValidity(idx,arg)
if isempty(idx)
    error(message('images:imrotate3:unrecognizedInputString', arg));
end
end
