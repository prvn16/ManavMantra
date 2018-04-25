classdef PeerPopoutHandler < dynamicprops
    % Copyright 2017 The MathWorks, Inc.
    
    %PEERPOPOUTHANDLER Sets up the parameters required to create a CEF
    % Window in desktop. This handler ensures that a channel and docID 
    % are passed in as required parameters to be able to construct the URL. 
    % Also keeps track of docID's by hashing and does not allow the duplicate 
    % creation of popouts for a given docID.    
    
    properties (Access='protected')       
		popoutHandlerList = containers.Map;  
    end
    
    properties
        url;
        createNewWindow = false;
        ID;
        groupID;
    end  
    
    methods
        % Initializes the peerPopoutHandler. The variable list of arguments
        % are name-value pairs and dynamically added as class properties.
        % If docID or channel is not specified, this class errors as they
        % are essential to construct Query parameters for the URL.
        function this = PeerPopoutHandler(varargin)            
            if (nargin >0)
                for i=1:2:length(varargin)
                    propname = varargin{i};
                    propVal = varargin{i+1};
                    addprop(this, propname);
                    this.(propname) = propVal;
                end
                if ~isprop(this, 'docID') || ~isprop(this, 'channel')                    
                    error(message('MATLAB:codetools:datatoolsservices:RequiredParamsUnspecified'));
                end                 
                this.setupPopoutParams();
            end
        end
        
        % This method constructs the 'url' required for showing the CEF
        % window. The url construction takes place only when a window does
        % not exist for the given docID. If it does, the createNewWindow is
        % set to false signalling the dialogHandler to bring the existing
        % window to the front.
        function setupPopoutParams(this) 
            this.ID = this.docID;
            % Group all popouts belonging to a particular channel by
            % assinging a groupID. (This is convenient for cleanup)
            this.groupID = this.channel;
            if ~(isKey(this.popoutHandlerList,this.ID))                
                try                   
                    % Construct URL for CEF                                        
                    urlForCef = connector.getUrl(this.getUrl);
                    this.url = sprintf('%s&channel=%s&docId=%s',urlForCef,this.channel,this.docID);                                                            
                    this.createNewWindow = true;
                    this.popoutHandlerList(this.ID) = this.ID;
                catch e
                    error(e.message);
                end                            
            else                
                this.createNewWindow = false;
            end 
        end 
        
        % Close method handles removing the hashed docID. 
        function close(this)                        
            if (isKey(this.popoutHandlerList,this.ID))
                remove(this.popoutHandlerList, this.ID);
            end
        end        
    end    
    
    methods(Static)
        function url = getUrl(~)
            url = '';
        end        
    end
end

