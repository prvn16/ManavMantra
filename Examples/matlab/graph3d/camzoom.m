function camzoom(arg1, arg2)
%CAMZOOM Zoom camera.
%   CAMZOOM(ZF) zooms the camera of the current axes in or out by ZF.
%   If ZF is greater than 1, the scene appears larger. If ZF is
%   greater than 0 and less than 1, the scene appears
%   smaller. CAMZOOM(AX, ZF) uses axes AX instead of the current
%   axes. 
%
%   CAMZOOM sets the CameraViewAngle property of an axes.
%
%   See also CAMORBIT, CAMPAN, CAMROLL, CAMDOLLY.
 
%   Copyright 1984-2005 The MathWorks, Inc. 

if nargin==1
  ax = gca;
  zf = arg1;
elseif nargin==2
  ax = arg1;
  zf = arg2;
else
  error(message('MATLAB:camzoom:TooManyInputs'))
end

if (zf <= 0)
   error(message('MATLAB:camzoom:InvalidInput'))
end

if isa(ax,'matlab.graphics.chart.Chart')
    error(message('MATLAB:Chart:UnsupportedConvenienceFunction', 'camzoom', ax.Type));
end


darSave = get(ax, 'dataaspectratio');
cvaSave = get(ax, 'cameraviewangle');
cpSave  = get(ax, 'cameraposition' );
ctSave  = get(ax, 'cameratarget'   );

v  = (ctSave-cpSave)./darSave;
dis = norm(v);
fov = 2*dis*tan(cvaSave/2*pi/180);

newcva = 2*atan((fov/zf/2)/dis)*180/pi;
set(ax, 'cameraviewangle', newcva);
