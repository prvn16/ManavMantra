function registerFixedPointExtensions(ext)
%REGISTERFIXEDPOINTEXTENSIONS register the fixed-point extensions.

%   Copyright 2016-2017 The MathWorks, Inc.

% Visuals
r = ext.add('Visuals','Fixed-Point Histogram', 'embedded.ntxui.HistogramVisual', 'Histogram Visualization');
r.Visible = false;

% Scope specific information (DataHandlers)
uiscopes.addDataHandler(ext, 'Streaming', 'Fixed-Point Histogram', 'scopeextensions.HistogramMLStreamingHandler');

% [EOF]
