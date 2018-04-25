classdef MessageDiagnostic < matlab.unittest.diagnostics.Diagnostic
    % This class is undocumented and may change in a future release.
    
    % MessageDiagnostic - A message object diagnostic.
    %
    %   See also
    %       matlab.unittest.diagnostics.Diagnostic
    
    %  Copyright 2016 The MathWorks, Inc.
    properties(Hidden,SetAccess=private)
        Message
    end
    
    methods
        function diag = MessageDiagnostic(msgObjOrID,varargin)
            if isa(msgObjOrID,'message')
                narginchk(1,1);
                validateattributes(msgObjOrID,{'message'},{'scalar'});
                msgObj = msgObjOrID;
            else
                validateattributes(msgObjOrID,{'char'},{'row','nonempty'},1);
                msgObj = message(msgObjOrID,varargin{:});
            end
            
            diag.Message = msgObj;
        end
        
        function diagnose(diag)
            diag.DiagnosticText = getString(diag.Message);
        end
    end
end