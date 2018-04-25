classdef MLWorkspace < handle & JavaVisible
    %MLWorkspave MixIn class definition
    %   This class is used to create a workspace-like object that can work
    %   with the Variable Editor Framework

    % Copyright 2014-2015 The MathWorks, Inc.

    %%
    % Events
    %
    events
        VariablesAdded;
        VariablesRemoved;
        VariablesChanged;
    end
    
    %%
    %
    methods
        %%
        % Method: evalin
        % Input: cmd -- The command to be evaluated
        % Output: the result of the evaluation
        % Evaluates the command against the properties in the workspace.
        % This method attempts to add this. to any assignment statement or
        % evaluation statement.  If that fails it will just try to do an
        % evaluation of the cmd.
        %
        function varargout = evalin(this, cmd) %#ok<*INUSL>
            % Short circuit if this is a quoted string
            trimmedCommand = strtrim(cmd);
            if trimmedCommand(1) == '''' && trimmedCommand(end) == ''''
                varargout{1} = trimmedCommand;
                return;
            end
            
            % Also short circuit for logicals.  If not, a cmd of true or
            % false gets turned into a double, because logicals display as
            % 0 or 1 at the command line.
            if strcmp(trimmedCommand, 'true')
                varargout{1} = true;
                return;
            elseif strcmp(trimmedCommand, 'false')
                varargout{1} = false;
                return;
            end

            % If this is an assignment operation add this. to the beginning
            if ~isempty(strfind(trimmedCommand, '=')) && ...
                    ~isequal(strfind(trimmedCommand, '{'), 1)
                s = strsplit(trimmedCommand, '=');
                variable = s{1};
                value = strtrim(strrep(s{2},';',''));
                try
                    if ~strncmpi(value, 'this.', 5)
                        value = eval(['this.' value]); %#ok<*NASGU>
                    else
                        value = eval(value);
                    end
                catch
                    value = eval(value);
                end
                if ~strncmpi(variable, 'this.', 5)
                    eval(['this.' variable '=value;']);
                else
                    eval([variable '=value;']);
                end
                result = '';
            else
                % This is an evaluation statement so try to add this. to
                % the beginning and see if its a property of the workspace
                % otherwise the catch block will just evaluate the command.
                try
                    if ~strncmpi(trimmedCommand, 'this.', 5)
                        result = eval(['this.' trimmedCommand]);
                    else
                        result = eval(trimmedCommand);
                    end
                catch                  
                    currFormat = strtrim(strrep(evalc('disp(get(0, ''Format''))'), 'ans =', ''));
                    result = evalc(['format long; ' trimmedCommand]);
                    eval(['format ' currFormat]);
                end
            end
               
            if ischar(result)
                % Remove 'ans =' from the disp output if it exists
                result = strtrim(strrep(result,'ans =',''));
                
                % Does the output contain multiple lines?  It may if it is
                % split by columns, for example, starting with: 'Columns 1
                % through 5'. If this is the case, we need to remove those
                % headers as well.
                splitVal = strtrim(strsplit(result, '\n')');
                if ~isscalar(splitVal) || ~isequal(splitVal{1}, result)
                    % If the result contains multiple lines, check to see
                    % if the first line contains the text 'Columns N
                    % through M'.  First, check that there are two numbers
                    % in it.
                    colNums = regexp(splitVal{1}, '\d+', 'match');
                    if ~isempty(colNums) && length(colNums) == 2
                        % If there are two numbers, get the text used for
                        % disp to see if it matches the first line
                        colHeaderText = getString(message('MATLAB:services:printmat:Columns', ...
                            str2double(colNums{1}), str2double(colNums{2})));
                        if strcmp(splitVal{1}, colHeaderText)
                            % Remove every other line (which is 'Columns N
                            % through M', and join them back together.
                            splitVal(1:2:end) = [];
                            result = strjoin(splitVal);
                        end
                    end
                end
                [num, status] = str2num(result); %#ok<*ST2NM>
                if status==1
                    result = num;
                end
            end

            varargout{1} = result;
        end

        %%
        % Method: who
        % Input: none
        % Output: a cell array of strings (variable names)
        % Override this method so the workspace browser to knows what
        % variables should be displayed.
        %
        function variables = who(this) %#ok<*MANU>
            variables = {};
        end

        %%
        % Method: disp
        % Input: var -- The variable to disp
        % Output: The result of the disp
        % Calls disp on the variable passed in.  This is used in the
        % variable editor to get the correct formatting for a value. (i.e.
        % short, long, bank, etc).
        % 
        function output = disp(this, var) %#ok<*INUSD>
            if nargin < 2
                output = evalc('this.disp@handle');
                builtin('disp', this);
            else
                output = evalc('disp(var)');
            end
        end
        
        %%
        % Method: supportsPlotGallery
        % Output: Boolean indicating if the Plot Gallery should respond to
        % selection in the workspace
        %         
        function enabled = supportsPlotGallery(this)
            enabled = false;
        end
    end
end

