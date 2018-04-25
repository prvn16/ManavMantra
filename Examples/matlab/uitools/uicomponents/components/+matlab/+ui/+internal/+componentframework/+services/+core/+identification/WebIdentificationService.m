% WEBIDENTIFICATIONSERVICE This class provides the web-based service which 
% uniquely identies the web component.
classdef WebIdentificationService < handle

%   Copyright 2014-2017 The MathWorks, Inc.
    
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %
       %  Method:      perform
       %
       %  Description: Method which performs a web-based identification on a web
       %               component.  
       %   
       % Inputs :      peerNode -> Peer node information.     
       %
       % Outputs:      String which uniquely identifies the web component.
       %
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function id = perform( ~, view )
            id = char( view.PeerNode.getId );
       end
 

    end
    
end
