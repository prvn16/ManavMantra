function postUpdate(this)
%POSTUPDATE

%   Copyright 2015 The MathWorks, Inc.
      
hScope = this.Application;
            
sendEvent(hScope, 'VisualUpdated');
           
% [EOF] 
