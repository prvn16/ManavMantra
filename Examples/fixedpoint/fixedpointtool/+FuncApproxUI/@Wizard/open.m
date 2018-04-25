function open(this, debugPort)
    % OPEN Opens Look-up Table Wizard window using the specified port.
    
    % Copyright 2017 The MathWorks, Inc.
    
    if nargin < 2
        debugPort = 0;
    end
    
    % g1664994 - Function Approximation app should prompt an appropriate error 
    % when launching the app in the absence of the Fixed-Point Designer license
    if ~fxptui.checkInstall
        msgTitle = FuncApproxUI.Utils.lookuptableMessage('fxpLicenseRequiredTitle');
        [msg, msgID] = FuncApproxUI.Utils.lookuptableMessage('fxpLicenseRequired');    
        errordlg(msg, msgTitle); 
        lutException = MException(msgID, msg);
        throwAsCaller(lutException);     
    end
  
    if isempty(this.WebWindow)
        this.createApplication(debugPort);
    else        
        if ~isequal(debugPort, this.WebWindow.getDebugPort)
            delete(this.WebWindow);
            this.createApplication(debugPort);
        end        
    end
    
    if isempty(this.MsgServiceInterface)
        this.setMsgServiceInterface(FuncApproxUI.FxpMsgServiceInterface);
    end
    
    if isempty(this.Subscriptions)
        this.Subscriptions{1} = this.MsgServiceInterface.subscribe('/lut/ready',@(data)this.initControllers(data));
    end
    
    this.show;
end

% LocalWords:  lut
