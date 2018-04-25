function d = NaT(varargin)
%NaT Not-a-Datetime.
%   NaT is the representation for Not-a-Datetime, a value that can be stored in
%   a datetime array to indicate an unknown or missing datetime value. DATETIME
%   creates a NaT automatically when reading text that cannot be parsed as a datetime,
%   or for elements in a datetime array where the Year, Month, 
%   Day, Hour, Minute, or Second properties are set to NaN.
%
%   D = NaT with no inputs returns a scalar NaT datetime.
%   D = NaT(N) is an N-by-N matrix of NaTs.
%   D = NaT(M,N) or NaT([M,N]) is an M-by-N matrix of NaTs.
%   D = NaT(M,N,P,...) or NaT([M,N,P,...]) is an M-by-N-by-P-by-... array of NaTs.
%
%   Note: The size inputs M, N, and P... should be nonnegative integers. 
%   Negative integers are treated as 0.
%
%   D = NAT(...,'Format',FMT, ...) creates D with the specified display format. FMT
%   is a character vector containing a datetime format. See the description of the <a href="matlab:doc('datetime.Format')">Format property</a>
%   for details.
%
%   D = NAT(...,'TimeZone',TZ, ...) specifies the time zone that the datetimes in D
%   are in. TZ is the name of a time zone region, as accepted by the DATETIME
%   function. See the description of the <a href="matlab:doc('datetime.TimeZone')">TimeZone property</a> for more
%   details.
%
%   See also ISNAT, NAN, DATETIME.

%   Copyright 2015-2017 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.parseArgs

if nargin == 0
    d = datetime.fromMillis(NaN);
else
    paramsStart = find(cellfun(@(s) isCharString(s),varargin),1,'first');
    if isempty(paramsStart)
        d = datetime.fromMillis(NaN(varargin{:}));
    else
        % Separate the size inputs from the parameters.
        params = varargin(paramsStart:end);
        varargin(paramsStart:end) = [];
        
        d = datetime(0,0,0,0,0,nan(varargin{:}),params{:});
    end
end
