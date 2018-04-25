classdef TrimmedException < MException
    %TRIMMEDEXCEPTION MException that removes App Designer internal frames
    %
    % Copyright 2015-2017 The MathWorks, Inc.

    properties (Access = protected)
        OriginalException
    end

    methods
        function obj = TrimmedException(originalException)

            % Call MException constructor to setup the identifier and
            % message properties
            obj@MException(originalException.identifier, '%s', originalException.message);

            % Update the type to be the same as the input MException. This
            % needs to be done so that getReport() works properly.
            obj.type = originalException.type;

            % Update the cause field to be the same as the input MException
            % This needs to be done so that getReport() works properly.
            for i=1:length(originalException.cause)
                obj = addCause(obj,originalException.cause{i});
            end

            obj.OriginalException = originalException;
        end

        function report = getReport(obj, varargin)
            % STACK = GETREPORT(OBJ, VARARGIN) This method overrides the
            % inherited GETREPORT method from MException.

            % Before returning the report from MException, need to reset
            % the type to that of the original exception so that the report
            % message is correct. This is necessary because the type gets
            % modified when "throw" is executed (g1484207).
            obj.type = obj.OriginalException.type;
            report = getReport@MException(obj, varargin{:});
        end

    end

    methods (Access = protected)
        function stack = getStack(obj)
            % STACK = GETSTACK(OBJ) This method overrides the inherited
            % GETSTACK method from MException. It returns the original
            % stack. It is necessary to override this method so that the
            % method GETREPORT generates the correct message.

            stack = trimStack(obj, obj.OriginalException.stack);
        end

        function stack = trimStack(~, stack)
            % STACK = TRIMSTACK(OBJ, STACK) This method trims an
            % MException stack by removing frames that show the inner
            % workings of the callback handling which adds no value.

            appDesignerRoot = ...
                fullfile(matlabroot,'toolbox','matlab','appdesigner','appdesigner');

            % Find and remove all the frames that contain appdesigner MATLAB code
            hits = strfind({stack.file}, appDesignerRoot);
            hits = cellfun(@(c)~isempty(c), hits);
            stack(hits) = [];
            
            % Find and remove anonymous call to startupFcn
            % see g1602207
            anonyStartupFcnHit = cellfun(@(c)regexp(c, '^@\(app\)\w*\(app,\s*varargin{:}\)'), ...
                {stack.name}, 'UniformOutput', false);
            anonyStartupFcnHit = cellfun(@(c)~isempty(c), anonyStartupFcnHit);
            stack(anonyStartupFcnHit) = [];
        end
    end

    methods (Access = protected, Static)
        function cleanMessage = cleanMessageForClient(message)
            % removes html markup from the error message
            cleanMessage = regexprep(message, '<a.*?>(.*?)</a>', '$1');
        end
    end
end
