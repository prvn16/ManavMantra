% Copyright 2014-2017 The MathWorks, Inc.

classdef (Sealed) PlotManager < matlab.mixin.SetGet & JavaVisible
    events
        PlotFunctionDone
        PlotEditPaste
        PlotEditBeforePaste
        PlotSelectionChange
    end
    
    methods (Access = private)
        function h = PlotManager
            mlock
        end
    end

    methods (Static)
        function h = getInstance
            mlock
            persistent pm;
            if isempty(pm) || ~isvalid(pm)
                pm = matlab.graphics.internal.PlotManager;
            end
            h = pm;
        end
    end
end
