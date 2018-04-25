function varargout = ipcam(varargin)
%IPCAM Creates ipcam object to acquire frames from your IP Camera.
%    CAMOBJ = IPCAM(URL) returns a ipcam object, CAMOBJ, that acquires
%    images from the specified URL. The URL is the MJPEG over HTTP URL
%    provided by your camera. 
%
%    CAMOBJ = IPCAM(URL, USERNAME, PASSWORD) returns a ipcam object,
%    CAMOBJ, that acquires images from the specified URL with
%    authentication provided by the USERNAME and PASSWORD. The URL is the
%    MJPEG over HTTP URL provided by your camera.
%
%    CAMOBJ = IPCAM(..., P1, V1) constructs the ipcam object, CAMOBJ, with
%    the specified property values. If an invalid property name or property
%    value is specified, the ipcam object is not created.
%
%    Example:
%       % Construct a ipcam object 
%       camObj = ipcam('http://192.168.0.20/video/mjpg.cgi');
%       
%       % Preview a stream of image frames.
%       preview(camObj);
%
%       % Acquire and display a single image frame.
%       img = snapshot(camObj);
%       imshow(img);

% Copyright 2015-2016 The MathWorks, Inc.
    
varargout = {[]};

% Check if the support package is installed.
try
    fullpathToUtility = which('ipcam.internal.Utility');
    if isempty(fullpathToUtility) 
        % Support package not installed - Error.
        error(getString(message('MATLAB:hwstubs:general:spkgNotInstalled', 'IP Camera', 'ML_IP_CAMERAS')));
    end
catch e
    throwAsCaller(e);
end
