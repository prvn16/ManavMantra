function childrenList = getDescendants(parent, childrenList)
    % Returns all the children of the object, including the
    % grand children, great grand children, etc.
    %
    % Copyright 2015 The MathWorks, Inc.
    
    if isvalid(parent)
        if nargin == 1
            childrenList = [];
        end

        % Add entry to childrenList
        childrenList = [childrenList, parent];

        if isprop(parent, 'Children')
            modelChildren = allchild(parent);

            % loop through children and add their children to the list
            for index = 1:numel(modelChildren)
                child = modelChildren(index);
                % Add grand children to the list with depth first
                % recursively
                
                % Do not get the sub-objects of UIAxes because
                % this is not a Container component
                if(strcmpi(class(child), 'matlab.ui.control.UIAxes'))
                    % Add UIAxes itself to childrenList
                    childrenList = [childrenList, child];
                else
                    % Child itself will be added into the list in the
                    % recursive calling
                    childrenList = appdesigner.internal.application.getDescendants(child, childrenList);
                end              
            end

        end
    end
end

