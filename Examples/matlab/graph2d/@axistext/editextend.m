function aObj = editextend(aObj, varargin)
%AXISTEXT/EDITEXTEND End text edit
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 


t = aObj;
tH = get(aObj,'MyHandle');
initVal = get(t,'FontSize');
virtualslider('init', tH, 6, initVal, 48, .5, 'set', 'FontSize');


