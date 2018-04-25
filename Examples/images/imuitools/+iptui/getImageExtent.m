function [x_extent y_extent] = getImageExtent(h_im)
% This undocumented function may be removed in a future release.

%   Copyright 2008-2013 The MathWorks, Inc.

% get axes parent
h_ax = ancestor(h_im,'Axes');
axes_xlim = get(h_ax,'XLim');
axes_ylim = get(h_ax,'YLim');

% get image size
image_size = size(get(h_im,'CData'));
image_xdata = get(h_im,'XData');
image_ydata = get(h_im,'YData');

if isempty(image_xdata)
    image_xdata = [1 0];
end

if isempty(image_ydata)
    image_ydata = [1 0];
end

% compute image extent in each dimension
x_extent = getDimensionExtent(image_size(2),image_xdata,axes_xlim);
y_extent = getDimensionExtent(image_size(1),image_ydata,axes_ylim);


function dim_extent = getDimensionExtent(im_dim, im_data, ax_dim)
% compute the extent of the image dimension in spatial units

if im_dim ~= 1
    % compute extent of one pixel in spatial coordinates
    im_pixel_extent = abs((im_data(end) - im_data(1)) / (im_dim - 1));
    half_pixel = im_pixel_extent / 2;
    dim_extent = sort([im_data(1) - half_pixel im_data(end) + half_pixel]);
else
    % the dimension is one pixel in size.  this is a degenerate case and we
    % return the axes limits as the default bounds.
    dim_extent = ax_dim;
end

