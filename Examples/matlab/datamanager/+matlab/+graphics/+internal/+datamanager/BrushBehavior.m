classdef BrushBehavior < matlab.graphics.internal.HGBehavior
% This is an undocumented class and may be removed in the future

% Copyright 2013 MathWorks, Inc.,

properties 
    DrawFcn = [];
    LinkBrushFcn = [];
    UserData = [];
    %ENABLE Property takes true/false
    Enable = true;
    Serialize = false;%SERIALIZE Property takes true/false
end

properties (Constant)
    %NAME Property is read only
    Name = 'Brush';
end

methods
    function ret = dosupport(~,hTarget)
        ret = ishghandle(hTarget);
    end
end

end  % classdef

