function h = createImageFromTargetImage(targetImage,parent)
%createImageFromTargetImage creates image using target image.
%   H = createImageFromTargetImage(TARGETIMAGE,PARENT) creates a new image
%   object that has the same properties as the TARGETIMAGE. The image object H
%   is parented to PARENT.
%
%   We created this function in order to avoid using COPYOBJ, which was
%   causing a host of problems in IMPIXELREGIONPANEL and in
%   IMOVERVIEWPANEL.
  
%   Copyright 2005 The MathWorks, Inc.  
  
h = image('Parent',parent,...
          'BusyAction',get(targetImage,'BusyAction'),...
          'CData',get(targetImage,'CData'),...
          'CDataMapping',get(targetImage,'CDataMapping'),...
          'Interruptible',get(targetImage,'Interruptible'),...
          'XData',get(targetImage,'XData'),...
          'YData',get(targetImage,'YData'));

