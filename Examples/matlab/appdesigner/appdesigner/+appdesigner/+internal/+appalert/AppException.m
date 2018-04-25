classdef AppException < appdesigner.internal.appalert.TrimmedException
    %APPEXCEPTION Captures App Designer app error information
    %   An AppException decorates the actual MException thrown by the app.
    %   It removes stack frames that are unnecessary and don't provide
    %   any value to the user
    
    % Copyright 2014 - 2017 The MathWorks, Inc.
    
    properties
        ErrorLineInApp
    end
    
    properties (Access = private)
        AppFullFileName
    end
    
    methods
        function obj = AppException(originalException, appFullFileName)
            
            % Call super constructor to setup the identifier and
            % message properties using the otherException
            obj@appdesigner.internal.appalert.TrimmedException(originalException);
            
            if(strcmpi(originalException.identifier, 'MATLAB:ui:uiaxes:general'))
                % UIAxes - specific
                % Replace the anchor tag with a different anchor tag
                % because the original anchor tag
                % is of the form
                % <a href="matlab:helpview('matlab/creating_guis/app-designer-graphics-support.html')">
                % but this does not work in CEF
                % Custom event handlers are wired on the client to look for
                % the CSS class thats specified here
                obj.message = regexprep(originalException.message, '<a.*?>', '<a href = "#" class = "ad-graphics-support-runtime-link">');
            else
                % Remove any anchor html tags from the MException message
                % This is primarily for syntax errors that break the class
                % code (it fails upon code parsing prior to executing). Do
                % not remove all html tags or tags that appear similar to
                % html tags becuase these could be errors related to char
                % content.
                
                % strip anchor tags from message and replace with its
                % content
                msg = obj.cleanMessageForClient(originalException.message);
                % escape remaining < and > to avoid conversion into a html
                % tag
                msg = regexprep(msg, '<', '&lt;');
                msg = regexprep(msg, '>', '&gt;');
                obj.message = msg;
            end
            
            obj.AppFullFileName = appFullFileName;
            
            obj.ErrorLineInApp = obj.getErrorLineInApp();
        end
    end
    
    methods (Access = protected)
        
        function stack = trimStack(obj, stack)
            % STACK = TRIMSTACK(OBJ, STACK) Overrides super method so that
            % it can also remove the first stack frame pertaining to the app
            
            % Find the first stack frames that pertain to the running
            % app and remove it.
            fileNames = {stack.file};
            hits = strcmp(obj.AppFullFileName, fileNames);
            firstIndex = find(hits,1,'first');
            stack(firstIndex) = [];
            
            % Use super method to remove all of the App Designer internal stack frames
            stack = trimStack@appdesigner.internal.appalert.TrimmedException(obj, stack);
        end
        
        function line = getErrorLineInApp(obj)
            % LINE = GETERRORLINEINAPP(OBJ) This method gets the line
            % number where the exception occurs/surfaces in the running
            % app's code.
            
            line = 1;
            stack = obj.OriginalException.stack;
            
            % if the exception is an app argument exception for too few
            % arguments the stack of the original exception will have the
            % line number for the error in its stack and not in the app
            % argument exception.
            if (strcmp(obj.OriginalException.identifier, 'MATLAB:appdesigner:appdesigner:TooFewAppArgumentsError'))
               stack = obj.OriginalException.cause{1}.stack;
            end
            
           
            % Finds the first non-truncated stack frame with the same file
            % path as this app
            for i=1:length(stack)
                fileName = stack(i).file;
                if strcmp(fileName, obj.AppFullFileName)
                    line = stack(i).line;
                    break
                end
            end
                
            % The error could be due to a failure in parsing the app's
            % code. In this case there is no stack information that
            % indicates where the parsing failure is in the app code.
            % However, the error message itself contains this info and so
            % it can be extracted out of the message.
            if line == 1
                % Parse out the line number by using a regular express and
                % tokening off the 'opentoline' hyperlink in the message.
                % For example:
                %
                %   Error: <a href="matlab:
                %   opentoline('C:\AppErrorExamples.mlapp',43,42)">File:
                %   AppErrorExamples.mlapp Line: 43 Column: 42 </a>...
                %
                [lineAndColumn,~] = regexp(obj.OriginalException.message,...
                    'opentoline\(.*\,(\d*),(\d*)\)','tokens','match');
                
                if ~isempty(lineAndColumn)
                    line = str2double(lineAndColumn{1}{1});
                end
            end
            
            % If for some reason the line number is negative (invalid),
            % return 1 (see g1447322);
            if line < 1
                line = 1;
            end
        end
    end
end

