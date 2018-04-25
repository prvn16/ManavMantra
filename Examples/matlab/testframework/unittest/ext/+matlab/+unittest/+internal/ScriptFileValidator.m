classdef ScriptFileValidator
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(Constant, Access=private)
        CreateScriptFileValidationFcnInputParser = createParserForCreateScriptFileValidationFcn();
        ValidateScriptFileInputParser = createParserForValidateScriptFileInput();
    end
    
    methods(Static)
        function fcn = createScriptFileValidationFcn(fileName, varargin)
            import matlab.unittest.internal.ScriptFileValidator;
            import matlab.unittest.internal.getParentNameFromFilename;
            import matlab.unittest.internal.ContentWrapper;
            
            scriptName = getParentNameFromFilename(fileName);
            args = {scriptName};
            
            parser = ScriptFileValidator.CreateScriptFileValidationFcnInputParser;
            parser.parse(varargin{:});
            input = parser.Results;
            
            if input.WithExtension
                args = [args, {'Extension', getExtension(fileName)}];
            end
            
            if input.WithCode
                %Code is wrapped with a ContentWrapper to save storage if
                %the function handle is distributed to multiple locations.
                args = [args, {'Code', ContentWrapper(getCode(fileName))}];
            end
            
            if input.WithLastModifiedMetaData
                args = [args, {'LastModifiedMetaData', getLastModifiedMetaData(fileName)}];
            end
            
            
            % Although these are not being used right now, we might want to
            % use these in the future if we decide to stop using WithCode
            % with m scripts.
            if input.WithDatenum
                args = [args, {'Datenum', getDatenum(fileName)}];
            end
            if input.WithBytes
                args = [args, {'Bytes', getBytes(fileName)}];
            end
            if input.WithChecksum && usejava('jvm')
                args = [args, {'Checksum', getChecksum(fileName)}];
            end
            
            fcn = @() matlab.unittest.internal.ScriptFileValidator.validateScriptFile(args{:});
        end
        
        function validateScriptFile(scriptName,varargin)
            % validateScriptFile - Validate script file based on given properties
            %
            % Calls to this function are stored as function handles inside
            % of ScriptTestCaseProvider as of R2016b. Therefore, altering this
            % function may affect R2016b (or later) saved test suites.
            import matlab.unittest.internal.ScriptFileValidator;
            
            fileName = matlab.unittest.internal.whichFile(scriptName);
            if isempty(fileName)
                error(message('MATLAB:unittest:TestSuite:ScriptFileNotFound', scriptName));
            end
            
            parser = ScriptFileValidator.ValidateScriptFileInputParser;
            parser.parse(varargin{:});
            input = parser.Results;
            
            if wasProvided(parser,'Extension') && ~strcmpi(getExtension(fileName),input.Extension)
                error(message('MATLAB:unittest:TestSuite:ScriptFileExtensionChanged', ...
                    scriptName, input.Extension, getExtension(fileName)));
            end
            
            if wasProvided(parser,'Code') && ~strcmp(getCode(fileName),input.Code.Content)
                throwContentChangedError(scriptName);
            end
            
            if wasProvided(parser,'LastModifiedMetaData') && ...
                    ~isequal(getLastModifiedMetaData(fileName),input.LastModifiedMetaData)
                throwContentChangedError(scriptName);
            end
            
            if wasProvided(parser,'Datenum') && ~isequal(getDatenum(fileName),input.Datenum)
                throwContentChangedError(scriptName);
            end
            if wasProvided(parser,'Bytes') && ~isequal(getBytes(fileName),input.Bytes)
                throwContentChangedError(scriptName);
            end
            if wasProvided(parser,'Checksum') && usejava('jvm') && ~strcmp(getChecksum(fileName),input.Checksum)
                throwContentChangedError(scriptName);
            end
        end
    end
end

function throwContentChangedError(scriptName)
error(message('MATLAB:unittest:TestSuite:ScriptContentChanged', scriptName));
end

function parser = createParserForCreateScriptFileValidationFcn()
parser = inputParser();
parser.addParameter('WithExtension',false);
parser.addParameter('WithCode',false);
parser.addParameter('WithLastModifiedMetaData',false);

parser.addParameter('WithDatenum',false);
parser.addParameter('WithBytes',false);
parser.addParameter('WithChecksum',false);
end

function parser = createParserForValidateScriptFileInput()
parser = inputParser();
parser.addParameter('Extension',[]);
parser.addParameter('Code',[]);
parser.addParameter('LastModifiedMetaData',false);

parser.addParameter('Datenum',[]);
parser.addParameter('Bytes',[]);
parser.addParameter('Checksum',[]);
end

function ext = getExtension(fileName)
[~,~,ext] = fileparts(fileName);
end

function code = getCode(fileName)
code = matlab.internal.getCode(fileName);
end

function lastModified = getLastModifiedMetaData(fileName)
fileModel = matlab.internal.livecode.FileModel.fromFile(fileName);
lastModified = fileModel.LastModified;
end

function datenum = getDatenum(fileName)
dirInfo = dir(fileName);
datenum = dirInfo.datenum;
end

function bytes = getBytes(fileName)
dirInfo = dir(fileName);
bytes = dirInfo.bytes;
end

function txt = getChecksum(fileName)
checksum = com.mathworks.comparisons.util.LocalIOUtils.getFileChecksum(fileName);
txt = reshape(upper(dec2hex(typecast(checksum, 'uint8'))),1,[]);
end

function bool = wasProvided(parser, parameterName)
bool = ~ismember(parameterName,parser.UsingDefaults);
end