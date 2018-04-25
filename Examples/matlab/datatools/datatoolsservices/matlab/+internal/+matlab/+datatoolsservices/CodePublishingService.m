classdef CodePublishingService < handle
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Internal class use for publishing code from the Data Tools UIs.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    properties
        channelMap string;
        codeArray string;
        codeGenListener;
    end
    
    methods(Static)
        % Get an instance of the Code Publishing Service
        function obj = getInstance(varargin)
            mlock;  % Keep persistent variables until MATLAB exits
            persistent docCodeGenInstance;
            if isempty(docCodeGenInstance) || ~isvalid(docCodeGenInstance)
                % Create a new Code Publishing Service
                docCodeGenInstance = internal.matlab.datatoolsservices.CodePublishingService;
            end
            obj = docCodeGenInstance;
        end
        
        % Convenience method to get a unique variable name for the
        % specified workspace.
        function varName = getUniqueVarName(varName, workspaceName)
            w = evalin(workspaceName, 'who');
            varName = matlab.lang.makeUniqueStrings(varName,  w);
        end
    end
    
    methods
        % Called to execute and publish code for the given channel.
        %
        % channel: used as the peer channel to publish to using the
        % Matlab pub/sub interface
        % code: the code to execute and publish
        % varargin: can optionally include an error callback function
        function publishCode(this, channel, code, varargin)
            if nargin == 4
                errorFcn = varargin{1};
            else
                errorFcn = [];
            end
            
            % Store the code and undo value
            this.addCode(string(channel), string(code));
            
            % Publish the code on the given channel if code
            % generation is enabled
            this.publishCodeOnChannel(channel, code, errorFcn);
        end
        
        % Called to buffer code for the given channel.
        %
        % channel: used as the peer channel to publish to using the
        % Matlab pub/sub interface
        % code: the code to store for later retrieval
        function bufferCode(this, channel, code)
            this.addCode(string(channel), string(code));
        end
        
        % Called to get the code for a given channel.
        function code = getCode(this, channel)
            idx = this.channelMap == channel;
            if any(idx)
                code = this.codeArray(:, idx);
                code(ismissing(code)) = [];
            else
                code = strings(0);
            end
        end
        
        % Called to discard the code for a given channel.  This is
        % called when the code will no longer be needed (for example,
        % when a variable is closed the code for it can be discarded)
        function discardCode(this, channel)
            idx = this.channelMap == channel;
            if any(idx)
                this.channelMap(:, idx) = [];
                this.codeArray(:, idx) = [];
            end
        end
    end
    
    methods(Access = protected)
        function this = CodePublishingService
        end
               
        % Stores code in an array, based on the channel and variable.
        function addCode(this, channel, code)
            idx = this.channelMap == channel;
            if isempty(idx) || ~any(idx)
                this.channelMap(end+1) = channel;
                idx = this.channelMap == channel;
            end
            
            if any(idx)
                for i=1:length(code)
                    this.codeArray(end+1, idx) = code(i);
                end
            end
        end
       
        % Creates a JSON string, and publishes the code to the client
        function publishCodeOnChannel(this, channel, code, errorFcn)
            msg.code = cellstr(code);
            if ~isempty(errorFcn)
                msg.errorFcn = char(errorFcn);
            end
            jsonTxt = mls.internal.toJSON(msg);
            this.publishMessage('/DataToolsCodePubChannel' + "/" + channel, jsonTxt);
        end
        
        % Publishes the code to the client
        function publishMessage(~, channel, text)
            message.publish(channel, text);
        end
    end
end
