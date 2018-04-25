function varargout = webcam(varargin)
%WEBCAM Creates webcam object to acquire frames from your Webcam.
%    CAMOBJ = WEBCAM returns a webcam object, CAMOBJ, that acquires images
%    from the specified Webcam. By default, this selects the first
%    available Webcam returned by WEBCAMLIST.
% 
%    CAMOBJ = WEBCAM(DEVICENAME) returns a webcam object, CAMOBJ, for
%    Webcam with the specified name, DEVICENAME. The Webcam name can be 
%    found using the function WEBCAMLIST.
%
%    CAMOBJ = WEBCAM(DEVICEINDEX) returns a webcam object, CAMOBJ, for
%    Webcam with the specified device index, DEVICEINDEX. The Webcam device
%    index is the index into the cell array returned by WEBCAMLIST.
%
%    CAMOBJ = WEBCAM(..., P1, V1, P2, V2,...) constructs the webcam object,
%    CAMOBJ, with the specified property values. If an invalid property
%    name or property value is specified, the webcam object is not created.
%
%    Creating WEBCAM object obtains exclusive access to the Webcam. 
%
%    SNAPSHOT method syntax:
%
%    IMG = snapshot(CAMOBJ) acquires a single frame from the Webcam.
%
%    [IMG, TIMESTAMP] = snapshot(CAMOBJ) returns the frame, IMG, and the 
%    acquisition timestamp, TIMESTAMP. 
%
%    WEBCAM methods:
%
%    snapshot     - Acquire a single frame from the Webcam.
%    preview      - Activate a live image preview window.
%    closePreview - Close live image preview window.
%
%    WEBCAM properties:    
%
%    Name                 - Name of the Webcam.
%    Resolution           - Resolution of the acquired frame.
%    AvailableResolutions - Cell array of list of available resolutions.
%
%    The WEBCAM interface also exposes the dynamic properties of the Webcam
%    that we can access programmatically. Some of these dynamic properties
%    are Brightness, Contrast, Hue, Exposure etc. The presence of these
%    properties in the WEBCAM object depends on the Webcam that you connect
%    to.
%
%    Example:
%       % Construct a webcam object
%       camObj = webcam;
%       
%       % Preview a stream of image frames.
%       preview(camObj);
%
%       % Acquire and display a single image frame.
%       img = snapshot(camObj);
%       imshow(img);
%
%    See also WEBCAMLIST
    
%   Copyright 2013-2014 The MathWorks, Inc.

varargout = {[]};

% Check if the support package is installed.
fullpathToUtility = which('matlab.webcam.internal.Utility');
if isempty(fullpathToUtility) 
    % Support package not installed - Error.
    if feature('hotlinks')
        error('MATLAB:webcam:supportPkgNotInstalled', message('MATLAB:webcam:webcam:supportPkgNotInstalled').getString);
    end
end