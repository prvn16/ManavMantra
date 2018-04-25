classdef MLDocument < internal.matlab.variableeditor.Document & internal.matlab.variableeditor.MLNamedVariableObserver
    %MLDocument  Summary of this class goes here
    %   Detailed explanation goes here

    % Copyright 2013-2016 The MathWorks, Inc.

    properties
        deletionListener=[];
        PreviousFormat = get(0,'format');
    end

    methods
        function this = MLDocument(manager, variable, userContext)
            this@internal.matlab.variableeditor.Document(manager, variable.DataModel, variable.ViewModel, userContext);
            this@internal.matlab.variableeditor.MLNamedVariableObserver(variable.getDataModel.Name, variable.getDataModel.Workspace);
            data = variable.DataModel.Data;
            try
                if isa(data, 'handle') && ~isempty(data) && ismethod(data, 'isvalid') && any(any(isvalid(data)))
                    this.addDeletionListener(data);
                end
            catch
            end
        end
        
        function data = variableChanged(this, varargin)
            % Check data type and see if we need to create new models
            newData = [];
            newSize = 0;
            newClass = '';
            if (nargin >= 1)
                newData = varargin{1};
            end
            if (nargin >= 2)
                newSize = varargin{2};
            end
            if (nargin >= 3)
                newClass = varargin{3};
            end
			
            % Check for type changes
            oldData = this.DataModel.Data;
            
            adapter = [];
            dimsChanged = false;
            if (isa(newData, 'internal.matlab.variableeditor.VariableEditorMixin'))
                if (~strcmp(class(this.DataModel),class(newData.getDataModel())) || ...
                    ~strcmp(class(this.ViewModel),class(newData.getViewModel())))
                 %Check to see if we have a new type of VariableEditorMixIn
                adapter = newData;
                end
            else
                % Check to see if either the number of dimensions (i.e. we've
                % changed from a scalar to a matrix or multidimensional array)
                % or if the type has changed
                % we need to check the class type of new data using the new adapter since in some cases
                % (like char arrays), class(newData) is not the same as newAdapter.getDataModel(this).getClassType()
                dimsChanged = this.isDimsChanged(this.DataModel.Data, ...
                    newData);
                isUnsupported = any(strcmp(this.DataModel.getClassType(), 'unsupported'));

                % get the new adapter class name(s), and make sure its a
                % cell array
                newAdapterClass = this.Manager.getVariableAdapterClassType(...
                    newClass, newSize, newData);
                if ~iscell(newAdapterClass) 
                    newAdapterClass = {newAdapterClass};
                end
                if dimsChanged || ...
                        ~ismember(class(this.DataModel.Data), newAdapterClass) || ...
                        isUnsupported
                    adapter = this.Manager.getVariableAdapter(...
                        this.Name, this.Workspace, newClass, ...
                        newSize, newData);
                elseif isobject(newData) && isa(newData, 'handle') && ...
                        all(size(newData) >= [1, 1]) && ...
                        ~any(any(isvalid(newData)))
                    adapter = this.Manager.getVariableAdapter(...
                        this.Name, this.Workspace, newClass, ...
                        newSize, newData);
                    
                    %add and remove deletion listeners as appropriate
                    this.checkDeletionListeners(newData, oldData);
                end
            end

            if ~isempty(adapter)
                classTypeChange = ~any(strcmp(this.DataModel.getClassType(), ...
                    adapter.getDataModel(this).getClassType()));
                dataChanged = ~internal.matlab.variableeditor.areVariablesEqual(...
                    this.DataModel.getData, adapter.getDataModel(this).getData);
            end

            % Fire a change event if there is a change in class type, or if
            % it is unsupported, but the data has changed
            if ~isempty(adapter) && ...
                    (((classTypeChange || dimsChanged) && ~this.IgnoreScopeChange) || ...
                    (isUnsupported && dataChanged))
                
                % We need to swap out the data and view models
                delete(this.ViewModel);
                delete(this.DataModel);
                this.removeDeletionListener();
                newDataModel = adapter.getDataModel(this);
                newViewModel = adapter.getViewModel(this);
                
                this.DataModel = newDataModel;
                this.ViewModel = newViewModel;
                
                % Fire DocumentTypeChanged Event
                eventdata = internal.matlab.variableeditor.DocumentChangeEventData;
                eventdata.Name = this.Name;
                eventdata.Workspace = this.Workspace;
                eventdata.Document = this;
                this.notify('DocumentTypeChanged', eventdata);
            else
                % If the global format has changed force a refresh
                % TODO: remove this once ViewModel level formatting is
                % implemented
                currFormat = get(0, 'format');
                if ~strcmp(this.PreviousFormat, currFormat)
                    ed = internal.matlab.variableeditor.DataChangeEventData;
                    % Force a refresh of the whole viewport with an arbitrary range, since having
                    % the range be more than one element will cause a
                    % refresh of the whole view            
                    ed.Range = {1:1000, 1:1000};                    
                    this.ViewModel.notify('DataChange', ed);
                    this.PreviousFormat = currFormat;
                end
            end

            data = this.DataModel.getData();
        end
        
        function delete(this)
            if ~isempty(this.Manager) && isvalid(this.Manager)
                this.Manager.closevar(this.Name, this.Workspace);
            end
        end
        
        function name = getVariableName(this)
            name = this.Name;
        end
        
        function ws = getVariableWorkspace(this)
            ws = this.Workspace;
        end
        
        function [] = checkDeletionListeners(this, newData, oldData)
            if isa(oldData, 'handle') && any(any(isvalid(oldData)))
                % old data is valid handle
                if ~isequaln(oldData, newData)
                    % and new data is not exact same handle then remove
                    % current listener on old object
                    this.removeDeletionListener();

                    if isa(newData, 'handle') && any(any(isvalid(newData)))
                        % and if new data is a valid handle then add new
                        % deletionlistener
                        this.addDeletionListener(newData);
                    end
                end
            else
                % old data is not a valid handle
                if isa(newData, 'handle') && any(any(isvalid(newData)))
                    % if new data is a valid handle then add new
                    % deletionlistener
                    this.addDeletionListener(newData);
                end
            end
        end
        
        function [] = addDeletionListener(this, obj)
            if ~isempty(this.deletionListener)
                this.removeDeletionListener();
            end
           
            this.deletionListener = event.listener(obj, 'ObjectBeingDestroyed', @this.deletionCallback);
        end
        
        function [] = removeDeletionListener(this)
            delete(this.deletionListener);
            this.deletionListener=[];
        end
        
        function [] = deletionCallback(this, varargin)
            data=this.DataModel.Data;
            
            %call the variableChanged function on same variable
            
            %if variable has been deleted, this will change the variable
            %type to unsupported and display the appropriate error message
            this.variableChanged(data, size(data), class(data));
        end
        
        function dimsChanged = isDimsChanged(~, oldData, newData)
            % dimsChanged is true if the dimensions of the data have
            % changed
            if istall(oldData) || istall(newData)
                % Special handling for tall variables.  The size of a tall
                % variable is a tall variable, so use the getArrayInfo to
                % try to compare sizes.
                if istall(oldData) && istall(newData)
                    oldTallInfo = matlab.bigdata.internal.util.getArrayInfo(oldData);
                    newTallInfo = matlab.bigdata.internal.util.getArrayInfo(newData);
                    dimsChanged = ~isequaln(oldTallInfo.Size, newTallInfo.Size);
                else
                    % The variable was tall and is no longer, or vice
                    % versa.  Consider this a dimension change.
                    dimsChanged = true;
                end
            else
                dimsChanged = ~isequal(length(size(oldData)),length(size(newData)));
                
                % in some cases (like structure arrays) the change in
                % dimensions is not represented in the length of the size of
                % data
                % explicitly check if scalar data has changed to vector and
                % vice versa
                if ~dimsChanged
                    oldDataScalar = isscalar(oldData);
                    newDataScalar = isscalar(newData);
                    isequalData = isequal(size(oldData), size(newData));
                    
                    if (oldDataScalar && ~newDataScalar) || (newDataScalar && ~oldDataScalar) ...
                            || (~isequalData)
                        dimsChanged = true;
                    end
                end
            end
        end
    end
end

