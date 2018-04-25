function ax = imgca(varargin)
%IMGCA Get handle to current axes containing image.
%   H = IMGCA returns the handle of the current axes that contains an 
%   image. The current axes may be in a regular figure window or in an 
%   Image Tool window.
%
%   If no figure contains an axes that contains an image, IMGCA creates a
%   new axes.
%
%   H = IMGCA(FIG) returns the handle to the current axes that contains
%   an image in the specified figure (it need not be the current figure).
%
%   Note
%   -----
%   IMGCA can be useful in getting the handle to the Image Tool axes.
%   Because the Image Tool turns graphics object handle visibility
%   off, you cannot retrieve a handle to the tool figure using gca. 
%
%   Example
%   -------
%   Compute the centroid of each coin, and superimpose its location on the
%   image. View the results using IMTOOL and IMGCA.
%
%       I = imread('coins.png');
%       figure, imshow(I)
%
%       bw = imbinarize(I, graythresh(getimage));
%       figure, imshow(bw)
%
%       bw2 = imfill(bw,'holes');
%       s  = regionprops(bw2, 'centroid');
%       centroids = cat(1, s.Centroid);
%
%       % Display original image I and superimpose centroids
%       imtool(I)
%       hold(imgca,'on')
%       plot(imgca,centroids(:,1), centroids(:,2), 'r*')
%       hold(imgca,'off')
%
%   See also GCA, GCF, IMGCF, IMHANDLES.
 
%   Copyright 1993-2015 The MathWorks, Inc.

narginchk(0,1);

if nargin==0
    fig = imgcf;
else
    fig = varargin{1};
    iptcheckhandle(fig,{'figure'},mfilename,'FIG',1)
end

if ~isempty(fig)
    currentAx = get(fig,'CurrentAxes');
    im = findobj(currentAx,'Type','image');
    if ~isempty(im)
        ax = currentAx;
    else
        % current axes doesn't contain any images
        [im,ax] = imhandles(fig);
        if ~isempty(ax)
            ax = ax(1);
        end
    end
end

if isempty(ax)
    ax = axes('parent',fig);
end
