%Copyright 2016-2017 The MathWorks, Inc. 
% Class to invoke CEF window from Rights Refresh call

classdef  OpenJITVRDCEFWindow < handle

    properties
        urlString='ui/install/jit_activation/jit_activation/index.html';
        debugPort = 0; %matlab.internal.getOpenPort;
        cefWidth = 550;  % As per current Spec
        cefHeight = 480; % As per current Spec
        instWin = [];
        win;
    end
  
    methods
%         function instanCEF(obj)
%             CEFObj = OpenJITVRDCEFWindow;
%             CEFObj.OpenCEFWindowfunc
%         end
        function  OpenCEFWindowFunc(obj)
            try
                cefPosition = getCefPosition(obj);
                connector.ensureServiceOn;
                com.mathworks.matlab_login.MatlabLogin.initializeLoginServices;
                com.mathworks.jit_activation.JITUtil.initializeJitServices;
                
                queryParams=[ '?matlabroot=' matlabroot, '&invokedfrom=' 'VRD' ];
                pageUrl = connector.getUrl([obj.urlString queryParams]);
                
                obj.win = matlab.internal.webwindow(pageUrl,obj.debugPort,cefPosition);
                obj.win.show;
            catch ME
            end
        end
        
        function closeCEF(obj)
            obj.win.close;
            close(obj.win);
        end
    end
    
    methods(Access = private)
        function cefPosition = getCefPosition(obj)
            set(0,'units','pixels');
            screensize = get(0,'screensize');
            width = screensize(3);
            height = screensize(4);
            center_x = width / 2;
            center_y = height / 2;
            
            cefXpos = center_x - (obj.cefWidth / 2);
            cefYpos = center_y - (obj.cefHeight / 2);
            cefPosition = [cefXpos, cefYpos, obj.cefWidth, obj.cefHeight];
        end
    end
end
