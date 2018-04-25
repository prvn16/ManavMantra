classdef SubplotDeleteListenersManager < handle
% This class is undocumented and will change in a future release
   
%SubplotDeleteListenersManager keeps the SubplotDeleteListener as transient properties
%So that listeners are not saved during hgsave.  
    
%   Copyright 2010-2013 The MathWorks, Inc.

    properties(Transient)
        SubplotDeleteListener
    end
	
    methods
	
        function obj = SubplotDeleteListenersManager()
           % CTOR needs to do nothing
        end
  
        % This function will be called addToListeners@SubplotListenersManager during load
        function addToListeners(obj,ax)
            p = 'ObjectBeingDestroyed';
            f = @(o,e) matlab.graphics.internal.axesDestroyed(o, e);
            obj.SubplotDeleteListener = event.listener(ax,p,f);
        end     
		
    end
	
	
end
        
        