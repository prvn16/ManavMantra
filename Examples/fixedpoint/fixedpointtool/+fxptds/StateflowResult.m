classdef StateflowResult < fxptds.AbstractSimulinkResult
% STATEFLOWRESULT Class definition for results corresponding to stateflow objects excluding charts

% Copyright 2013-2017 The MathWorks, Inc.

    properties(GetAccess = protected, SetAccess = protected)
        SFListeners
    end

    methods
        function this = StateflowResult(data)
        % Class should be able to instantiate with no input arguments
            if nargin == 0
                argList = {};
            else
                argList{1} = data;
            end
            this@fxptds.AbstractSimulinkResult(argList{:});
        end
        
        function icon = getDisplayIcon(this)
            icon = '';
            if ~this.isResultValid; return; end
            sfObj = this.getUniqueIdentifier.getObject;
            icon = sfObj.getDisplayIcon;
            if contains(icon,'truthtable')
                icon = strrep(icon,'truthtable','StateflowData');
            end
            %if we have no need to annotate this result return the default icon
            if(~this.isPlottable && isempty(this.Alert)); return; end
            idx = strfind(icon,filesep);
            if isempty(idx)
                idx = strfind(icon,'/');
            end
            %use the icon with blue antenna if this result has a signal
            if(this.isPlottable)
                filename = strrep(icon(idx(end)+1:end),'.png', ['Logged' this.Alert '.png']);
                icon = fullfile('toolbox','fixedpoint','fixedpointtool','resources',filename);
            else
                filename = strrep(icon(idx(end)+1:end),'.png', [this.Alert '.png']);
                icon = fullfile('toolbox','fixedpoint','fixedpointtool','resources',filename);  
            end
        end
        
        function [b, numOutputs] = hasOutput(~)
           b = false;
           numOutputs = [];
        end
      
        function setDerivedRangeState(this)
            hasinsufficientrange = this.hasInsufficientRange && this.hasDerivedMinMax;
            if(hasinsufficientrange)
                % Update the state to InsufficientRange
                this.DerivedRangeState = fxptds.DerivedRangeStates.InsufficientRange;
            else
                % Update the state to Default when no issues found
                this.DerivedRangeState = fxptds.DerivedRangeStates.Default;    
            end
        end
        
    end
    
    methods(Static)
        function obj = loadobj(this)
            obj = loadobj@fxptds.AbstractSimulinkResult(this);
        end 
    end
    methods
        function obj = saveobj(this) 
            obj = saveobj@fxptds.AbstractSimulinkResult(this);
            obj.SFListeners = []; 
        end 
    end
    
    methods(Hidden)
        function b = isReadonlyProperty(this, propName)
            b = true;
            
            if(strcmp('LogSignal', propName))
                return;
            end
            if this.IsViewOnlyEntry
                return;
            end
            if(this.hasProposedDT && (strcmpi('ProposedDT',propName) ...
                    ||strcmpi('Accept',propName))) || strcmpi('Run',propName)
                b = false;
            end
        end
        
        function ovMode = getOverflowMode(this)
            ovMode = 'wrap';
            chartObj = this.UniqueIdentifier.getChartObject;
            if ~isempty(chartObj)
                if chartObj.SaturateOnIntegerOverflow
                    ovMode = 'saturate';
                end
            end
        end
       % computeIfInheritanceReplaceable API verifies if a result is a
       % candidate for fixed point proposal on having an inheritance
       % rule as specified type. 
       % For Stateflow result, this API always set isInheritanceReplaceable
       % property to true only if the sfdata has local scope
        function computeIfInheritanceReplaceable(this)
            this.IsInheritanceReplaceable  = true;
            
            % for all results which interface with Simulink, this API will
            % return false.
            
            % i.e. When scope is input/output/Parameter/DataStoreMemory
            % SF Local Data does not interface with Simulink and hence API
            % returns true.
            if ~isempty(this.getUniqueIdentifier)
                sfData = this.getUniqueIdentifier.getObject;
                if ~isempty(sfData) && ( ~(strcmp(sfData.Scope, 'Local')) || ...
                        sfData.Props.ResolveToSignalObject)
                    this.IsInheritanceReplaceable  = false;
                end
            end
        end
        function subsystemId = getSubsystemId(this)
        % GETSUBSYSTEMID function constructs uses the uniqueIdentifier's
        % parent object and constructs subsystem identifier
            blkObj = this.UniqueIdentifier.getObject.getParent;
            subsystemIdentifier = fxptds.Utils.getSubsystemIdUsingBlkObj(blkObj, num2str(blkObj.Id));
            subsystemId = {subsystemIdentifier.UniqueKey};
        end
    end

end

% LocalWords:  truthtable
