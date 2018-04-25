function [d1, d2] = ipticondir
%IPTICONDIR Directories containing IPT and MATLAB icons.
%   [D1, D2] = IPTICONDIR returns the directories containing the IPT icons
%   (D1) and the MATLAB icons (D2).
%
%   Example
%   -------
%       [iptdir, MATLABdir] = ipticondir
%       dir(iptdir)
%
%   See also IMTOOL.

%   Copyright 1993-2004 The MathWorks, Inc.

pathname = fileparts(which(mfilename));
pathname = fileparts(pathname);
d1 = fullfile(pathname, 'icons');

if nargout > 1
    d2 = fullfile(toolboxdir('matlab'), 'icons');
end

