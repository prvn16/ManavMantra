classdef ToUniqueFile < matlab.unittest.plugins.OutputStream
    %ToUniqueFile  Write text output to a unique file.
    %   ToUniqueFile is an OutputStream that sends text to a unique file for
    %   each instance of the class. When text is printed to this stream,
    %   ToUniqueFile opens the file, appends the text to the end of the file,
    %   and closes the file.
    %
    %   ToUniqueFile properties:
    %       Filename   - Full name of the file to write output
    %
    %   ToUniqueFile methods:
    %       ToUniqueFile - Create an output stream to a unique file
    %
    %   Examples:
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.TAPPlugin;
    %       import matlab.unittest.plugins.ToUniqueFile;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a test runner
    %       runner = TestRunner.withTextOutput;
    %
    %       % Create an instance of a stream to write to a unique file.
    %       stream = ToUniqueFile(pwd,'WithPrefix','myTapFile_','WithExtension','.tap');
    %
    %       % Create a TAPPlugin and direct output to the stream
    %       plugin = TAPPlugin.producingOriginalFormat(stream);
    %
    %       % Add the plugin to the TestRunner, and run the suite in parallel.
    %       runner.addPlugin(plugin);
    %       result = runner.runInParallel(suite);
    %
    %   See also: OutputStream, matlab.unittest.plugins

    
    %  Copyright 2017 The MathWorks, Inc.
    properties(SetAccess = immutable,GetAccess=private)
        %BaseFolder - Root folder that holds the file.
        %   The BaseFolder property contains the name of the folder that contains the
        %   output file.
        BaseFolder string
        
        %Prefix - Characters prepended to the name of the file.
        %   The Prefix property contains the text that appears at the beginning of
        %   the filename of the output file.
        Prefix string
        
        %Extension - File extension for the output file.
        %   The Extension property contains the output file extension.
        Extension string
    end
    
    properties (Hidden, Transient, Access = private)
        FilenameModifier string;
    end
    
    properties (Dependent, SetAccess=private)
        %Filename - Full name of the file to write output.
        %   The Filename property contains the name of the output file.
        Filename (1,1) string
    end
    
    methods
        function stream = ToUniqueFile(folder, varargin)
           %ToUniqueFile - Create an output stream to a unique file.
           %   STREAM = ToUniqueFile(FOLDER) creates an OutputStream that writes text
           %   output to a file in FOLDER. Each instance of ToUniqueFile creates a
           %   file with a unique filename.
           %
           %   STREAM = ToUniqueFile(...,'WithPrefix',PREFIX) creates a file with a
           %   name that starts with PREFIX. Specify PREFIX as a string scalar or a
           %   character vector.
           %
           %   STREAM = ToUniqueFile(...,'WithExtension',EXTENSION) creates a file
           %   with EXTENSION as the file extension. Specify EXTENSION as a string
           %   scalar or a character vector. EXTENSION must begin with a period (.).
            import matlab.unittest.internal.folderResolver;
            import matlab.unittest.internal.validatePathname;
            defaultPrefix = '';
            defaultExtension = '.txt';
            
            toUniqueFileParser = matlab.unittest.internal.strictInputParser;
            toUniqueFileParser.addParameter('WithPrefix',...
                defaultPrefix,@validatePrefix);
            toUniqueFileParser.addParameter('WithExtension',...
                defaultExtension,@validateExtension);
            toUniqueFileParser.parse(varargin{:});
            parserResults = toUniqueFileParser.Results;
            
            stream.BaseFolder = string(folderResolver(folder));
            
            stream.Prefix = string(parserResults.WithPrefix);
            stream.Extension = string(parserResults.WithExtension);
            
            validatePathname(stream.Filename);
        end
        
        function print(stream, formatStr, varargin)
            [fid, msg] = fopen(stream.Filename, 'a', 'n', 'UTF-8');
            assert(fid > 0, 'MATLAB:unittest:ToUniqueFile:OpenFailed', msg);
            cl = onCleanup(@() fclose(fid));
            fprintf(fid, formatStr, varargin{:});
        end
        
        function filename = get.Filename(stream)
            import matlab.unittest.internal.generateUUID;
            if isempty(stream.FilenameModifier)
                stream.FilenameModifier = generateUUID();
            end
            
            filename = string(fullfile(char(stream.BaseFolder), char(stream.Prefix + stream.FilenameModifier + stream.Extension)));
        end
    end
end

function validatePrefix(input)
validateattributes(input, {'char','string'}, {'nonempty','scalartext'},'','Prefix');
matlab.unittest.internal.validateNonemptyText(input);
ensureNoFileseps(input);
end

function validateExtension(input)
validateattributes(input, {'char','string'},{'scalartext'},'','Extension');
if strlength(input)==0
    return;
end
matlab.unittest.internal.validateNonemptyText(input);
input = string(input);
if ~input.startsWith('.')
    error(message('MATLAB:unittest:ToUniqueFile:ExtensionMustStartWithADot'));
end
ensureNoFileseps(input);
end

function ensureNoFileseps(input)
if contains(input,'/')
    error(message('MATLAB:unittest:ToUniqueFile:CharacterProhibited','/'));
elseif contains(input,'\')
    error(message('MATLAB:unittest:ToUniqueFile:CharacterProhibited','\'));
end
end
