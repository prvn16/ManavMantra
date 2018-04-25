classdef LinkplotManager < handle
% Copyright 2016 The MathWorks, Inc.
    properties
        LinkListener
        Figures
        UndoRedoBlocked@logical
        FactoryValue  = false;
        DebugMode@logical
    end
    
    
    methods (Access = private)        
        function h = LinkplotManager()
        end
    end
    
    
    methods (Static)
        function h = getInstance()
            % Linkplotmanager is a singleton
            mlock
            persistent linkManager;
            if isempty(linkManager)
                linkManager = datamanager.LinkplotManager();
                try
                    linkManager.LinkListener = com.mathworks.page.datamgr.linkedplots.LinkedVariableObserver;
                    linkManager.LinkListener.activate;
                catch %#ok<CTCH>
                    error(message('MATLAB:graphics:linkplotdata'));
                end
            end
            h = linkManager;
        end
    end
end

