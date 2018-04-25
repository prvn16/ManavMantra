function [hPanel,hImLeft,hImRight,hSpLeft,hSpRight] = ...
    leftRightImscrollpanel(parent,leftImage,rightImage)
%leftRightImscrollpanel Display two images side-by-side in scroll panels.
%   [hPanel,hImLeft,hImRight,hSpLeft,hSpRight] = ...
%      leftRightImscrollpanel(PARENT,leftImage,rightImage) displays 
%   leftImage and rightImage side-by-side each in its own scroll panel. 
%   PARENT is a handle to an object that can contain a uigridcontainer.
%
%   Arguments returned include:
%      hPanel   - Handle to panel containing two scroll panels
%      hImLeft  - Handle to left image object
%      hImRight - Handle to right image object
%      hSpLeft  - Handle to left scroll panel
%      hSpRight - Handle to right scroll panel
%
%   Example
%   -------
%       % Display two images side-by-side in scroll panels
%       left = imread('peppers.png');
%       right = edge(left(:,:,1),'canny');
%       hFig = figure('Toolbar','none',...
%                     'Menubar','none');
%       leftRightImscrollpanel(hFig,left,right);

%   Copyright 2005-2014 The MathWorks, Inc.
%   

hFig = ancestor(parent,'figure');

% Call imageDisplayParseInputs twice
specificArgNames = {}; % No specific args needed
leftArgs  = images.internal.imageDisplayParseInputs(specificArgNames,leftImage);
rightArgs = images.internal.imageDisplayParseInputs(specificArgNames,rightImage);


% Display left image
hAxLeft = axes('Parent',parent);
hImLeft = images.internal.basicImageDisplay(hFig,hAxLeft,...
                            leftArgs.CData,leftArgs.CDataMapping,...
                            leftArgs.DisplayRange,leftArgs.Map,...
                            leftArgs.XData,leftArgs.YData, false);

% Display right image
hAxRight = axes('Parent',parent);
hImRight = images.internal.basicImageDisplay(hFig,hAxRight,...
                            rightArgs.CData,rightArgs.CDataMapping,...
                            rightArgs.DisplayRange,rightArgs.Map,...
                            rightArgs.XData,rightArgs.YData, false);

% Create a scroll panel for left image
hSpLeft = imscrollpanel(parent,hImLeft);

% Create scroll panel for right image
hSpRight = imscrollpanel(parent,hImRight);

hPanel = uipanel('Parent',parent,'Position',[0 0 1 1],'BorderType','none');
hPanelLeft  = uipanel('Parent',hPanel,'Position',[0 0 0.5 1],'BorderType','none');
hPanelRight = uipanel('Parent',hPanel,'Position',[0.5 0 0.5 1],'BorderType','none'); 

hFig = iptancestor(hSpLeft,'Figure');
iptui.internal.setChildColorToMatchParent([hSpLeft,hSpRight,hPanel],hFig);

% Reparent hSpLeft and hSpRight
set(hSpLeft,'parent',hPanelLeft)
set(hSpRight,'parent',hPanelRight)

% Tag components for testing
set(hSpLeft,'Tag','LeftScrollPanel')
set(hSpRight, 'Tag','RightScrollPanel')  
