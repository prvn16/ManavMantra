classdef Dialog < handle
% This function is undocumented and will change in a future release
    
    % Copyright 2007-2012 The MathWorks, Inc.
    %ABSTRACTDIALOG Summary of this class goes here
    %   Detailed explanation goes here

    properties(GetAccess='protected',SetAccess='protected')
        Peer;
        WaitFlag;
    end
    
    properties(GetAccess='protected',SetAccess='protected',Transient=true)
        ParentFrame;
    end
    
    

    methods(Abstract=true,Access='public')
        show(obj)
    end
    
    methods(Access='protected')
        function setPeerTitle(~)
        end
    end

    methods
        function delete(obj)                       
            % Release the dialog owner
            if ishandle(obj.Peer)
                delete(obj.Peer);
            end
            
            % Release the system resources of the Parent Frame
            if ~isempty(obj.ParentFrame)
                javaMethodEDT('destroyParentWindow', 'com.mathworks.hg.peer.utils.DialogUtilities', obj.ParentFrame);
            end
        end
    end
    
    methods(Access='protected')
        % Get the parent frame.
        function parframe = getParentFrame(obj)
            if isempty(obj.ParentFrame)
               obj.ParentFrame = javaObjectEDT(com.mathworks.hg.peer.utils.DialogUtilities.createParentWindow);
            end                     
            parframe = obj.ParentFrame;
            assert(~isempty(parframe));    
        end
        
              
        function blockMATLAB(obj)
            obj.WaitFlag = handle(java.lang.Object);
            waitfor(obj.WaitFlag);
        end
        
        function unblockMATLAB(obj)
            delete(obj.WaitFlag);
            obj.WaitFlag = [];
        end
      
    end    
   
end
