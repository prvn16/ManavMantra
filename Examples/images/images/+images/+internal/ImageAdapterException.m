% This undocumented class may be removed in a future release.

%   Copyright 2009-2015 The MathWorks, Inc.

classdef ImageAdapterException < MException
    
    methods
        
        function obj = ImageAdapterException(method_name,class_name,diagnostic_string)
            
            % A reference to an instance of the class will remain in
            % "lasterror" until the next exception is thrown.  This will
            % prevent a clear classes unless we lock this file.
            mlock;
            errid = sprintf('images:AdapterDispatcher:%sError',method_name);
            errstr = getString(message( ...
                'images:ImageAdapterException:errorEncountered', ...
                method_name, class_name));
            
            if nargin == 3
                errstr = sprintf('%s  %s',errstr,diagnostic_string);
            end
            
            obj = obj@MException(errid,errstr);
            
        end % constructor
        
        function str = getReport(obj)
            
            str = getString(message('images:ImageAdapterException:causeOfError'));
            str = sprintf('%s\n\n%s\n\n%s',...
                obj.message,str,obj.cause{1}.getReport());
            
        end % getReport
        
    end % public methods
    
end % ImageAdapterException

