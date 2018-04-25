classdef plottoolsbehavior < matlab.mixin.SetGet & matlab.mixin.Copyable
      
    properties (SetAccess=protected, SetObservable, GetObservable)
        Name = 'PlotTools';
    end
    
    properties (SetObservable, GetObservable)
        PropEditPanelJavaClass char = '';
        PropEditPanelObject handle;
        Enable logical = true;
        ActivatePlotEditOnOpen logical = true;
    end
    
    properties (Transient, SetObservable, GetObservable)
        Serialize = false;
    end
    
    methods (Hidden)
        ret = dosupport(hThis,hTarget)
    end    
end