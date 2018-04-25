classdef TAPTestFilePlugin < matlab.unittest.plugins.TAPPlugin
    
    % This class is undocumented and will change in a future release.
    
    % Copyright 2013-2017 The MathWorks, Inc.
    properties(Access= private)
        
        % The stall file is a file containing the last executed test class output.
        % In the case of a stall or other catastrophic failure this file contains
        % the output up to the failure point. It is also used to store the output
        % of normally running tests to place into the raw_output of the yaml
        % diagnostics. If it is supplied externally, it is retained. However, if it
        % is not it is deleted along with the plugin itself.
        StallFile
        DeleteStallFile = false;
        
        % An index into the suite of tests which points to the first leading test
        % for each test class or file.
        LeadingTestsIdx
        
        % Simple structure to hold onto data for each class.
        ClassData = struct;
        
        % The start of the class buffer. This retains knowledge of which class
        % output has been flushed to the output stream and which is not yet ready
        % (due to the presence of active shared test fixtures which can still fail
        % previously run classes)
        ClassBufferStart
        
        % The index through which test results have been finalized
        FinalizedResultIndex
    end
    properties(Dependent, Access=private)
        % Suite index of the currently running class.
        CurrentClassIndex
    end
    
    properties(Constant, GetAccess=private)
        Indentation = '  ';
    end
    
    properties(Access=private)
        RunTestSuitePluginData;
    end
    
    methods(Access={?matlab.unittest.plugins.TAPPlugin})
        function plugin = TAPTestFilePlugin(stallFile,varargin)
            plugin@matlab.unittest.plugins.TAPPlugin(varargin{:});
            
            
            if isempty(stallFile)
                stallFile = tempname;
                plugin.DeleteStallFile = true;
            end
            plugin.StallFile = stallFile;
        end
    end
    
    methods (Access=protected)
        
        function runTestSuite(plugin, pluginData)
            import matlab.unittest.internal.plugins.LinePrinter;
            plugin.Printer = LinePrinter(plugin.OutputStream);
            
            plugin.RunTestSuitePluginData = pluginData;
            
            plugin.ClassBufferStart = 1;
            plugin.FinalizedResultIndex = 0;
            
            % Find the leading tests
            plugin.LeadingTestsIdx = findLeadingTestsPerClass(pluginData.TestSuite);
            
            % Initialize class data to store information for each test class
            s = struct(...
                'RawOutput', '', ...
                'Timestamp', '');
            plugin.ClassData = repmat(s, size(plugin.LeadingTestsIdx));
            
            % Print the TAP Plan
            plugin.Printer.printLine(...
                sprintf('TAP version 13\n1..%d', numel(plugin.LeadingTestsIdx)));
            
            % Store the suite start time in the plan yaml
            yaml.datetime = timestamp;
            plugin.Printer.printLine(plugin.createYamlBlock(yaml));
            
            runTestSuite@matlab.unittest.plugins.TAPPlugin(plugin, pluginData);
            
            plugin.flushIfNeeded;
        end
        
        function runTestClass(plugin, pluginData)
            
            import matlab.unittest.internal.plugins.OutputLogger;
            
            stallFile = plugin.StallFile;
            clearFile(stallFile);
            logger = OutputLogger(stallFile);
            
            runTestClass@matlab.unittest.plugins.TAPPlugin(plugin, pluginData);
            
            % Capture the timestamp
            currentClassIdx = plugin.CurrentClassIndex;
            plugin.captureTimestampFor(currentClassIdx);
            
            % Stop logging and capture the output
            delete(logger);
            plugin.captureLogOutputFor(currentClassIdx);
            
            plugin.flushIfNeeded;
        end
        
        function teardownSharedTestFixture(plugin, pluginData)
            
            
            % Assign any timestamps that were unassigned due to skipped classes from
            % assumption or assertion failures. Work backwards until we find a class
            % with timestamp to determine how far to apply the current finish time.
            currentIdx = plugin.CurrentClassIndex;
            firstEmptyIdx = currentIdx;
            while firstEmptyIdx > 1 && isempty(plugin.ClassData(firstEmptyIdx).Timestamp)
                firstEmptyIdx = firstEmptyIdx - 1;
            end
            plugin.captureTimestampFor(firstEmptyIdx:currentIdx);
            
            teardownSharedTestFixture@matlab.unittest.plugins.TAPPlugin(plugin, pluginData);
            
            plugin.flushIfNeeded;
        end
        
        function reportFinalizedResult(plugin, pluginData)
            plugin.FinalizedResultIndex = plugin.FinalizedResultIndex + 1;
            reportFinalizedResult@matlab.unittest.plugins.TAPPlugin(plugin, pluginData);
        end
    end
    
    methods
        function idx = get.CurrentClassIndex(plugin)
            idx = find(plugin.LeadingTestsIdx <= plugin.RunTestSuitePluginData.CurrentIndex, ...
                1,'last');
        end
        function delete(plugin)
            if plugin.DeleteStallFile && exist(plugin.StallFile, 'file') == 2
                delete(plugin.StallFile);
            end
        end
    end
    
    
    methods(Access=private)
        function flushIfNeeded(plugin)
            % Find the classes to be flushed
            classBufferStart = plugin.ClassBufferStart;
            classBufferEnd = plugin.CurrentClassIndex;
            
            for classIdx = classBufferStart:classBufferEnd
                
                % Find the suite indices of this class to be flushed
                suiteBufferStart = plugin.LeadingTestsIdx(classIdx);
                suiteBufferEnd = plugin.findClassEnd(classIdx);
                
                % Send the result of the entire flushed class to the flush method.
                if suiteBufferEnd <= plugin.FinalizedResultIndex
                    result = plugin.RunTestSuitePluginData.TestResult(suiteBufferStart:suiteBufferEnd);
                    plugin.flush(result);
                end
            end
        end
        
        
        function captureLogOutputFor(plugin, idx)
            plugin.ClassData(idx).RawOutput = sanitize(fileread(plugin.StallFile));
        end
        
        function captureTimestampFor(plugin, idx)
            [plugin.ClassData(idx).Timestamp] = deal(timestamp);
        end
        
        function flush(plugin, result)
            
            idx = plugin.ClassBufferStart;
            
            % Print the core tap result
            leadingTest = plugin.RunTestSuitePluginData.TestSuite(plugin.LeadingTestsIdx(idx));
            plugin.printTAPResult(result, idx, leadingTest.TestParentName);
            
            % Print the diagnostics
            yaml.datetime = plugin.ClassData(idx).Timestamp;
            yaml.raw_output = plugin.ClassData(idx).RawOutput;
            plugin.Printer.printLine(plugin.createYamlBlock(yaml));
            
            % Increment the class buffer
            plugin.ClassBufferStart = plugin.ClassBufferStart + 1;
        end
        
        function classEnd = findClassEnd(plugin, classIdx)
            % Find the end of the class at a given index in "suite" units
            
            if classIdx < numel(plugin.LeadingTestsIdx)
                % The last element of the class is the index of the start of the next class
                % minus 1
                classEnd = plugin.LeadingTestsIdx(classIdx+1) - 1;
            else
                % If we are on the last class the end is just the end of the suite
                classEnd = numel(plugin.RunTestSuitePluginData.TestSuite);
            end
        end
        
        
        function str = createYamlBlock(plugin, yaml)
            % Turn a structure into a block of yaml text
            
            import matlab.unittest.internal.diagnostics.indent;
            
            indentation = plugin.Indentation;
            % Begin the yaml block
            str = sprintf('---\n');
            
            % Add yaml for each field
            fields = fieldnames(yaml);
            for idx = 1:numel(fields)
                yamlLabel = fields{idx}; % Fieldname is the label
                yamlValue = yaml.(yamlLabel); % Field value is the value
                if contains(yamlValue, newline)
                    % If the value has a newline add a pipe, newline, and extra indentation in
                    % order to denote pre-formatted yaml text
                    thisYamlField = sprintf('%s%s: |\n%s\n', indentation, ...
                        yamlLabel, indent(yamlValue, [indentation, indentation]));
                else
                    % Just include the indentation followed by "label: value"
                    thisYamlField = sprintf('%s%s: %s\n', indentation, ...
                        yamlLabel, yamlValue);
                end
                str = sprintf('%s%s', str, thisYamlField);
            end
            
            % End the yaml block
            str = sprintf('%s...', str);
            str = indent(str, indentation);
        end
        
        
        
    end
    
