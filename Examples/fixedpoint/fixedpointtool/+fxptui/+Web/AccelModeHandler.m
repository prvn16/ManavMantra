classdef AccelModeHandler < handle
% Handle accelerator mode on models when performing actions in FPT

% Copyright 2017 The MathWorks, Inc.

 properties (SetAccess = private, GetAccess = private)
     Models
     OriginalModeValues
 end
    
   methods
       function this = AccelModeHandler(topModel)
           if nargin < 1
               [msg, identifier] = fxptui.message('incorrectInputArgsModel');
               e = MException(identifier, msg);
               throwAsCaller(e);
           end
           try
               this.Models = find_mdlrefs(topModel);
           catch % Model not on path.              
               return;
           end
           for i = 1:numel(this.Models)
               this.OriginalModeValues{i} = get_param(this.Models{i},'SimulationMode');
           end
       end
       
       function switchToNormalMode(this)
           % Switch the models to Normal mode.
             settingValue(1:numel(this.Models)) = {'normal'};
             this.switchSimulationMode(settingValue);
       end
       
       function restoreSimulationMode(this)
           % Restore the simulation mode on the models.
           this.switchSimulationMode(this.OriginalModeValues);
       end
       
       function delete(this)
           this.Models = {};
           this.OriginalModeValues = {};
       end
   end
   
   methods (Access = private)
       function switchSimulationMode(this, settingValue)
           % Switch the models to the specified mode in settingValue
           origDirty(1:length(this.Models)) = {''};
           for i = 1:length(this.Models)
               origDirty{i} = get_param(this.Models{i}, 'dirty');
           end
           for i = 1:numel(this.Models)
               set_param(this.Models{i},'SimulationMode', settingValue{i});
           end
           for i = 1:numel(this.Models)
               if strcmp(origDirty{i}, 'off')
                   set_param(this.Models{i}, 'dirty','off')
               end
           end
       end
   end
end
