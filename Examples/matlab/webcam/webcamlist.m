function camList = webcamlist
%WEBCAMLIST Returns a list of all webcams connected to the system.
%
%    CAMLIST = WEBCAMLIST returns a cell array of strings with names of the
%    available USB video class (UVC) compliant webcams.
%
%    See also webcam

% Author: Anchit Dhar
% Copyright 2013-2015 The MathWorks, Inc.

% Check number of input arguments.
narginchk(0, 0);

% Check if the support package is installed.
fullpathToUtility = which('matlab.webcam.internal.Utility');
if isempty(fullpathToUtility) 
    % Support package not installed - Error.
    if feature('hotlinks')
        error('MATLAB:webcam:supportPkgNotInstalled', message('MATLAB:webcam:webcam:supportPkgNotInstalled').getString);
    end
end

% Enumerate the list of available webcams.
[success, camList] = matlab.webcam.internal.Utility.enumerateWebcams;
if ~success % Failure mode
    error('MATLAB:webcamlist:enumFailed', message('MATLAB:webcam:webcamlist:enumFailed').getString);
end

camList = camList';