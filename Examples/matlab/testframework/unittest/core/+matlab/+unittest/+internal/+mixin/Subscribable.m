classdef (Hidden) Subscribable < handle
    % This class is undocumented and may change in a future release.
    
    %   Copyright 2016 The MathWorks, Inc.
    
    events (NotifyAccess = private, ListenAccess = private)
        DataPublished
    end
    
    properties (Access = private)
        OpenChannels (1,:) string
    end
    
    methods (Hidden, Sealed)
        function publish(subscribable, transmittingChannel, customData)
            % publish - Publishes data on a given channel
            %
            %  publish(SUBSCRIBABLE, TRANSMITTINGCHANNEL, CUSTOMDATA) publishes
            %  CUSTOMDATA on the TRANSMITTINGCHANNEL. If there are any subscribers to
            %  the TRANSTMITTINGCHANNEL, then the CUSTOMDATA will be forwarded to the
            %  callback function that was subscribed to the channel.
            %
            %  Example:
            %
            %      % Create a TestCase for interactive use
            %      testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %      % Create some data to publish
            %      someData = timeseries(sin(0:0.1:pi), 0:0.1:pi);
            %
            %      % Publish the data on (previously) subscribed channel
            %      testCase.publish("TestChannel:TimeseriesData", someData);
            %
            %  See also
            %      subscribe
            %
            import matlab.unittest.internal.PublishableData
            
            validateChannel(transmittingChannel, "publish");
            if ismember(transmittingChannel, subscribable.OpenChannels)
                publishedData = PublishableData(transmittingChannel, customData);
                subscribable.notify('DataPublished', publishedData);
            end
        end
        
        function subscribe(subscribable, receivingChannel, customCallback)
            % subscribe - Subscribes a callback to be invoked when data is
            %   published on the subscribed channel
            %
            %   subscribe(SUBSCRIBABLE, RECEIVINGCHANNEL, CUSTOMCALLBACK) subscribes a
            %   CUSTOMCALLBACK function handle to the RECEIVINGCHANNEL. If any scalar
            %   custom data is published on RECEIVINGCHANNEL, the CUSTOMCALLBACK will
            %   be invoked with the published custom data.
            %
            %   Example:
            %
            %      % Create a TestCase for interactive use
            %      testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %      % Subscribe a function handle callback that accepts a
            %      % single data input with specific channel
            %      testCase.subscribe("TestChannel:TimeseriesData", @plot);
            %
            %   See also
            %       publish
            %
            validateChannel(receivingChannel, "subscribe");
            if ~ismember(receivingChannel, subscribable.OpenChannels)
                subscribable.OpenChannels = [subscribable.OpenChannels, receivingChannel];
            end
            
            subscribable.addlistener('DataPublished', @(src, evd)publishToChannel(src, evd, receivingChannel, customCallback));
        end
    end
    
    methods (Access = private)
        function publishToChannel(~, eventData, receivingChannel, customCallback)
            if eventData.Channel == receivingChannel
                customCallback(eventData.CustomData);
            end
        end
    end
end


function validateChannel(aChannel, fcnName)
validateattributes(aChannel, ["string", "char"], {"scalartext"}, fcnName);
end