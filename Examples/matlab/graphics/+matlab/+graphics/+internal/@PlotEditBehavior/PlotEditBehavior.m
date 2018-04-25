classdef (CaseInsensitiveProperties = true) PlotEditBehavior < matlab.graphics.internal.HGBehavior

% Copyright 2013 The MathWorks, Inc.

properties (SetAccess = protected)
    Name = 'Plotedit';
    Enable_ = true;
end

properties 
    EnableMove = true;
    AllowInteriorMove = false;
    EnableSelect = true;
    MouseOverFcn = [];
    ButtonDownFcn = [];
    ButtonUpFcn = [];
    KeepContextMenu = false;
    MouseMotionFcn = [];
    EnableCopy = true;
    EnablePaste = true;
    EnableDelete = true;
end

properties (Dependent = true)
    Enable;
end

properties (Transient=true)
    Serialize = true;
end

methods 
    function set.Enable(this,val)
        this.EnableSelect = val;
        this.EnableMove = val;
        this.EnableCopy = val;
        this.EnablePaste = val;
        this.EnableDelete = val;
        this.Enable_ = val;
    end
    
     function val = get.Enable(this)
        val = this.Enable_;
    end
end

methods
    function thisSerialize = saveobj(this)
        if this.Serialize
            thisSerialize = this;
        else
            thisSerialize = [];
        end
    end
    
    function ret = dosupport(~,hTarget)
       ret = ishghandle(hTarget) && isobject(handle(hTarget)) && ...
           isvalid(handle(hTarget));
    end
end
end
        

