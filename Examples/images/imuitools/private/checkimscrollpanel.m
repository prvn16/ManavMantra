function hpanel = checkimscrollpanel(varargin)
%CHECKIMSCROLLPANEL Check image scrollpanel.
%   HPANEL = CHECKIMSCROLLPANEL(HIMAGE,FUNCTION_NAME,VARIABLE_NAME) returns the
%   imscrollpanel associated with HIMAGE. If no imscrollpanel is found,
%   CHECKIMSCROLLPANEL errors.
  
%   Copyright 2005-2010 The MathWorks, Inc.

narginchk(3, 3);
himage = varargin{1};
iptcheckhandle(himage,{'image'},mfilename,'HIMAGE',1)

function_name = varargin{2};
variable_name = varargin{3};

hpanel = imshared.getimscrollpanel(himage);

if isempty(hpanel)
    error(message('images:checkimscrollpanel:invalidScrollpanel', upper( function_name ), variable_name))
end
