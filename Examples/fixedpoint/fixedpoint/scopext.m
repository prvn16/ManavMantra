function scopext(ext)
%SCOPEXT Register the Fixed-Point Histogram Scope extension.

%   Copyright 2009 The MathWorks, Inc.


% Visuals
r = ext.add('Visuals','Fixed-Point Histogram', 'scopeextensions.HistogramVisual', 'Histogram Visualization');
r.Visible = false;

% Scope specific information (DataHandlers)
uiscopes.addDataHandler(ext, 'Streaming', 'Fixed-Point Histogram', 'scopeextensions.HistogramMLStreamingHandler');

