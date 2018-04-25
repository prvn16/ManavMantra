function dataSourceChanged(this,~,~)
%DATASOURCECHANGED React to a new data source being installed.
%   React to a new data source being installed into the scope application.

%   Copyright 2007-2017 The MathWorks, Inc.

uiservices.setListenerEnable(this.ScalingChangedListener, false);
% Keep the colormap in sync so that it has the latest data information.

source = this.Application.DataSource;

% If the source is invalid, simply return.
if ~validateSource(this, source)
    return;
end

nInputs = getNumInputs(source);
maxDims = getMaxDimensions(source);

dataType = getDataTypes(source, 1);
isRGB = false;
if nInputs == 3
    isRGB = true;
    maxDims = [maxDims(1,:) 3];
    
elseif nInputs == 1
    if numel(maxDims) > 2 && maxDims(3) == 3        
        isRGB = true;
    end
end

frameRows = max(1, maxDims(1));
frameCols = max(1, maxDims(2));

% XXX How do we handle colormap?

% Adjust image limits and axis limits appropriately
%
% Be sure to "blank out" the image
% Must put in an actual image size, so that subsequent truesize
% function will operate correctly.  (Cannot set to empty image.)
%
% In case empty matrix passed in, need to override axis limits

this.DataType      = dataType;
this.IsIntensity   = ~isRGB;

% Use replaceImage API function to update the scrollpanel.  Grab the
% current magnification in case it has changed.  replaceImage does not
% maintain the magnification when the size of the image changes.
sp_api = iptgetapi(this.ScrollPanel);
sp_api.replaceImage(zeros(frameRows, frameCols, 'uint8'), ...
    'ColorMap', this.ColorMap.Map, 'PreserveView', true);


updateColorMap(this);

this.OldDimensions = maxDims;
this.MaxDimensions = maxDims;

this.ColorMap.update;
this.ColorMap.updateScaling; % Need to reapply settings because of replaceImage
this.VideoInfo.update;

% Do not update the status bar if there is no data.
if isDataEmpty(source)
    return;
end

% Status: 1:size, 2:rate, 3:num
sizeStr = sprintf('%dx%d', maxDims(1), maxDims(2));
if isRGB
    s = 'RGB';
else
    s = 'I';
end
sizeStr = sprintf('%s:%s', s, sizeStr);

hUIMgr = getGUI(this.Application);
if isempty(hUIMgr)
    hDims = this.DimsStatus;
    if ~isempty(hDims)
        hDims.Text = sizeStr;
        hDims.Width = max(hDims.Width, largestuiwidth({sizeStr})+2);
    else
        hDims.Text = sizeStr;
    end
else
    hDims = hUIMgr.findchild({'StatusBar','StdOpts','iptscopes.VideoVisual Dims'});
    if hDims.IsRendered
        hDims.WidgetHandle.Text = sizeStr;
        hDims.WidgetHandle.Width = ...
            max(hDims.WidgetHandle.Width, largestuiwidth({sizeStr})+2);
    else
        hDims.setWidgetPropertyDefault('Text', sizeStr);
    end
end

uiservices.setListenerEnable(this.ScalingChangedListener, true);

% [EOF]