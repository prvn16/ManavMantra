classdef SignalObjectResult < fxptds.AbstractSimulinkObjectResult
    % SIGNALOBJECTRESULT Class definition for result corresponding to a signal object
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods
        function this = SignalObjectResult(data)
            this@fxptds.AbstractSimulinkObjectResult(data);
        end
        
        function icon = getDisplayIcon(this)
            icon = '';
            if this.isResultValid
                icon = fullfile('toolbox','fixedpoint','fixedpointtool','resources',['SimulinkSignal' this.Alert '.png']);
            end
        end
        
        function b = isWithinProvidedScope(this, systemIdentifierObj)
            % Signal objects is within provided scope is complex compared to other
            % objects. Both clients are considered client blocks. Such a functional
            % requirement is unique to signal objects. Other data objects are used inside
            % a client. This functionality was considered useful for signal objects that
            % are on signal crossing a subsystem or model reference boundary.
            b = false;
            actSrcIDs = this.ActualSourceIDs;
            if isempty(actSrcIDs); return; end
            repository = fxptds.FPTRepository.getInstance;
            for idx = 1:length(actSrcIDs)
                % Get the results that have the same actual src of this result.
                if isValidAndNotWithoutGrapicalParent(this,actSrcIDs{idx})
                    % getSID call may error out if the object is in the
                    % process of being deleted.
                    mData = getAssociatedMetaData(this, actSrcIDs{idx},repository);
                    
                    if ~isempty(mData)
                        resultSet = mData.getResultSetForSource(actSrcIDs{idx});
                        resList = resultSet.values;
                        for i = 1:numel(resList)
                            res = resList{i};
                            if checkResultValidityforScope(this,res,actSrcIDs{idx})
                                b = res.isWithinProvidedScope(systemIdentifierObj);
                                if b; break; end
                            end
                        end
                        if b; break; end
                    end
                end
            end
        end
    end
    
    methods(Hidden)
        function blockList = getClientBlocks(this)
            % Call parent class method
            blockList = getClientBlocks@fxptds.AbstractSimulinkObjectResult(this);
            
            % Append more clients. A signal connects two clients. Both clients are
            % considered client blocks. Such a functional requirement is unique to signal
            % objects. Other data objects are used inside a client. This functionality was
            % considered useful for signal objects that are on signal crossing a subsystem
            % or model reference boundary.
            resultList = this.getConnectedResults;
            for iResult = 1:length(resultList)
                if ~isa(resultList(iResult),'fxptds.AbstractSimulinkObjectResult')
                    blockList = [blockList {resultList(iResult).getUniqueIdentifier.getObject}]; %#ok<AGROW>
                end
            end
        end
    end
    
    methods(Access = private)        
        function b = checkResultValidityforScope(~,res,~)
            b = ~isempty(res) && ...
                ~isa(res,'fxptds.AbstractSimulinkObjectResult') && ...
                fxptds.isResultValid(res);
        end
        
        function resList = getConnectedResults(this)
            resList = [];
            actSrcIDS = this.ActualSourceIDs;
            if isempty(actSrcIDS)
                return;
            end
            repository = fxptds.FPTRepository.getInstance;
            for idx = 1:length(actSrcIDS)
                % Get the results that have the same actual src of this result.
                if isValidAndNotWithoutGrapicalParent(this,actSrcIDS{idx})
                    mData = getAssociatedMetaData(this, actSrcIDS{idx},repository);
                    if ~isempty(mData)
                        resList = [resList mData.getResultListForSource(actSrcIDS{idx})]; %#ok <AGROW>
                    end
                end
            end
        end
        
        function metaData = getAssociatedMetaData(this,sourceID,repository)
            metaData = [];
            % getSID call may error out if the object is in the
            % process of being deleted.
            try
                if isa(sourceID, 'fxptds.MATLABVariableIdentifier')
                    sid = Simulink.ID.getSID(sourceID.getMATLABFunctionBlock);
                else
                    sid = Simulink.ID.getSID(sourceID.getObject);
                end
                model = Simulink.ID.getModel(sid);
                ds = repository.getDatasetForSource(model);
                runObj = ds.getRun(this.getRunName);
                metaData = runObj.getMetaData;
                if ~isa(metaData,'fxptds.AutoscalerMetaData')
                    metaData = [];
                end
            catch e %#ok<NASGU>
            end
        end
        
        function isValid = isValidAndNotWithoutGrapicalParent(~,ID)
            isValid = false;
            block = ID.getObject;
            if (isa(block,'DAStudio.Object') && ...
                    isempty(regexp(block.getFullName,'^built-in/','once'))) ||...
                    isa(block,'fxptds.MATLABVariableIdentifier')
                isValid = true ;
            end
        end
    end
end