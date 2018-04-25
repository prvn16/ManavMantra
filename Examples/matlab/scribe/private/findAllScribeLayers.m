function [scribelayer, child_scribelayers] = findAllScribeLayers(container)

% Given a container (figure or uipanel, find the scribe axes. If there is no
% is no existing scribe axes for the container then create one. The second
% output argument returns the scribe axes for any uipanel children of the
% container. Note that no default scribe axes will be created for these
% children.

%   Copyright 2010-2014 The MathWorks, Inc.

% Find the parent uipanel or figure
if isempty(container)
    container = gcf;
end

% Find any uipanel children which may contain additional JavaCanvases
uipanels = findobj(container,'type','uipanel');
childpanels = uipanels(uipanels~=container);

% Find the scribe camera for the specified container, creating one as
% needed
scribelayer = getDefaultCamera(container,'overlay');

% Collect scribe camera handles for children of the specified container,
% without creating any default instances
child_scribelayers = [];
for k=1:length(childpanels)
    child_scribelayers = [child_scribelayers, ...
        getDefaultCamera(childpanels(k),'overlay','-peek')]; %#ok<AGROW>
end
 