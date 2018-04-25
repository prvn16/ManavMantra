classdef (Abstract) DialogHelper < handle & ...
        matlab.ui.internal.componentframework.services.core.identification.IdentificationService & ...
        matlab.ui.internal.componentframework.services.optional.ViewReadyInterface
    %DIALOGHELPER utility function used by In-App dialogs
    
    methods (Static, Hidden)
        function out = getFigureID(f)
            out = f.getId();
        end
        
        function id = validateUIfigure(h)
            if isempty(h) || ~isscalar(h) || ~ishghandle(h, 'figure')
                throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidFigureHandle')));
            end
            
            if strcmpi(h.Visible,'off')
                throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvisibleFigure')));
            end
            
            drawnow; % To draw and get ID after update
            id = matlab.ui.internal.dialog.DialogHelper.getFigureID(h);
            if isempty(id)
                throwAsCaller(MException(message('MATLAB:uitools:uidialogs:NotAnAppWindowHandle')));
            end
        end
        
        function msg = validateMessageText(msgString)
            if ischar(msgString) && (isempty(msgString) || isrow(msgString))
                msg = msgString;
                return;
            elseif iscellstr(msgString) && isvector(msgString)
                msg = msgString{1};
                for k = 2:length(msgString)
                    msg = sprintf('%s\n%s', msg, msgString{k});
                end
                return
            end
            throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidMessageText')));
        end
        
        function title = validateTitle(title)
            if ischar(title)
                if isempty(title)
                    return;
                end
                if isrow(title)
                    % Replace \n, \r characters with spaces
                    title = regexprep(title, '\n|\r',' ');
                    return;
                end
            end
            throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidTitleText')));
        end
        
        function [val, iconType] = validateIcon(val)
            invalidIcon = true;
            if ischar(val)
                presetIcon = {'error','warning','info','success','question','none'};
                iconMatched = strmatch(lower(val), presetIcon); %#ok<MATCH2>
                if isempty(val)
                    val = '';
                    iconType = 'preset';
                    invalidIcon = false;
                elseif (iconMatched)
                    val = presetIcon{iconMatched};
                    if strcmpi(val,'none')
                        % none and '' do the same thing.
                        val = '';
                    end
                    iconType = 'preset';
                    invalidIcon = false;
                else
                    fid = fopen(val, 'r'); % Opens file in current directory or matlab search path.
                    if (fid == -1)
                        warning(message('MATLAB:uitools:uidialogs:UnableToReadIconFile'));
                        iconType = 'preset';
                        val = '';
                        invalidIcon = false;
                    else
                        filename = fopen(fid);  % Get the full pathname if not in pwd.
                        fclose(fid);
                        [~, ~, ext] = fileparts(filename);
                        if ~isempty(ext) && ismember(lower(ext(2:end)), {'svg','png','jpg','gif'})
                            invalidIcon = false;
                            iconType = 'file';
                            val = filename;
                        end
                    end
                end
            elseif(isnumeric(val) && (ndims(val) == 3) && (size(val,3) ==3))
                iconType = 'cdata';
                invalidIcon = false;
            end
            if (invalidIcon)
                throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidIconSpecified')));
            end
        end
        
        function [params, iconType] = validatePVPairs(params, varargin)
            %Provide defaults as params struct
            iconType = 'preset';
            
            numArgs = numel(varargin);
            if (numArgs == 0)
                return;
            end
            if (mod(numArgs,2)==1)
                throwAsCaller(MException(message('MATLAB:uitools:uidialogs:IncorrectNameValuePairs')));
            end
            
            fields = fieldnames(params);
            for k = 1:2:numArgs
                % Handle parameter
                param = varargin{k};
                if ~ischar(param)
                    throwAsCaller(MException(message('MATLAB:uitools:uidialogs:IncorrectParameter')));
                end
                paramMatched = strmatch(lower(param), lower(fields)); %#ok<MATCH2> % Partial and Case Insensitive
                if isempty(paramMatched)
                    throwAsCaller(MException(message('MATLAB:uitools:uidialogs:IncorrectParameterName', param)));
                end
                param = fields{paramMatched};
                
                % Handle value
                val = varargin{k+1};
                switch (param)
                    case 'Icon'
                        [val, iconType] = matlab.ui.internal.dialog.DialogHelper.validateIcon(val);
                        
                    case 'Modal'
                        % Scalar: true, false, 0 or 1 accepted
                        if isempty(val) || ~isscalar(val)  || ~(islogical(val) || isnumeric(val)) || ~(val == 0 || val == 1)
                            throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidModalValue')));
                        end
                        val = logical(val);
                        
                    case 'CloseFcn'
                        validFcn = false;
                        if isempty(val) || ischar(val)
                            validFcn = true;
                        elseif iscell(val)
                            if isempty(val{1}) || ischar(val{1}) || isa(val{1}, 'function_handle')
                                validFcn = true;
                            end
                        elseif isa(val, 'function_handle')
                            validFcn = true;
                        end
                        if ~validFcn
                            throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidCloseFcnValue')));
                        end
                        
                    case 'Options'
                        if ~(iscellstr(val) && length(val) >= 1 && length(val) <= 4 && ~any(cellfun(@isempty,val)))
                            throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidOptionsValue')));
                        end
                        
                end
                params.(param) = val;
            end
            
        end
        
        function dispatchWhenViewIsReady(f, func)
            % If view is ready, dispatch the function handle.
            if (f.isViewReady)
                func()
                return;
            end
            
            % Otherwise Setup a ViewReady Listener and then dispatch all
            % function handles when view is ready.
            p = findprop(f, 'ViewReadyDispatcher');
            if isempty(p)
                p = addprop(f, 'ViewReadyDispatcher');
                p.Hidden = true;
                p.Transient = true;
            end
            if isempty(f.ViewReadyDispatcher)
                l = addlistener(f, 'ViewReady', @(o,e) handleViewReady(o,e));
                f.ViewReadyDispatcher.Listener = l;
                f.ViewReadyDispatcher.CommandStack = {};
            end
            % Queue up the function handle in the command stack
            f.ViewReadyDispatcher.CommandStack{end+1} = func;
        end
        
        function returnController = setupAlertDialogController(newController)
            persistent controller;
            if isempty(controller)
                controller = @matlab.ui.internal.dialog.AlertDialogController;
            end
            if nargin == 1
                assert(isa(newController, 'function_handle'))
                controller = newController;
            end
            returnController = controller;
        end
        
        function returnController = setupConfirmDialogController(newController)
            persistent controller;
            if isempty(controller)
                controller = @matlab.ui.internal.dialog.ConfirmDialogController;
            end
            if nargin == 1
                assert(isa(newController, 'function_handle'))
                controller = newController;
            end
            returnController = controller;
        end
        
        function pmm = getPeerModelDialogService(channelID,f)
            % Get Peer Model Manager
            pmm = com.mathworks.peermodel.PeerModelManagers.getServerInstance(channelID);
            if ~(pmm.hasRoot())
                % First time creation
                pmm.setSyncEnabled(true);
                pmm.setRoot('DialogServiceRoot');
                
                % Configure performance settings for coalescing events
                synchronizer = com.mathworks.peermodel.PeerModelManagers.getPeerSynchronizer(channelID);
                % Set max and min to be the same low number @25ms.
                % This ensures fast client-sync for progress dialogs
                synchronizer.setCoalescerMaxDelay(25);
                synchronizer.setCoalescerMinDelay(25);
                
                % Setup listener for cleaning up Peer Model Manager
                addlistener(f,'ObjectBeingDestroyed',@(o,e)cleanupPeerModelManager(channelID));
            end
        end
    end
end


function handleViewReady(src, ~)
% Cleanup Dynamic prop and listeners
viewReadyListener = src.ViewReadyDispatcher.Listener;
dispatcherProp = findprop(src, 'ViewReadyDispatcher');
commandStack = src.ViewReadyDispatcher.CommandStack;
src.ViewReadyDispatcher = [];
delete(viewReadyListener);
delete(dispatcherProp);

% Execute the queued function handles
for k = 1:length(commandStack)
    functionToExecute = commandStack{k};
    functionToExecute();
end
end

function cleanupPeerModelManager (channel)
com.mathworks.peermodel.PeerModelManagers.cleanup(channel);
end
