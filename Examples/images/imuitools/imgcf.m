function fig = imgcf(varargin)
%IMGCF Get handle to current figure containing image.
%   H = IMGCF returns the handle of the current figure that contains an
%   image. The figure may be a regular figure window that contains at
%   least one image or an Image Tool window.
%
%   If none of the figures currently open contains an image, IMGCF 
%   creates a new figure.
%
%   Note
%   -----
%   IMGCF can be useful in getting the handle to the Image Tool figure
%   window. Because the Image Tool turns graphics object handle visibility
%   off, you cannot retrieve a handle to the tool figure using gcf. 
%
%   Example
%   -------
%   Center the Image Tool on the screen
%
%       imtool rice.png
%       sz = get(groot,'ScreenSize');
%       pos = get(imgcf,'Position');
%       pos = [(sz(3)-pos(3))/2 (sz(4)-pos(4))/2 pos(3) pos(4)];
%       set(imgcf,'Position',pos)
%
%   See also GCA, GCF, IMGCA, IMHANDLES.

%   Copyright 1993-2016 The MathWorks, Inc.

narginchk(0,0);

figs = findall(0,'Type','figure');

if numel(figs) > 0
    % filter out hidden handles that are not imtool
    tags = get(figs,'Tag');
    vis = get(figs,'HandleVisibility');
    figs(~strcmp(vis,'on') & ~strcmp(tags,'imtool')) = [];

    % filter out figures that don't contain any images
    idx = [];
    for i = 1:numel(figs)
        hIm = imhandles(figs(i));
        if isempty(hIm)
            idx(end+1) = i;
        end
    end
    figs(idx) = [];
end

if numel(figs) > 0
    fig = figs(1);
else
    fig = figure;
end
