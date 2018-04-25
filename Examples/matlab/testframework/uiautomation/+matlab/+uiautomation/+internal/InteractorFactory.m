classdef (Abstract) InteractorFactory
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods (Static)
        
        function actor = getInteractorForHandle(H, dispatcher)
            import matlab.uiautomation.internal.ErrorInHGCallbacks;
            import matlab.uiautomation.internal.InteractorFactory;
            import matlab.uiautomation.internal.ThrowableDispatchDecorator;
            import matlab.uiautomation.internal.UIDispatcher;
            
            if isscalar(H) && isa(H,'handle')
                cls = metaclass(H);
                cls = InteractorFactory.getInteractorForClass(cls);
            else
                cls = ?matlab.uiautomation.internal.interactors.InvalidInteractor;
            end
            
            if nargin < 2
                dispatcher = UIDispatcher.forComponent(H);
                dispatcher = ErrorInHGCallbacks(dispatcher);
                dispatcher = ThrowableDispatchDecorator(dispatcher);
            end
            actor = feval(str2func(cls.Name), H, dispatcher);
        end
        
    end
    
    methods (Static, Hidden)
        
        function cls = getInteractorForClass(cls)
            
            shortClassName = getShortClassName(cls.Name);
            
            pkg = meta.package.fromName('matlab.uiautomation.internal.interactors');
            pkgcls = pkg.ClassList;
            
            % This heuristic is based on naming conventions.
            % @TODO: make a Service to reuse MATLAB Unit's ServiceLocator.
            for k=1:numel(pkgcls)
                actor = pkgcls(k);
                shortInteractorName = getShortClassName(actor.Name);
                if strcmp(shortClassName + "Interactor", shortInteractorName)
                    cls = actor;
                    return;
                end
            end
            
            cls = ?matlab.uiautomation.internal.interactors.InvalidInteractor;
            
        end

    end
    
end

function short = getShortClassName(long)
tokens = split(long, '.');
short = tokens(end);
end