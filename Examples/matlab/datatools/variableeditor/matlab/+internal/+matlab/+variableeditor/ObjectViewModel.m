classdef ObjectViewModel < internal.matlab.variableeditor.StructureViewModel
    
    %OBJECTVIEWMODEL
    % Abstract Object View Model.  Extends the StructureViewModel, because
    % the view for both objects and structures is very similar.
    
    % Copyright 2013-2014 The MathWorks, Inc.
    
    properties (Hidden = true)
        % metaclass data is used to determine read-only properties
        metaclassData;
        
        % Deletion listener for the metaclassData.  This will be deleted
        % when the class information for this object is reloaded
        deletionListener = [];
    end
    
    methods (Access = public)
        % Constructor
        function this = ObjectViewModel(dataModel)
            this@internal.matlab.variableeditor.StructureViewModel(dataModel);
            
            % Initialize the metaclass information for later
            this.metaclassData = metaclass(this.getData());
            this.addDeletionListener();
        end
        
        % Destructor
        function delete(this)
            if ~isempty(this.deletionListener)
                this.removeDeletionListener();
            end
        end
    end
    
    methods (Access = protected)
        function isPublic = setAccessPublic(this, propertyName)
            % Returns true if the property has setAccess = public, and
            % false otherwise
            isPublic = [];
            if ~isempty(this.metaclassData)
                propList = this.metaclassData.PropertyList;
                prop = findobj(propList, 'Name', propertyName);
                if ~isempty(prop)
                    isPublic = isequal(prop.SetAccess, 'public');
                end
            end
            
            if isempty(isPublic)
                % assume false, but look for another way to find out if the
                % property is settable
                isPublic = false;
                currObj = this.getData();
                
                if ismember('findprop', methods(currObj))
                    % If findprop is defined for the object, use it to try
                    % to get the property
                    p = findprop(currObj, propertyName);
                    if ~isempty(p)
                        isPublic = isequal(p.SetAccess, 'public');
                    end
                else
                    % Check if the object has a set command which returns
                    % all of the settable properties.
                    try
                        propsList = set(currObj);
                        if ~isempty(propsList) && ...
                                any(ismember(fieldnames(propsList), propertyName))
                            isPublic = true;
                        end
                    catch
                    end
                end
            end
        end
    end
    
    methods(Access = protected)
        function [] = addDeletionListener(this)
            % Adds a deletion listener to the metaclass data.  This will be
            % destroyed if the class definition changes
            if ~isempty(this.deletionListener)
                this.removeDeletionListener();
            end
            
            this.deletionListener = event.listener(this.metaclassData, ...
                'ObjectBeingDestroyed', @this.deletionCallback);
        end
        
        function [] = removeDeletionListener(this)
            % Removes the deltion listener for the metaclass data
            delete(this.deletionListener);
            this.deletionListener = [];
        end
        
        function [] = deletionCallback(this, varargin)
            % if variable metadata has been deleted, this means that the
            % class definition has changed - a full redisplay is required
            this.metaclassData = metaclass(this.DataModel.Data);
            this.addDeletionListener();
            this.refresh([], struct('Range', []));
        end
      
        function fields = getFields(~, data)
            % Protected method to get the fields from the data.
            % Because objects reuse much of the structure code, they
            % override this method to call properties instead of
            % fieldnames.
            fields = properties(data);
        end
    end
end