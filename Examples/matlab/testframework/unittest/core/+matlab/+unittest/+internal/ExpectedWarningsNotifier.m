classdef(Hidden) ExpectedWarningsNotifier <  handle
    
    properties(Constant,GetAccess=private)
        Instance = matlab.unittest.internal.ExpectedWarningsNotifier;
    end
    
    events(NotifyAccess=private, ListenAccess=private)
        ExpectedWarningsIssued;
    end
    
    
    methods(Static)
        function listener = createExpectedWarningsListener(callback)
            instance = matlab.unittest.internal.ExpectedWarningsNotifier.Instance;
            listener = event.listener(...
                instance,...
                'ExpectedWarningsIssued',...
                @(~,evd) instance.executeCallback(callback, evd.ExpectedWarnings));
        end
        function notifyExpectedWarnings(warnings)
            import matlab.unittest.internal.ExpectedWarningsNotifier;
            import matlab.unittest.internal.ExpectedWarningsEventData;
            
            instance = matlab.unittest.internal.ExpectedWarningsNotifier.Instance;
            instance.notify('ExpectedWarningsIssued', ExpectedWarningsEventData(warnings));                       
        end
    end
    
    methods(Static,Access=private)
        function executeCallback(callback, warnings)
            callback(warnings);
        end
    end
    
    
    methods(Access=private)
        function notifier = ExpectedWarningsNotifier
            % ctor should be private
            mlock;
        end
        function delete(~)
            % dtor should be private
        end
    end
end

