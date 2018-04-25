classdef cpselectPoint < impoint
    % This undocumented class may be removed in a future release.

    %   Copyright 2007-2014 The MathWorks, Inc.
    
   properties (GetAccess = 'private',SetAccess = 'private')
      
       pairId
       drawAPI
       
   end
   
   methods
      
      %----------------------------------------------------------------
      function obj = cpselectPoint(h_parent,x,y,draw_api,constrainDrag)
          
          % Ideally would want to not pass in draw_api and just specify
          % cpPointSymbol here, but cpPointSymbol has private dependencies
          % that cannot be accessed from within +roipackage.
          obj = obj@impoint(h_parent,x,y,'DrawAPI',draw_api);
          obj.Deletable = false;
          
          obj.drawAPI = draw_api;
          
          obj.setPositionConstraintFcn(constrainDrag);
          obj.setColor('c');
              
      end
       
      %---------------------
      function setPairId(obj,id)
        obj.pairId = id;
        idString = mat2str(id);
        obj.setString(idString);

      end

      %---------------------------
      function id = getPairId(obj)
        id = obj.pairId;
      end
 
      %-------------------------------
      function setActive(obj,isActive)
        
        obj.drawAPI.showActiveDecoration(isActive);
        
      end

      %-------------------------------------
      function setPredicted(obj,isPredicted)
        
        obj.drawAPI.showPredictedDecoration(isPredicted);
        
      end
        
      %---------------------------------
      function addButtonDownFcn(obj,fcn)
         
          iptaddcallback(obj.h_group,'ButtonDownFcn',{fcn,obj});
          
      end
      
       
   end
       
end

% This is a workaround to g411666. Need pragma to allow ROIs to compile
% properly.
%#function impoint