end

function ts = timestamp
ts = char(datetime('now','TimeZone','local','Format','yyyy-MM-dd HH:mm:ssZ'));
end


function clearFile(file)
fclose(fopen(file,'w'));
end


function charVector = sanitize(charVector)
charVector(~isAcceptableYAMLCharacter(charVector)) = []; % remove invalid characters
end

function tf = isAcceptableYAMLCharacter(c)
% Determine whether a character is an acceptable YAML characters as per the YAML spec:
% http://yaml.org/spec/1.1/#id868524

tf = (...
    c >= 32 & c <= 126 | ...  accept all printable ASCII characters, the space,
    c == 9 | ...  tab,
    c == 10 | c == 13 | c == 133 | c == 8232 | c == 8233 | ... line break,
    c >= 159 & isUnicodeCharacter(c)) ... and all Unicode characters beyond #x9F
    & ...
    ~isExcludedYAMLCharacter(c);
end

function tf = isExcludedYAMLCharacter(c)
tf = ...
    c >= 55296 & c <= 57343 | ... the surrogate block #xD800-#xDFFF
    c == 127 | ...  DEL #x7F,
    (c <= 31 & c ~= 9 & c ~= 10 & c ~= 13) | ... the C0 control block #x0-#x1F (except for #x9, #xA, and #xD)
    (c >= 128 & c <= 159 & c ~= 133)  | ...  the C1 control block #x80-#x9F (except for #x085)
    c == 65534 | ...  #xFFFE,
    c == 65535; % and #xFFFF.
end


function tf = isUnicodeCharacter(c) 
c = int32(c);
plane = idivide(c, 65536);
tf = ~(c >=64976 & c <= 65007) & (plane <= 16 & (bitand(c, 65534) ~= 65534));
end

function leadingTestsIdx = findLeadingTestsPerClass(suite)
if isempty(suite)
    leadingTestsIdx = [];
    return
end
boundaryMarkers = [suite.ClassBoundaryMarker];
leadingTestsMask = [true, boundaryMarkers(2:end) ~= boundaryMarkers(1:end-1)];
leadingTestsIdx = find(leadingTestsMask);

end

% LocalWords:  mypackage yaml datetime sok Fieldname yyyy THH
