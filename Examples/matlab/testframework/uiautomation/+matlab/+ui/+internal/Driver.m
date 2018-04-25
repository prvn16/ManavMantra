classdef Driver < handle
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        function press(driver, H, varargin)
            driver.doGesture(@uipress, H, varargin{:});
        end
        function choose(driver, H, varargin)
            driver.doGesture(@uiselect, H, varargin{:});
        end
        function drag(driver, H, varargin)
            driver.doGesture(@uidrag, H, varargin{:});
        end
        function type(driver, H, varargin)
            driver.doGesture(@uitype, H, varargin{:});
        end
        function lock(driver, FIG)
            driver.doLock(FIG, true);
        end
        function unlock(driver, FIG)
            driver.doLock(FIG, false);
        end
    end
    
    methods (Access = protected)
        
        function doGesture(~, gesture, H, varargin)
            import matlab.uiautomation.internal.InteractorFactory;
            
            if ~isscalar(H)
                e = MException( message('MATLAB:uiautomation:Driver:MustBeScalar') );
                throwAsCaller(e);
            end
            
            if ~ishghandle(H) || ~isvalid(H)
                e = MException( message('MATLAB:uiautomation:Driver:MustBeValidHGHandle') );
                throwAsCaller(e);
            end
            
            actor = InteractorFactory.getInteractorForHandle(H);
            
            try
                gesture(actor, varargin{:});
            catch e
                throwAsCaller(e);
            end
        end
        
        function doLock(~, fig, bool)
            
            import matlab.uiautomation.internal.FigureHelper;
            import matlab.uiautomation.internal.InteractorFactory;
            import matlab.uiautomation.internal.ThrowableDispatchDecorator;
            import matlab.uiautomation.internal.UIDispatcher;
            
            fig = fig(:).';
            if ~all(ishghandle(fig)) || ~all(isvalid(fig))
                e = MException( message('MATLAB:uiautomation:Driver:MustBeValidHGHandle') );
                throwAsCaller(e);
            end
            
            if ~isa(fig, 'matlab.ui.Figure') || ~all(FigureHelper.isWebFigure(fig))
                me = MException( message('MATLAB:uiautomation:Driver:MustBeUIFigure') );
                throwAsCaller(me);
            end
            
            fig = unique(fig, 'stable');
            for f=fig
                dispatcher = UIDispatcher.forComponent(f);
                dispatcher = ThrowableDispatchDecorator(dispatcher);
                actor = InteractorFactory.getInteractorForHandle(f, dispatcher);
                uilock(actor, bool);
            end
        end
        
    end
    
end
