classdef (Hidden) FigureManagerObserver < handle
    %FIGUREMANAGEROBSERVER - keeps a track of the number of figures snapshoted on the server
    
    properties
        Status 
        FiguresOnServer
    end
    
    methods
        
        function obj = FigureManagerObserver
            obj.Status = false;
            obj.FiguresOnServer = 0;
        end
        
        function increment(obj)        
            obj.FiguresOnServer = obj.FiguresOnServer + 1;
            % Reset the Status (just in case it got flipped. E.g. animated lines)
            obj.Status = false;
        end
        
        function decrement(obj)        
            obj.FiguresOnServer = obj.FiguresOnServer - 1;   
            if obj.FiguresOnServer == 0
                obj.Status = true;
            end
        end        
        
    end
    
end

