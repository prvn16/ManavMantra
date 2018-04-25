function volumeViewer(V, ref)
%volumeViewer View volumetric image.
%   volumeViewer opens a volume visualization app. The app can be
%   used to view 2-D slices of a volume and do volume rendering, maximumum
%   intensity projection, and isosurface visualizations of volume data.
%
%   volumeViewer(V) loads the volume V into a volume visualization app.
%
%   volumeViewer(V, REF) loads the volume V with spatial referencing
%   information REF into a volume visualization app. REF is a 3-D scale
%   transformation of size [4 4].
%
%   volumeViewer CLOSE closes all open volume viewer apps.
%
%   Class Support
%   -------------
%   V is a scalar valued MxNxP image of class logical, uint8, uint16,
%   uint32, int8, int16, int32, single, or double.
%
%   REF is a scalar valued 4x4 array of class double.
%
%   See also isosurface, slice

%   Copyright 2016-2017 The MathWorks, Inc.

if nargin == 0
    % Create a new Volume Viewer app.
    images.internal.app.volview.VolumeViewer();
else    
    V = matlab.images.internal.stringToChar(V);
    if ischar(V)
        % Handle the 'close' request
        validatestring(V, {'close'}, mfilename);
        images.internal.app.volview.VolumeViewer.deleteAllTools();
    else
        supportedImageClasses    = {'int8','uint8','int16','uint16','int32','uint32','single','double','logical'};
        supportedImageAttributes = {'real','nonsparse','nonempty'};
        validateattributes(V,supportedImageClasses,supportedImageAttributes,mfilename,'V');
        
        if ~images.internal.app.volview.isVolume(V)
            error(message('images:volumeViewer:requireVolumeData'));
        end
        
        if nargin == 1
            images.internal.app.volview.VolumeViewer(V);
        elseif nargin == 2
            validateattributes(ref, {'double'}, {'size', [4 4]}, mfilename, 'REF');
            images.internal.app.volview.VolumeViewer(V, ref);
        else
            naringchk(0, 2)
        end
    end     
end