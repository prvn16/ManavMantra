classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, ConstructOnLoad=true) DataModel < internal.matlab.variableeditor.Variable & internal.matlab.variableeditor.VariableObserver & internal.matlab.variableeditor.NamedVariable
    % An abstract class defining the methods for a Data Model
    % 

    % Copyright 2013 The MathWorks, Inc.

    events
       DataChange; % Fired when data has changed
    end
   
    % Public Abstract Methods
    methods(Access='public',Abstract=true)
        %getType
        type = getType(this);
        
        %getClassType
        type = getClassType(this);
    end

         
  
end %classdef
