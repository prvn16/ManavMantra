classdef ArrayDataModel < internal.matlab.variableeditor.DataModel & internal.matlab.variableeditor.EditableVariable
    %ARRAYDATAMODEL 
    %   Abstract Array Data Model.
    % This class contains all the common functionality for any tabular
    % data types.  Classes extending this class must provide the
    % getLHS method.

    % Copyright 2013-2016 The MathWorks, Inc.

    methods(Access='public')
        % getData
        % Gets a block of data.
        % If optional input parameters are startRow, endRow, startCol,
        % endCol then only a block of data will be fetched otherwise all of
        % the data will be returned.
        function varargout = getData(this,varargin)
            if nargin>=5 && ~isempty(this.Data)
                % Fetch a block of data using startrow, endrow, startcol,
                % endcol
                [startRow, endRow, startColumn, endColumn] = internal.matlab.variableeditor.FormatDataUtils.resolveRequestSizeWithObj(...
                    varargin{1}, varargin{2}, varargin{3}, varargin{4}, size(this.Data));
                varargout{1} = this.Data(startRow:endRow,startColumn:endColumn);
            else
                % Otherwise return all data
               varargout{1} = this.Data;
            end
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
        function varargout = setData(this,varargin)
            newValue = varargin{1};

            % Simple case, all of data replaced
            if nargin == 2
                setCommands{1} = sprintf(' = %s;', this.getRHS(newValue));
                varargout{1} = setCommands;
                return;
            end

            % Check for paired values
            if rem(nargin-1, 3)~=0
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
                setCommands{outputCounter} = sprintf('%s = %s;', lhs, this.getRHS(newValue));

                outputCounter = outputCounter+1;
            end
            
            varargout{1} = setCommands;
        end
        
        % getSize
        % Returns the size of the data
        function s = getSize(this)
            s = size(this.Data);
        end %getSize
        
        %getType
        % Returns the type of the data
        function type = getType(this)
            type = this.Type;
        end
        
        %getClassType
        % Returns the class of the data
        function type = getClassType(this)
            type = this.ClassType;
        end
        
        % Returns the right hand side of a formatted assignment string
        function rhs = getRHS(~, newValue)
            % Avoiding loss of precision by formatting to a large number of
            % decimal places
            rhs=num2str(newValue, '%20.20f');
        end
    end %methods
    
    methods(Access='protected',Abstract=true)
        lhs=getLHS(varargin);
    end
end

