function ret = iscom(h)
%ISCOM  true for COM/ActiveX objects.
%   ISCOM(H) returns true if H is a COM/ActiveX object, false otherwise.
%
%   Example:
%     h=actxcontrol('mwsamp.mwsampctrl.2');
%     ret = iscom(h)
%
%   See also ISINTERFACE, ISOBJECT, ACTXCONTROL, ACTXSERVER.  
  
%   Copyright 1999-2004 The MathWorks, Inc.

if ispc
    ret = strncmp(class(h),'COM.',4);
else
    ret = false;
end


