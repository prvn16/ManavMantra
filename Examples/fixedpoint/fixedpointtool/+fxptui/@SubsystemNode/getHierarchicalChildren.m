function children = getHierarchicalChildren(this)
% GETHIERARCHICALCHILDREN Gets the children in the hierarchy

% Copyright 2013 MathWorks, Inc

    children = [];
    if ~this.isValid
        return;
    end
    if(isempty(this.ChildrenMap) || this.ChildrenMap.getCount == 0)
        return;
    end
    me = fxptui.getexplorer;
    %unwrap the subsysnodes and add them to the output array
    idx = 1;
    for chIdx = 1:this.ChildrenMap.getCount
        % The map can be cleared in the process of the model being closed.
        % We need to make sure we can still index into the map in this
        % case.    
        if chIdx <= this.ChildrenMap.getCount
            thisChild  = this.ChildrenMap.getDataByIndex(chIdx);
            if isempty(thisChild); continue; end
            %G356323 make sure that any linked subsystems get refreshed if they were
            %lost during compile time. Don't do this during edit time because
            %Stateflow object removed events will cause this code to get hit with
            %handles of deleted objects and we don't want to deal with them
            
            %Sometimes, blocks from configurable sub systems go out of scope and it
            % is very difficult to detect it, causing ML crash. To avoid
            % this, add try catch block surrounding it.            
            try
                if(~isempty(me) && strcmp('running', me.status) && ~thisChild.isValid)
                    blk = get_param(thisChild.CachedFullName, 'Object');
                    thisChild.DAObject = blk;
                end
            catch
            end
            if ~thisChild.isValid
                % The block that this object was referring to was cleared from
                % memory and should no longer be reflected in the UI.
                % The key for the invalid entry is corrupted and we have no way of
                % removing just this entry from the HashMap. We have to do a copy
                % and restore this HashMap.
                childrenMapCopy = Simulink.sdi.Map(double(0),?handle);
                % Clear the property bag of the parent node
                for k = 1:this.ChildrenMap.getCount
                    childrenMapCopy.insert(this.ChildrenMap.getKeyByIndex(k), this.ChildrenMap.getDataByIndex(k));
                end
                this.ChildrenMap.Clear;
                for i = 1:childrenMapCopy.getCount
                    child = childrenMapCopy.getDataByIndex(i);
                    % restore the property bag of the parent
                    if child.isValid
                        this.ChildrenMap.insert(child.DAObject.Handle,child);
                    end
                end
                childrenMapCopy.Clear;
                unpopulate(thisChild);
                %update tree
                ed = DAStudio.EventDispatcher;
                %update tree
                ed.broadcastEvent('ChildRemovedEvent', this, thisChild);
                continue;
            end
            if(isempty(children))
                children = thisChild;
            else
                children(idx) = thisChild; %#ok <GROW>
            end
            idx = idx+1;
        end
    end
end
