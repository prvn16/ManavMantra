function newpix = shrinkHighDPI(pix, r)
% newpix = shrinkHighDPI(pix, r) shrinks matrix pix to match
% the size of figure position rectangle r (in pixels).

% Copyright 2016-2017 The MathWorks, Inc.

% Some monitor setups give non-integer figure Positions. We
% round the position rect to compensate.
r = fix(r);

pix_width = size(pix,2);
pix_height = size(pix,1);
fig_width = r(3);
fig_height = r(4);
if pix_width == fig_width && pix_height == fig_height
    newpix = pix; % no high dpi
elseif (fig_width*2 == pix_width) && (fig_height*2 == pix_height)
    p11 = pix(1:2:end,1:2:end);
    p12 = pix(1:2:end,2:2:end);
    p21 = pix(2:2:end,1:2:end);
    p22 = pix(2:2:end,2:2:end);
    newpix = max(max(max(p11,p12),p21),p22);
else
    newpix = imresize(pix, [fig_height fig_width]);
end
