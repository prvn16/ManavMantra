classdef IMToolExporter < matlabshared.scopes.tool.Tool
   %IMTOOLEXPORTER Class definition for IMToolExporter
   
   %    Copyright 2015-2017 The MathWorks, Inc.
   
   properties(Access=protected)
       IMTool = -1
       IMToolExporterButton
       IMToolExporterMenu
   end
   
   methods
       %Constructor
       function this = IMToolExporter(varargin)
           
           this@matlabshared.scopes.tool.Tool(varargin{:});
           
       end
   end
   
   methods(Access=protected)
       plugInGUI = createGUI(this)
       
       enableGUI(this, enabState)
       
       function lclExport(this)
           try
               export(this);
           catch ME
               uiscopes.errorHandler(ME.message);
           end
       end
   end
   
    methods(Static)
        propSet = getPropertySet
        
    end
end