classdef (CaseInsensitiveProperties = true,ConstructOnLoad = true) fipref < hgsetget
%FIPREF  Class definition for EMBEDDED.FIPREF.
    
%   Copyright 2003-2016 The MathWorks, Inc.
    properties
        NumberDisplay              =  'RealWorldValue'   
        NumericTypeDisplay         =  'full'             
        FimathDisplay              =  'full'             
        LoggingMode                =  'Off'              
        DataTypeOverride           =  'ForceOff'         
        DataTypeOverrideAppliesTo  =  'AllNumericTypes'  
        LockDataTypeOverride       =  'Unlocked'         
    end % properties

    properties (Hidden)
        LogType = 'Assignment'; % Obsolete. Keep for backward compatibility.
    end % properties (Hidden)

    properties (Hidden,Dependent=true)
        Logging  % Obsolete. Replaced by LoggingMode. Keep for backward compatibility
    end % properties (Hidden,Dependent=true)
    
    properties (Access=private,Hidden,Constant)
        % Enumerated values for each property
        NumberDisplay_Values             = {'RealWorldValue','bin','dec','hex','int','none'};
        NumericTypeDisplay_Values        = {'full','none','short'};
        FimathDisplay_Values             = {'full','none'};
        LoggingMode_Values               = {'Off','On'};
        Logging_Values                   = {'Off','On'};
        DataTypeOverride_Values          = {'ForceOff','ScaledDoubles','TrueDoubles','TrueSingles'};
        DataTypeOverrideAppliesTo_Values = {'AllNumericTypes','Fixed-point','Floating-point'};
        LockDataTypeOverride_Values      = {'Unlocked','Locked'};
        LogType_Values                   = {'Assignment','Tag'};
     end % properties (Hidden,Constant)
    
    methods

        function self = fipref(varargin)
            % The persistent state is necessary because fipref is a
            % singleton object
            persistent FIPREF_PERSISTENT;
            if ~isempty(FIPREF_PERSISTENT) && isvalid(FIPREF_PERSISTENT)
                self = FIPREF_PERSISTENT;
            elseif ispref('embedded','fipref')
                % Use the one stored in the preferences file.
                thisstruct = struct(getpref('embedded','fipref'));
                set(self,thisstruct);
            end
            for i=1:nargin
                if isfipref(varargin{i})
                    varargin{i} = get(varargin{i});
                end
            end
            if nargin>1 || nargin==1 && isstruct(varargin{1})
                set(self,varargin{:});
            elseif nargin==1
                narginchk(2,inf);
            end
            FIPREF_PERSISTENT = self;
            mlock;
        end % fipref constructor

        function set.NumberDisplay(self,value)
            if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                % Use the one stored in the preferences file.
                if ispref('embedded','fipref')
                    thisstruct = struct(getpref('embedded','fipref'));
                    set(self,thisstruct);
                end
            end
            v = get_enumerated_value(self,'NumberDisplay',value);
            self.NumberDisplay = v;
        end % set.NumberDisplay

        function set.NumericTypeDisplay(self,value)
            if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                % Use the one stored in the preferences file.
                if ispref('embedded','fipref')
                    thisstruct = struct(getpref('embedded','fipref'));
                    set(self,thisstruct);
                end
            end
            v = get_enumerated_value(self,'NumericTypeDisplay',value);
            self.NumericTypeDisplay = v;
        end % set.NumericTypeDisplay

        function set.FimathDisplay(self,value)
            if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                % Use the one stored in the preferences file.
                if ispref('embedded','fipref')
                    thisstruct = struct(getpref('embedded','fipref'));
                    set(self,thisstruct);
                end
            end
            v = get_enumerated_value(self,'FimathDisplay',value);
            self.FimathDisplay = v;
        end % set.FimathDisplay

        function set.LoggingMode(self,value)
            if strcmpi(value,'OverflowAndUnderflow')
                value = 'On';
                warning(message('fixed:fipref:obsoleteLoggingMode'));
            end
            if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                % Use the one stored in the preferences file.
                if ispref('embedded','fipref')
                    thisstruct = struct(getpref('embedded','fipref'));
                    set(self,thisstruct);
                end
            end
            v = get_enumerated_value(self,'LoggingMode',value);
            self.LoggingMode = v;
            numerictype(); % To load the embedded package
            switch v
                case 'Off'
                    % Turn fi logging off (= false)
                    embedded.qlogger.SetLoggingMode(false);
                otherwise
                    % Turn fi logging on (= true)
                    embedded.qlogger.SetLoggingMode(true);
            end
        end % set.LoggingMode

        function set.Logging(self,value)
            if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                % Use the one stored in the preferences file.
                if ispref('embedded','fipref')
                    thisstruct = struct(getpref('embedded','fipref'));
                    set(self,thisstruct);
                end
            end
            self.LoggingMode = value;
        end  % set.Logging

        function value = get.Logging(self)
            if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                % Use the one stored in the preferences file.
                if ispref('embedded','fipref')
                    thisstruct = struct(getpref('embedded','fipref'));
                    set(self,thisstruct);
                end
            end
            value = self.LoggingMode;
        end  % set.Logging


        function set.DataTypeOverride(self,value)
            if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                % Use the one stored in the preferences file.
                if ispref('embedded','fipref')
                    thisstruct = struct(getpref('embedded','fipref'));
                    set(self,thisstruct);
                end
            end
            if strcmp(get(self,'LockDataTypeOverride'), 'Locked')
                error(message('fixed:fipref:attemptToChangeDTOWhileLocked'));
            end
            if strcmpi(value,'ScaledDouble')
                % For backward compatibility.  The shortened version was
                % accepted in the past.
                value = 'ScaledDoubles';
            end
            v = get_enumerated_value(self,'DataTypeOverride',value);
            self.DataTypeOverride = v;
        end % set.DataTypeOverride
        
        function set.DataTypeOverrideAppliesTo(self,value)
            if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                % Use the one stored in the preferences file.
                if ispref('embedded','fipref')
                    thisstruct = struct(getpref('embedded','fipref'));
                    set(self,thisstruct);
                end
            end
            if strcmp(get(self,'LockDataTypeOverride'), 'Locked')
                error(message('fixed:fipref:attemptToChangeDTOWhileLocked'));
            end
            v = get_enumerated_value(self,'DataTypeOverrideAppliesTo',value);
            self.DataTypeOverrideAppliesTo = v;
        end % set.DataTypeOverrideAppliesTo

        function set.LockDataTypeOverride(self,value)
            if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                % Use the one stored in the preferences file.
                if ispref('embedded','fipref')
                    thisstruct = struct(getpref('embedded','fipref'));
                    set(self,thisstruct);
                end
            end
            v = get_enumerated_value(self,'LockDataTypeOverride',value);
            self.LockDataTypeOverride = v;
        end % set.LockDataTypeOverride

        function set.LogType(self,value)
            if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                % Use the one stored in the preferences file.
                if ispref('embedded','fipref')
                    thisstruct = struct(getpref('embedded','fipref'));
                    set(self,thisstruct);
                end
            end
            v = get_enumerated_value(self,'LogType',value);
            self.LogType = v;
            numerictype(); % To load the package
            switch v
                case 'Assignment'
                    % Log sub-scripted assignment only A(k)=B
                    embedded.qlogger.SetLogType(0);
                case 'Tag'
                    % Log by Tags, and discriminate by Assignment, Product, Sum
                    embedded.qlogger.SetLogType(1);
            end
        end % set.LogType

        function v = get_enumerated_value(self,property_name,value)
            if ~isempty(value) && ischar(value)
                if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                    % Use the one stored in the preferences file.
                    if ispref('embedded','fipref')
                        thisstruct = struct(getpref('embedded','fipref'));
                        set(self,thisstruct);
                    end
                end
                allowable_values = self.([property_name,'_Values']);
                [t,k] = ismember(lower(value),lower(allowable_values));
                if t
                    v = allowable_values{k};
                else
                    error(message('MATLAB:class:InvalidEnumValue', value));
                end
            else
                error(message('MATLAB:class:MustBeNonEmptyString'));
            end
        end % get_enumerated_value

        function t = isfipref(~)
            t = true;
        end % isfipref

        function savefipref(self)
            if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                % Use the one stored in the preferences file.
                if ispref('embedded','fipref')
                    thisstruct = struct(getpref('embedded','fipref'));
                    set(self,thisstruct);
                end
            end
            s = rmfield(get(self),'DataTypeOverride');
            setpref('embedded','fipref',s);
        end % savefipref

        function disp(self)
            if ~isempty(self) && isvalid(self) && isa(self,'embedded.fipref')
                s = get(self);
                if isequal(self.DataTypeOverride,'ForceOff')
                    s = rmfield(s,'DataTypeOverrideAppliesTo');
                end
                s = rmfield(s,'LockDataTypeOverride');
                disp(s)
            elseif ispref('embedded','fipref')
                % Use the one stored in the preferences file.
                disp(struct(getpref('embedded','fipref')));
            end
        end % disp

        function reset(self)
            if ~isempty(self) && isvalid(self) && isa(self,'embedded.fipref')
                self.NumberDisplay             = 'RealWorldValue';
                self.NumericTypeDisplay        = 'full';
                self.FimathDisplay             = 'full';
                self.LoggingMode               = 'Off';
                self.DataTypeOverride          = 'ForceOff';
                self.DataTypeOverrideAppliesTo = 'AllNumericTypes';
                self.LockDataTypeOverride      = 'Unlocked';
            end
        end % reset

        function B = set(self, varargin)
            if isempty(self) || ~isvalid(self) || ~isa(self,'embedded.fipref')
                % Use the one stored in the preferences file.
                if ispref('embedded','fipref')
                    thisstruct = struct(getpref('embedded','fipref'));
                    self = fipref(thisstruct);
                end
            end
            % This overloaded SET calls set@hgsetget for everything but the forms
            % set(obj) and set(obj, 'property_name').
            if nargin == 1
                propNames = properties(self);
                for i = 1: length(propNames)
                    propName = propNames{i};
                    S.(propName) = self.([propName,'_Values']);
                end
                if nargout == 1
                    B = S;
                else
                    disp(S);
                end
            elseif nargin == 2 && ~isempty(varargin{1}) && ischar(varargin{1})
                propName = varargin{1};
                propNames = properties(self);
                % Add in obsolete properties for tab completion on values,
                % but don't tab-complete the property name itself.
                propNames = [propNames; {'LogType'}];
                [t,k] = ismember(lower(propName),lower(propNames));
                if t
                    AsgnVal = self.([propNames{k},'_Values']);
                    if nargout == 1
                        B = AsgnVal;
                    else
                        disp(AsgnVal)
                    end
                else
                    error(message('MATLAB:noSuchMethodOrField', varargin{1}, class(self)));
                end
            else
                set@hgsetget(self,varargin{:});
            end
        end % set

        function s = struct(self)
            if ~isempty(self) && isvalid(self) && isa(self,'embedded.fipref')
                s = get(self);
            elseif ispref('embedded','fipref')
                % Use the one stored in the preferences file.
                s = struct(getpref('embedded','fipref'));
            end
        end % struct

    end % methods
    
end % fipref
