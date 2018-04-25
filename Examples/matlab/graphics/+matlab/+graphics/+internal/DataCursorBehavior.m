classdef DataCursorBehavior < matlab.graphics.internal.HGBehavior
% This is an undocumented class and may be removed in a future release.

% Copyright 2013-2017 The MathWorks, Inc.

properties (Constant)
    %NAME Property (read only)
    Name = 'DataCursor';
end

properties
    StartDragFcn = [];
    EndDragFcn = [];
    UpdateFcn = [];
    CreateFcn = [];
    StartCreateFcn = [];
    UpdateDataCursorFcn = [];
    MoveDataCursorFcn = [];
    %CREATENEWDATATIP Property takes true/false 
    CreateNewDatatip = false;
    %ENABLE Property takes true/false
    Enable = true;
end


properties (Transient)
    %SERIALIZE Property 
    Serialize = true;
end


methods 
    function [ret] = dosupport(~,hTarget)
        % Support double handle inputs
        hTarget = handle(hTarget);
        
        % axes or axes children
        ret = isa(hTarget, 'matlab.graphics.mixin.AxesParentable') ...
            || isa(hTarget, 'matlab.graphics.mixin.PolarAxesParentable') ...
            || isa(hTarget, 'matlab.graphics.mixin.UIAxesParentable') ...
            || isa(hTarget, 'matlab.graphics.axis.AbstractAxes') ...
            || isgraphics(hTarget, 'axes');
    end
end 

end  % classdef

