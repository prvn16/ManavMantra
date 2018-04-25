classdef DurationArrayDataModel < internal.matlab.variableeditor.ArrayDataModel
    %DURATIONARRAYDATAMODEL 
    %   Duration Array Data Model

    % Copyright 2015 The MathWorks, Inc.
    
    % Type
    properties (Constant)
        % Type Property
        Type = 'DurationArray';
        
        % Class Type Property
        ClassType = 'duration';
    end %properties

    % Data
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=false, Hidden=false)
        % Data Property
        Data;
        Format;
        
    end %properties
    methods
        function storedValue = get.Data(this)
            storedValue = this.Data;
        end
        
        % Sets the data
        % Data must be a two dimensional duration array
        function set.Data(this, newValue)
            if ~isduration(newValue) || numel(size(newValue))~=2
                error(message('MATLAB:codetools:variableeditor:NotAnMxNDurationArray'));
            end
            this.Data = newValue;
            this.Format = newValue.Format; %#ok<MCSUP>
        end
        
        % setData - Sets a block of values.
        %
        % If only one paramter is specified that parameter is assumed to be
        % the data and all of the data is replaced by that value.
        %
        % Otherwise, the parameters must be in groups of three.  These
        % triplets must be in the form:  newValue, row column.
        %
        %  The return values from this method are the formatted command
        %  string to be executed to make the change in the variable.
        %
        % This may change in the future if there is a duration constructor
        % that accepts a string an input. In this case, the data passed to 
        % setData will be a string and the duration object can be directly
        % constructed from this string.
        function varargout = setData(this,varargin)
            newValue = varargin{1};

            % Simple case, all of data replaced
            if nargin == 2
                setCommands{1} = sprintf('=%s;',this.getRHS(newValue));
                varargout{1} = setCommands;
                return;
            end

            % Check for paired values
            if rem(nargin-1, 3)~=0,
                error(message('MATLAB:codetools:variableeditor:UseNameRowColTriplets'));
            end

            % Range(s) specified (value-range pairs)
            outputCounter = 1;
            setCommands = cell(1,round((nargin-1)/3));
            for i=3:3:nargin
                newValue = varargin{i-2};
                row = varargin{i-1};
                column = varargin{i};

                lhs = this.getLHS(sprintf('%d,%d',row,column));
                setCommands{outputCounter} = sprintf('%s=%s;',lhs,this.getRHS(newValue));

                outputCounter = outputCounter+1;
            end
            
            varargout{1} = setCommands;
        end
        
        % Returns the right hand side of a formatted assignment string
        %
        % This may change in the future if there is a duration constructor
        % that accepts a string an input. In this case, the data passed to 
        % getRHS will be a string and this function can just return 
        % 'duration(newValue)'.
        function rhs = getRHS(~, newValue)           
            [hour, minute, second] = hms(newValue);
            
            % Construct the right hand side of the assignment sprintf is
            % necessary to handle new lines and/or carriage returns.
            rhs = ['duration(', ...
                num2str(hour), ', ', ...
                num2str(minute), ', ', ...
                num2str(second), ', ', ...
                '''Format'', ''' newValue.Format, ''')' ...
            ];
        end
    end

    methods(Access='protected')
        % Returns the left hand side of an assigntment operation
        function lhs=getLHS(~,idx)
            lhs = sprintf('(%s)',idx);
        end
    end
end

