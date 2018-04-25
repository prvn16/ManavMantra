function leg_images = getLegendableImages(h)

% Returns an array of Images which should be viewed as legendable by the
% Plot Browser

%   Copyright 2009-2011 The MathWorks, Inc.

legkids = findobj(h,'-depth',1,'Type','image');
I = false(size(legkids));
for k=1:length(legkids)
    if hasbehavior(legkids(k),'legend')
       I(k) = true;
    end
end
leg_images = legkids(I);