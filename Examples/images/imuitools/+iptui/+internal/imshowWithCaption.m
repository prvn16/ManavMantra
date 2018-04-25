function haxes = imshowWithCaption(hParent, im, caption, varName)
%   Copyright 2014 The MathWorks, Inc.

% Note - hParent will be 'filled' and SizeChangedFcn clobbered


haxes = axes('Parent', hParent,...
    'Units','char');

warnState = warning('off','images:imshow:magnificationMustBeFitForDockedFigure');
resetWarnObj = onCleanup(@()warning(warnState));
if(isa(im,'logical')||isa(im,'uint8'))
    hImage = imshow(im,...
        'Parent', haxes,...
        'InitialMagnification', 'fit',...
        'Border', 'tight');
else
    % Auto-scale display range
    range = [min(im(:)), max(im(:))];
    if(range(1)==range(2))
        range = getrangefromclass(im);
    end
    hImage = imshow(im,...
        'Parent', haxes,...
        'InitialMagnification', 'fit',...
        'DisplayRange', range,...
        'Border', 'tight');
end
clear resetWarnObj;

iptui.internal.installSaveToWorkSpaceContextMenu(hImage,...
    caption, varName);

title(haxes, caption,...
    'FontWeight','normal',...
    'FontName','FixedWidth',...
    'FontSize', 12,...
    'Interpreter','None');

positionComponents(haxes);
hParent.SizeChangedFcn = @(varargin)positionComponents(haxes);
end


function positionComponents(haxes)

if(~isvalid(haxes))
    return;
end

% Position axes to ensure title is visible
hParent = haxes.Parent;

pUnits = hParent.Units;
hParent.Units = 'char';
position = hParent.Position;
hParent.Units = pUnits;

position(1:2) = 0;
position(end) = position(end)-2; % padding on top
if(position(3)>0 && position (4)>0)
    % Update only when w and h are not zeros
    haxes.Position = position;
end
end
