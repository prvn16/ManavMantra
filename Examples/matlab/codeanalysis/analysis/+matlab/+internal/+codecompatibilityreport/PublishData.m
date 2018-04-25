classdef PublishData < handle
%PublishData Create a pub/sub client and publish data to a JS report
%   This class manages subscriptions to codeAnalysisRequest channel
%   and publishes on codeAnalysisResponse channel with the data from
%   the input CodeCompatibilityAnalysis object.

%   Copyright 2017 The MathWorks, Inc.
    properties (SetAccess = protected)
        subscription
        clientId
        ccaResults
    end
    methods
        function obj = PublishData(clientId, ccaResults)
        %An object of this class is not cleared while it's subscribed to
        %the set channel. It will continue to do so until it receives a
        %"stop" message from that channel, which will then unsubscribe
        % and clear the object.
            obj.clientId = clientId;
            obj.ccaResults = ccaResults;
            channel = ['/codeCompatibilityReport/', clientId, '/codeAnalysisRequest'];
            obj.subscription = message.subscribe(channel, @(msg) obj.handleRequest(msg));
        end

        function cleanup(obj)
            message.unsubscribe(obj.subscription);
        end

        function handleRequest(obj, msg)
            if strcmp(msg, 'start')
                obj.sendResults();
            elseif strcmp(msg, 'stop')
                obj.cleanup();
            end
        end

        function sendResults(obj)
            channel = ['/codeCompatibilityReport/', obj.clientId, '/codeAnalysisResponse'];
            message.publish(channel, obj.ccaResults);
        end
    end
end
