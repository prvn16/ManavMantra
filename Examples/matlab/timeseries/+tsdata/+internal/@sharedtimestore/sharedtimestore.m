classdef (CaseInsensitiveProperties = true) sharedtimestore<handle
% This undocumented class may be removed in a future release.

    %   Copyright 2010-2011 The MathWorks, Inc.
    
    % This class is used to share time vectors among multiple timeseries.
    
       properties (GetAccess = private, SetAccess = private)       
           Time = [];
       end
       
       methods    
           function this = sharedtimestore(varargin)
               if nargin>=1
                   this.Time = varargin{1};
               end
           end
           
           function outData = getTime(this)
               outData = this.Time;
           end
           function setTime(this,data)
               this.Time = data;
           end           
           
           % Overridden array methods
           function len = length(this)
               len = length(this.Time);
           end
           function s = size(this)
               s = [length(this.Time) 1];
           end
           function state = isempty(this)
               state = isempty(this.Time);
           end  
           function horzcat(varargin)
               error(message('MATLAB:tsdata:internal:sharedtimestore:horzcat:noArrayCreated'))
           end
           function vertcat(varargin)
               error(message('MATLAB:tsdata:internal:sharedtimestore:vertcat:noArrayCreated'))
           end
       end
       
end