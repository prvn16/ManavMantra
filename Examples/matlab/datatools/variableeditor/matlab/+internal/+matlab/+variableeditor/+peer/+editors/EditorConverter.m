classdef EditorConverter < handle
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Abstract EditorConverter class.  This class is extended to provide a
    % way to convert to and from server/client values.  Typical usage is
    % when creating the values to display on the client, or when setting a
    % value from the client.  For example
    %
    % c = SomeEditorConverter(); 
    % c.setServerValue(myObj.value); 
    % clientValue = c.getClientValue();
    
    % Copyright 2015 The MathWorks, Inc.
    
    methods(Abstract = true)
        
        % Called to set the server-side value
        setServerValue(this, value, dataType, propName);
        
        % Called to set the client-side value
        setClientValue(this, value);
        
        % Called to get the server-side representation of the value
        value = getServerValue(this);
        
        % Called to get the client-side representation of the value
        value = getClientValue(this);
        
        % Called to get the editor state, which contains properties
        % specific to the editor
        props = getEditorState(this);
        
        % Called to set the editor state, which are properties specific to
        % the editor
        setEditorState(this, props);
    end
end
