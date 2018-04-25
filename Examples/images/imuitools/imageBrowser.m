function imageBrowser(imagedata)
%imageBrowser Browse images using thumbnails.
%  imageBrowser opens an image browsing app. This app can be used to look
%  at a large number of images from a folder. Images can be saved to the
%  MATLAB workspace as an image datastore object.
%
%  imageBrowser(FOLDER) opens the image browsing app with all images in
%  FOLDER loaded.
%
%
%  imageBrowser(IMDS) opens the image browsing app with all images
%  contained in the image datastore object IMDS.
%
%   Examples:
%
%       % Open all images in current folder
%       imageBrowser .
%
%       % Create and inspect an image datastore
%       imds = imageDatastore(fullfile(matlabroot,'toolbox/images/imdata/'));
%       imageBrowser(imds);
%
%   See also imageDatastore, imageBatchProcessor

%   Copyright 2016 The MathWorks, Inc.

switch nargin
    case 0
        iptui.internal.imageBrowser.ImageBrowserCore;
    case 1
        if isa(imagedata, 'matlab.io.datastore.ImageDatastore')
            h = iptui.internal.imageBrowser.ImageBrowserCore;
            h.newVarCollectionFig(inputname(1), imagedata);
        elseif ischar(imagedata) && isdir(imagedata)
            h = iptui.internal.imageBrowser.ImageBrowserCore;
            recursiveTF = false;
            h.loadFolder(imagedata,recursiveTF);
        else
            error(message('images:imageBrowser:unrecognizedInput'))
        end
    otherwise
        assert(false,'Unexpected syntax');
end
end


