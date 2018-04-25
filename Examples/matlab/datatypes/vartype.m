classdef (Sealed) vartype < matlab.internal.tabular.private.subscripter
%VARTYPE Timetable variable subscripting by variable type.
%   S = VARTYPE(TYPE) creates a subscript to select table variables of a
%   specified type. TYPE is a character vector that specifies any type that is
%   accepted by the ISA function, such as 'numeric', 'float', 'integer', or
%   'string', and may also be 'cellstr'.
%
%   Examples:
%
%   % Select the numeric variables in a timetable.
%   tt = timetable(hours([1;2;3]),[4;5;6],{'seven';'eight';'nine'},[10;11;12])
%   vt = vartype('numeric')
%   ttNumeric = tt(:,vt)
%
%   See also ISA, TIMERANGE, WITHTOL.

%   Copyright 2016 The MathWorks, Inc.

    
    properties(Transient, Access='protected')
        type
    end
    
    methods
        function obj = vartype(type,~)
            % Add an extra unused input to allow the error handling to catch the common
            % mistake of passing in a time/table as an extra first input. Otherwise, the
            % front-end throws "Too many input arguments".)
            import matlab.internal.datatypes.isCharString
                                  
            if nargin == 0
                % No input constructor, type will be empty and vartype will not match anything
                obj.type = '';
                return
            end
            
            if matlab.internal.datatypes.istabular(type) % common error: vartype(tt,type)
                error(message('MATLAB:vartype:TabularInput'));
            elseif nargin > 1
                error(message('MATLAB:TooManyInputs')); % as if the extra dummy input wasn't there
            elseif ~isCharString(type)
                % Invalid type provided, must be a character vector
                error(message('MATLAB:vartype:InvalidType'));
            end
            
            obj.type = type;
        end
    end
    methods(Access={?withtol, ?timerange, ?vartype, ?matlab.internal.tabular.private.tabularDimension})
        % The getSubscripts method is called by table subscripting to find the indices
        % of the times (if any) along that dimension that fall between the specified
        % first and last time.
        function subs = getSubscripts(obj,subscripter,tData)
            try
                % Return the indices of variables that match the type
                dataWidth = size(tData,2);
                subs = false(1,dataWidth);
                if strcmp(obj.type,'cellstr')
                    for i = 1:dataWidth
                        subs(i) = iscellstr(tData{i});
                    end
                else
                    for i = 1:dataWidth
                        subs(i) = isa(tData{i}, obj.type);
                    end
                end
            catch ME
                if ~isa(subscripter,'matlab.internal.tabular.private.varNamesDim')
                    % Only variable subscripting is supported. VARTYPE is used in
                    % non-variable dimension if subscripter is not a varNamesDim
                    error(message('MATLAB:vartype:InvalidSubscripter'));
                else
                    rethrow(ME);
                end
            end
        end
    end
    methods(Hidden = true)
        function disp(obj)      
            % Take care of formatSpacing
            tab = sprintf('\t');
            if strcmp(matlab.internal.display.formatSpacing,'loose')
                newline = sprintf('\n');
            else
                newline = '';
            end
                       
            disp([tab getString(message('MATLAB:vartype:UIStringDispHeader')) newline]);
            disp([tab tab getString(message('MATLAB:vartype:UIStringDispType',char(obj.type))) newline]);
            disp([tab getString(message('MATLAB:vartype:UIStringDispFooter')) newline]);
        end
    end
    
    %%%% PERSISTENCE BLOCK ensures correct save/load across releases %%%%%%
    %%%% Properties and methods in this block maintain the exact class %%%%
    %%%% schema required for VARTYPE to persist through MATLAB releases %%%
    properties(Constant, Access='protected')
        % current running version. This is used only for managing forward
        % compatibility. Value is not saved when an instance is serialized
        %
        %   1.0 : 16b. first shipping version
        %   1.1 : 18a. added serialized field 'incompatibilityMsg' to support
        %              customizable 'kill-switch' warning message. The field
        %              is only consumed in loadobj() and does not translate
        %              into any table property
        version = 1.1;
    end
    
    methods(Hidden)
        function s = saveobj(obj)
            s = struct;
            s = obj.setCompatibleVersionLimit(s, 1.0); % limit minimum version compatible with a serialized instance            
            
            s.type = obj.type; % a single character vector. Contains an arbitrary type name
        end
    end
    
    methods(Hidden, Static)
        function obj = loadobj(s)
            % Always default construct an empty instance, and recreate a
            % proper vartype in the current schema using attributes
            % loaded from the serialized struct                
            obj = vartype();
            
            % Pre-18a (i.e. v1.0) saveobj did not save the versionSavedFrom
            % field. A missing field would indiciate it is serialized in
            % version 1.0 format. Append the field if it is not present.
            if ~isfield(s,'versionSavedFrom')
                s.versionSavedFrom = 1.0;
            end            
            
            % Return the empty instance if current version is below the
            % minimum compatible version of the serialized object
            if obj.isIncompatible(s,'MATLAB:vartype:IncompatibleLoad')
                return;
            end
            
            % Restore serialized data
            % ASSUMPTION: 1. type and semantics of the serialized struct
            %                fields are consistent as stated in saveobj above.
            %             2. as a result of #1, the values stored in the
            %                serialized struct fields are valid in this
            %                version of vartype, and can be assigned into
            %                the reconstructed object without any check
            obj.type = s.type;
        end
    end
end