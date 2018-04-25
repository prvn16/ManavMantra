function varargout = NumericTypeScope(varargin)
%NumericTypeScope Determines fixed-point data type
%   The NumericTypeScope suggests a fixed-point data type based on the
%   dynamic range of the input data and the criteria you specify.
%
%   The scope allows you to visualize the dynamic range of data in the form
%   of a log2 histogram. It displays the absolute values of data on the
%   X-axis and the number or percentage of occurrences on the Y-axis. Each
%   bin in the histogram corresponds to a bit in a word. For example: 2^0
%   corresponds to the first integer bit in a word; 2^-1 corresponds to the
%   first fractional bit in a word. The height of the bar on the zeroth bit
%   indicates the number or percentage of cases where the input value is in
%   the range 0.5 < value <= 1.
% 
%   The scope suggests a data type in the form of a numerictype object that
%   satisfies the specified criteria. The Bit Allocation panel of the scope
%   allows you to specify data type criteria in many different ways. For
%   example, you can specify a known word length and the desired maximum
%   occurrences outside range or specify the desired number of occurrences
%   outside range and the smallest value that has to be represented by the
%   suggested data type. For streaming data, the suggested numerictype
%   object adjusts over time in order to continue to satisfy the specified
%   criteria. 
%
%   The scope also allows you to interact with the histogram plot. By
%   selecting the 'Graphical control' checkbox on the Bit Allocation panel,
%   you can enable cursors on either side of the binary point. You can
%   interact with these cursors and observe the impact of the suggested
%   numerictype on the input data. For example: you can see the number of
%   values that are outside range and/or below precision, representable
%   minimum and maximum values of the data type.  
%  
%   Command line syntax:
%
%   H = NumericTypeScope returns a numerictype scope object that
%   can be used to view the dynamic range of changing data in MATLAB.
%  
%   Step method syntax:
%
%   step(H, data) process data and visualize the dynamic range. The object
%   retains previously collected information on the variable between each
%   call to the step method. 
%  
%   Note:  The object will be reset automatically before processing data if
%   the data type or size of the input data changes between calls to the
%   step method.
%
%   NumericTypeScope methods:
%
%   step  - See above description for use of this method. 
%   reset - Clear the stored information from the object. Resetting the
%           object clears the information from the visual immediately. Use
%           this method to clear the stored information in the object if
%           you wish to reuse the existing object to process data from a
%           different variable.
%   show  - Turn on visibility of scope figure
%   hide  - Turn off visibility of scope figure
%
%   Data type support:
%  
%   double, single, int8, int16, int32, int64, uint8, uint16, uint32,
%   uint64, fi.
% 
%   % Example 1:
%      % View the dynamic range of a variable that is changing inside a
%      % loop and arrive at a data type for the accumulator.
% 
%      % Turn on data type override to capture the true range in floating
%      % point. 
%      fp = fipref;
%      initialDTOSetting = fp.DataTypeOverride;
%      fp.DataTypeOverride = 'TrueDoubles';
%      a = fi(sin(0:100)*3.5,1,8,7); 
%      b = fi(cos(0:100)*1.75,1,8,7); 
%      h = NumericTypeScope; 
%      for i = 1:length(a)
%        acc = a(i)*0.7 + b(i); 
%        step(h,acc); 
%        y(i) = acc;
%      end
%     % Reset the original setting of data type Override.
%     fp.DataTypeOverride = initialDTOSetting;
%
%     % You can see that with the suggested data type, there are no data
%     % values outside range or below precision. By default, the scope uses
%     % a word length of 16 bits with no data values outside the range. If
%     % your system has no constraint on the word length, you can optimize
%     % the data type by setting the 'Word Length' parameter on the Bit
%     % Allocation panel to 'Auto'. This optimizes the data type such that
%     % no data will be outside the range. 
% 
%   % Example 2:
%      % View the dynamic range of a variable and arrive at a suitable
%      % data type. Set data type override to 'Scaled Doubles' to
%      % visualize data values outside the range and below precision with
%      % the current fixed-point setting.
% 
%      fp = fipref;
%      initialDTOSetting = fp.DataTypeOverride;
%      fp.DataTypeOverride = 'ScaledDoubles';
%      a = fi(magic(10),1,8,2);
%      b = fi([a; 2.^(-5:4)],1,8,3);
%      h1 = NumericTypeScope;
%      step(h1,b);
%      fp.DataTypeOverride = initialDTOSetting;
%
%      % You can see that the current data type of numerictype(1,8,3)
%      % introduces data values that are both outside range and below
%      % precision. For most applications the huge number values outside
%      % range is undesirable. You can correct this a few ways. For
%      % example:  
%      % 1) Set the 'Specify constraint' parameter to 'Maximum occurrences
%      %    outside range' and specify 0% as the value. You will see the
%      %    data type change immediately to satisfy this criteria and the
%      %    data will no longer be outside the range of the suggested
%      %    numerictype. 
%      % 2) Select the 'Graphical control' checkbox. You can then drag the
%      %    cursor on the left side of the binary point to a location where
%      %    there are no data values outside the range.
%
%   See also hist, log2, numerictype.

%   Copyright 2009-2015 The MathWorks, Inc.


%Check number of output arguments.
nargoutchk(1,1);

%check number of input arguments.
narginchk(0,0);

varargout{1} = embedded.NumericTypeScope;

% [EOF]
