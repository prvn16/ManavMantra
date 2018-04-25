classdef(Abstract) TestCase < matlab.unittest.TestCase & matlab.unittest.measurement.internal.Measurable
% TestCase - TestCase intended for writing performance tests
%
%   The matlab.perftest.TestCase class is a class derived from
%   matlab.unittest.TestCase whose intent is to be used as part of
%   performance testing. By default, the time is measured around the test
%   method boundary, but the startMeasuring/stopMeasuring methods can be
%   used in the test in order to measure a finer granularity.
%
%   matlab.perftest.TestCase methods:
%       startMeasuring - Designate the start of timed test content.
%       stopMeasuring - Designate the end of timed test content.
%  
%   Examples:
%
%       % Example 1
%       % A test that compares a variety of different methods of
%       % preallocaton. The time is measured around the test method
%       % boundary.
%       classdef preallocationTest < matlab.perftest.TestCase
%             
%           methods(Test)
%  
%               function testOnes(testCase)
%                   x = ones(1,1e6); 
%               end
%  
%               function testIndexingWithVariable(testCase)
%                   id = 1:1e6; 
%                   x(id) = 1;
%               end
% 
%               function testIndexingOnLHS(testCase)
%                   x(1:1e6) = 1;
%               end
%
%               function testForLoop(testCase)
%                   for i=1:1e6
%                       x(i) = 1;
%                   end
%               end
%
%           end
%       end
%
%
%
%       % Example 2
%       % A test that defines a more granular measurement boundary
%       classdef fprintfTest < matlab.perftest.TestCase
%           methods(Test)
%               function testPrintingToFile(testCase)
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
%                   fclose(fid);
%               end
%           end
%       end
% 
%   See also: runperf, matlab.perftest.TimeExperiment.

% Copyright 2015 The MathWorks, Inc.
end