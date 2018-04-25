classdef SpreadsheetController < handle
% SPREADSHEETCONTROLLER Class definition to communicate with the web based spreadsheet in FPT
    
%   Copyright 2015-2017 The MathWorks, Inc.
    
    properties (Access = 'private')
        PublishAppendDataChannel = '/fpt/spreadSheet/fptSpreadSheetTable/appendData';
        PublishRowSelectInUI = '/fpt/spreadSheet/makeSelection';
        PublishProposedDTValidation = '/fpt/propdt/validate';
        Subscriptions
    end
    
    methods
        function this = SpreadsheetController(uniqueID)
            connector.ensureServiceOn;
            this.addUniqueIDToChannels(uniqueID);
        end        
    end
    
    methods (Hidden)        
        function varargout = invokeMethod(this,methodName,varargin)
            out = this.(methodName)(varargin{:});
            varargout{1} = out;
        end
               
        function updateSpreadsheet(this)
            msgObj = struct('data',[]);
            this.publishUpdateData(msgObj);            
        end
        
        function publishProposedDTValidity(this, validationResult)            
            message.publish(this.PublishProposedDTValidation, validationResult);
        end
        
        function unsubscribe(this)
            for i = 1:numel(this.Subscriptions)
                message.unsubscribe(this.Subscriptions{i});
            end
        end
        
        function delete(this)
            this.unsubscribe();
        end
              
        function selectResult(this, result, index)
            msgObj.uniqueID = result.ScopingId{1};
            msgObj.resultIndex = index;
            message.publish(this.PublishRowSelectInUI, msgObj);
        end        
    end
    
    methods(Access=private)
        function addUniqueIDToChannels(this, uniqueID)
            this.PublishAppendDataChannel = sprintf('%s/%s',this.PublishAppendDataChannel, uniqueID);
            this.PublishRowSelectInUI = sprintf('%s/%s',this.PublishRowSelectInUI, uniqueID);
            this.PublishProposedDTValidation = sprintf('%s/%s',this.PublishProposedDTValidation, uniqueID);
        end
        
        function publishUpdateData(this,msgObj)
            message.publish(this.PublishAppendDataChannel, msgObj);
        end                                               
    end
end
