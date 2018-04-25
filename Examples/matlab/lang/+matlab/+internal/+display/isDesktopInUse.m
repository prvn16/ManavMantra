function desktopMode = isDesktopInUse
% dekstopMode identifies whether or not the MATLAB desktop is in use. If
% the MATLAB desktop is in use, it returns true. If MATLAB is operating in
% nodesktop, nojvm or deployed modes, it returns false.

% Copyright 2016 The MathWorks, Inc 

desktopMode = false;
try
    desktopMode = desktop('-inuse');
catch
end

end