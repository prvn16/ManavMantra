classdef PlottoolsBehavior < matlab.graphics.internal.HGBehavior
%This is an undocumented class and may be removed in future
% Copyright 2013, MathWorks, Inc.,


properties 
    %PROPEDITPANELJAVACLASS Property takes a char
    PropEditPanelJavaClass = '';
    %PROPEDITPANELOBJECT Property takes a handle
    PropEditPanelObject = [];
    %ENABLE Property takes true/false
    Enable = true;
    %ACTIVATEPLOTEDITONOPEN Proeprty takes true/false 
    ActivatePlotEditOnOpen = true;
    Serialize = false;
end

properties (Constant)
    %NAME Property is read only
    Name = 'PlotTools';
end

methods 
    function ret = dosupport(~,hTarget)
        ret = ishghandle(hTarget);
    end
end  

end  % classdef

