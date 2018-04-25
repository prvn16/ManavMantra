classdef(Hidden) Measurable < matlab.unittest.internal.Measurable
    
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    methods(Sealed)
        function startMeasuring(measurable, label)
            % startMeasuring - Designate the start of a measurement boundary.
            %   The startMeasuring method provides a means for tests to denote the
            %   start of a measurement boundary. For example, invoking this method in
            %   conjunction with stopMeasuring allows a TimeExperiment to only include
            %   a portion of the test method in the time measurement. This allows setup,
            %   verification, and teardown code to be excluded from the time measurement.
            %
            %   startMeasuring(TESTCASE) designates the start of a measurement boundary.
            %   The startMeasuring method requires a subsequent call to stopMeasuring.
            %   The test will fail if called in an unsupported manner. Measurements
            %   from multiple boundaries in the same test method are accumulated and summed.
            %
            %   startMeasuring(TESTCASE, LABEL) designates the start of a measurement boundary
            %   and labels the measurement with LABEL. LABEL must be a valid variable name.
            %   The startMeasuring method requires a subsequent call to stopMeasuring
            %   with the same LABEL input. The test will fail if called in an unsupported
            %   manner. Measurements from multiple boundaries in the same test method and
            %   with the same label are accumulated and summed.
            %
            %   Example:
            %       classdef tfprintf < matlab.perftest.TestCase
            %           methods(Test)
            %               function testPrintingToFile(testCase)
            %
            %                   file = tempname;
            %                   fid = fopen(file, 'w');
            %                   testCase.assertNotEqual(fid, -1, 'IO Problem');
            %
            %                   stringToWrite = repmat('abcdef', 1, 1000000);
            %
            %                   testCase.startMeasuring();
            %                   fprintf(fid, '%s', stringToWrite);
            %                   testCase.stopMeasuring();
            %
            %                   testCase.verifyEqual(fileread(file), stringToWrite);
            %                   testCase.startMeasuring('filecleanup');
            %                   fclose(fid);
            %                   delete(file);
            %                   testCase.stopMeasuring('filecleanup');
            %               end
            %           end
            %       end
            %
            %   See also:
            %       stopMeasuring, matlab.perftest.TestCase, matlab.perftest.TimeExperiment
            
            import matlab.unittest.measurement.internal.validateLabel;
            
            % In case of no input or empty input
            if nargin < 2
                label = '_noLabel';
            else
                label = validateLabel(label,'startMeasuring');
            end
            
            measurable.notify('MeasurementStarted',...
                LabelEventData(label));
        end
        
        function stopMeasuring(measurable, label)
            % stopMeasuring - Designate the end of a measurement boundary.
            %   The stopMeasuring method provides a means for tests to denote the end
            %   of a measurement boundary. For example, invoking this method in
            %   conjunction with startMeasuring allows a TimeExperiment to only include
            %   a portion of the test method in the time measurement. This allows setup,
            %   verification, and teardown code to be excluded from the time measurement.
            %
            %   stopMeasuring(TESTCASE) designates the end of a measurement boundary.
            %   The stopMeasuring method requires a prior call to startMeasuring.
            %   The test will fail if called in an unsupported manner. Measurements
            %   from multiple boundaries in the same test method are accumulated and summed.
            %
            %   stopMeasuring(TESTCASE, LABEL) designates the end of a measurement boundary
            %   and labels the measurement with LABEL. LABEL must be a valid variable name.
            %   The stopMeasuring method requires a prior call to startMeasuring
            %   with the same LABEL input. The test will fail if called in an unsupported
            %   manner. Measurements from multiple boundaries in the same test method and
            %   with the same label are accumulated and summed.
            %
            %   Example:
            %       classdef tfprintf < matlab.perftest.TestCase
            %           methods(Test)
            %               function testPrintingToFile(testCase)
            %
            %                   file = tempname;
            %                   fid = fopen(file, 'w');
            %                   testCase.assertNotEqual(fid, -1, 'IO Problem');
            %
            %                   stringToWrite = repmat('abcdef', 1, 1000000);
            %
            %                   testCase.startMeasuring();
            %                   fprintf(fid, '%s', stringToWrite);
            %                   testCase.stopMeasuring();
            %
            %                   testCase.verifyEqual(fileread(file), stringToWrite);
            %                   testCase.startMeasuring('filecleanup');
            %                   fclose(fid);
            %                   delete(file);
            %                   testCase.stopMeasuring('filecleanup');
            %               end
            %           end
            %       end
            %
            %   See also:
            %       startMeasuring, matlab.perftest.TimeExperiment
            
            import matlab.unittest.measurement.internal.validateLabel;
            
            % In case of no input or empty input
            if nargin < 2
                label = '_noLabel';
            else
                label = validateLabel(label,'stopMeasuring');
            end
            
            measurable.notify('MeasurementStopped',...
                LabelEventData(label));
        end
    end
end

function evd = LabelEventData(varargin)
evd = matlab.unittest.internal.LabelEventData(varargin{:});
end