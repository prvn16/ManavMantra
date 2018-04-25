function adjustHistAxisSize(ntx)
% Adjust histogram axis width and height,
% based on current size of parent uipanel

%   Copyright 2010 The MathWorks, Inc.

% Update position of body panel
%
% x start need to leave space for y-axis label and ticks
%  [ left_margin_pix,  bottom_margin_pix, ...
%    right_margin_pix, top_margin_pix ]
left_pix   = ntx.Margins(1);
bottom_pix = ntx.Margins(2);
right_pix  = ntx.Margins(3);
top_pix    = ntx.Margins(4);
[~,body_dx,body_dy] = getBodyPanelAndSize(ntx.dp);
dx = max(1, body_dx - left_pix   - right_pix);
dy = max(1, body_dy - bottom_pix - top_pix);
set(ntx.hHistAxis,'Position',[left_pix bottom_pix dx dy]);
