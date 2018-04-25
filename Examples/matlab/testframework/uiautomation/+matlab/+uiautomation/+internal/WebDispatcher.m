classdef WebDispatcher < matlab.uiautomation.internal.UIDispatcher
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Access = private)
        Pending = false;
        
        SettledState = [];
        SubIDs = {};
    end
    
    properties (Constant, Access = private)
        FulfillChannel = '/uitest/fulfilled';
        RejectChannel  = '/uitest/rejected';
        TimeOut = 20;
    end
    
    methods (Access = ?matlab.uiautomation.internal.UIDispatcher)
        function dispatcher = WebDispatcher()
        end
    end
    
    methods
        
        function dispatchEventAndWait(dispatcher, model, evtName, varargin)
            %dispatchEventAndWait
            %
            % Use this method to guarantee synchronization between server
            % and client. The method will return only when a "fulfill" or
            % "reject" message is received from the client, else errors if
            % waiting for more than 20 seconds.
            
            import matlab.uiautomation.internal.FigureHelper;
            
            dispatcher.subscribe();
            clean = onCleanup(@()dispatcher.unsubscribe);
            
            dispatcher.Pending = true;
            
            dispatcher.dispatchEvent(model, evtName, varargin{:});
            
            settled = dispatcher.block();
            settled.resolve();
            
            fig = ancestor(model, 'figure');
            if ~isempty(fig)
                FigureHelper.flush(fig);
            end
        end
        
        function dispatchEvent(dispatcher, model, evtName, varargin)
            import matlab.uiautomation.internal.FigureHelper;
            import matlab.uiautomation.internal.IDService;
            
            dispatcher.okToDispatch(model);
            fig = ancestor(model, 'figure');
            FigureHelper.flush(fig);
            
            parser = inputParser;
            parser.KeepUnmatched = true;
            parser.addParameter('Options', []);
            parser.parse(varargin{:});
            
            evd = struct( ...
                'Name', evtName, ...
                'PeerNodeID', IDService.getId(model), ...
                'Options', mapOptions(parser.Results.Options), ...
                'Data', parser.Unmatched);
            
            figID = IDService.getId(fig);
            channel = ['/uitest/' figID];
            
            message.publish(channel, evd)
        end
        
    end
    
    methods (Access = protected)
        
        function settledState = fulfill(dispatcher, eventdata) %#ok<INUSD>
            import matlab.uiautomation.internal.dispatchstate.Fulfilled;
            
            settledState = Fulfilled();
            dispatcher.unblock(settledState);
        end
        
        function settledState = reject(dispatcher, eventdata) 
            import matlab.uiautomation.internal.dispatchstate.Rejected;
            
            me = MException( message(eventdata.MessageInput{:}) );
            settledState = Rejected(me);
            dispatcher.unblock(settledState);
        end
        
    end
    
    methods (Access = private)
        
        function subscribe(dispatcher)
            
            dispatcher.SubIDs{1} = message.subscribe(...
                dispatcher.FulfillChannel, @(data)dispatcher.fulfill(data));
            dispatcher.SubIDs{2} = message.subscribe(...
                dispatcher.RejectChannel, @(data)dispatcher.reject(data));
        end
        
        function unsubscribe(dispatcher)
            sub = dispatcher.SubIDs;
            for k=1:length(sub)
                message.unsubscribe(sub{k})
            end
        end
        
        function settledState = block(dispatcher)
            import matlab.uiautomation.internal.dispatchstate.Rejected;
            
            t0 = tic;
            while dispatcher.Pending && toc(t0) <= dispatcher.TimeOut
                drawnow limitrate
            end
            
            if dispatcher.Pending
                % still pending past timeout
                me = MException( message('MATLAB:uiautomation:Driver:GestureNotCompleted', dispatcher.TimeOut) );
                settledState = Rejected(me);
                return
            end
            
            % hand off resulting state
            settledState = dispatcher.SettledState;
            dispatcher.SettledState = [];
        end
        
        function unblock(dispatcher, state)
            dispatcher.Pending = false;
            dispatcher.SettledState = state;
        end
        
    end
    
end


function s = mapOptions(opts)
% Map Driver-independent options to Web-view-specifics

import matlab.uiautomation.internal.Modifiers;

modFields = {'ctrlKey',    'shiftKey',      'altKey',    'metaKey'};
modEnums =  [Modifiers.CTRL Modifiers.SHIFT Modifiers.ALT Modifiers.META];

opts = unique(opts);
modValues = ismember(modEnums, opts);

s = cell2struct(num2cell(modValues), modFields, 2);
end