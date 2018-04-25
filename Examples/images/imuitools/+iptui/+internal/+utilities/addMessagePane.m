function msgPane = addMessagePane(hFig,message)
%addMessagePane(hFig,message) adds a minimizable message notification pane
%to the top of the figure. This function assumes the message to be 1 line
%long.

% Copyright 2015 The MathWorks, Inc.

msgPane = ctrluis.PopupPanel(hFig);

fontName = get(0,'DefaultTextFontName');
fontSize = 12;
txtPane = ctrluis.PopupPanel.createMessageTextPane(message,fontName,fontSize);
msgPane.setPanel(txtPane);

%Position message pane at the top of the figure. Assume message to be
%one line only.
positionMessagePane();

msgPane.showPanel()

hFig.SizeChangedFcn = @(~,~)positionMessagePane();

function positionMessagePane()

msgLen = numel(message);
pos = hgconvertunits(hFig, [0 0 msgLen, 2], 'characters', 'normalized', hFig);

pos(2) = 1 - pos(4);
pos(3) = 1;

msgPane.setPosition(pos);
end

end

