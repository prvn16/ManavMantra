function varargout = webread(url, varargin)
%WEBREAD Read content from RESTful web service
%
%   Syntax
%   ------
%   DATA = WEBREAD(URL)
%   DATA = WEBREAD(URL,QueryName1,QueryValue1, ...)
%   DATA = WEBREAD(__,OPTIONS)
%   [DATA1,__] = WEBREAD(__)
%
%   Description
%   ------------
%   DATA = WEBREAD(URL) reads content from the web service specified by the
%   string URL and returns the content in DATA. WEBREAD sets HTTP request
%   parameters with the default property values of WEBOPTIONS and uses the
%   HTTP GET method to read content from URL.
%
%   DATA = WEBREAD(URL,QueryName1,QueryValue1,...) appends additional RESTful
%   web service query parameters, specified by QueryName1, QueryValue1, ..., to
%   URL. These name,value pair arguments set query parameters in an HTTP GET
%   operation. The parameters supported by a web service are defined in the
%   service's documentation. WEBREAD adds parameters to URL using the
%   "&name=value" construct. However, if URL does not contain a "?" character,
%   then WEBREAD adds the first name, value pair as "?name=value". WEBREAD still
%   adds all following parameters as "&name=value". Numeric and logical values
%   are converted to strings using NUM2STR. Nonscalar values are encoded as
%   specified by the default ArrayFormat property of WEBOPTIONS.
%
%   DATA = WEBREAD(__, OPTIONS) sets HTTP request parameters with the property
%   values of the scalar WEBOPTIONS object OPTIONS. Set the RequestMethod
%   property of OPTIONS to 'post' or some other method if you need to use a
%   method other than GET when reading data from a RESTful web service.
%   Changing the RequestMethod does not affect where the query parameters are
%   placed: they always are appended to the URL. To place parameters in the
%   body of the message, use WEBWRITE.  
%
%   [DATA1, __] = WEBREAD(__) returns multiple data values from the web
%   service if the data content is an indexed image or audio data, or if
%   you set options.ContentReader and your content reader returns multiple
%   outputs.
%
%   Input Arguments
%   ---------------
%
%   Name  Description                                     Data Type
%   ----  --------------------                            ---------
%   URL   Web address of content including the            string
%         transfer protocol, http or https. 
%         The URL is automatically encoded.
%
%   QueryName
%         Name of additional web service parameter        string
%         to append to URL.
%
%   QueryValue 
%         Value of additional web service parameter       string; vector of
%         to append to URL. If you specify a datetime     numeric, logical
%         you must specify its Format property as         or datetime; 2-D 
%         expected by the web service.  If it is a        array of char; or
%         non-scalar vector or cell vector, or char       cell array containing
%         array with more than one row, the value is      strings or numeric,
%         processed according to the ArrayFormat property logical or datetime
%         of WEBOPTIONS.                                  scalars
%
%   OPTIONS
%         Other options used to connect to web            scalar WEBOPTIONS
%         service.                                        object
%
%   % Example 1
%   % ---------
%   % Read the HTML page on the MATLAB(R) Central File Exchange that lists 
%   % submissions for sensor-data-acquisition.
%   url = 'https://www.mathworks.com/matlabcentral/fileexchange';
%   searchTerm = 'sensor-data-acquisition';
%   html = webread(url,'term',searchTerm)
%
%   % Example 2
%   % ---------
%   % Read USA average historical temperature data based on gridded
%   % climatologies from the Climate Research Unit and provided by the
%   % World Bank web service. More information on the data set may be found
%   % at http://data.worldbank.org/developers/climate-data-api
%   % The service returns data formatted as JSON objects.
%   % webread converts homogeneous JSON objects to a structure array.
%   api = 'http://climatedataapi.worldbank.org/climateweb/rest/v1/';
%   url = [api 'country/cru/tas/year/USA'];
%   S = webread(url)
%
%   % Plot the average temperature per year. 
%   % Convert temperatures and years to numeric arrays. 
%   % Convert years to a datetime array for ease of plotting.
%   temperatures = [S.data];
%   years = [S.year];
%   month = 1;
%   day = 1;
%   yearsToPlot = datetime(years,month,day);
%   figure
%   plot(yearsToPlot,temperatures);
%   minyear = num2str(min(years));
%   maxyear = num2str(max(years));
%   attribution = 'World Bank: Historical Data: Climate Research Unit';
%   title({['USA Average Temperature ',minyear,'-',maxyear], attribution});
%   xlabel Year
%   ylabel 'Temperature (^{\circ}C)'
%
%   % Read JSON data from the World Bank web service as text. 
%   options = weboptions('ContentType','text');
%   textData = webread(url,options)
%
%   See also AUDIOREAD, DATETIME, IMREAD, READTABLE, JSONDECODE, WEBOPTIONS, WEBWRITE, 
%            WEBSAVE, XMLREAD, WEBOPTIONS.ArrayFormat

% Copyright 2014-2017 The MathWorks, Inc.

% Parse the inputs.
[queryParams, options] = parseInputs(mfilename, varargin);

% Encode inputs.
[url, options] = encodeInputs(url, queryParams, options);

% Open the HTTP connection and obtain the connection and content type.
connection = openHTTPConnection(url, options, '');

% Send the request and read the content from the web service.
[varargout{1:nargout}] = readContentFromWebService(connection, options);
