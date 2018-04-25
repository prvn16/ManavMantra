function output = get(obj, varargin)
%GET Get serial port object properties.
%
%   V = GET(OBJ,'Property') returns the value, V, of the specified 
%   property, Property, for serial port object OBJ. 
%
%   If Property is replaced by a 1-by-N or N-by-1 cell array of strings 
%   containing property names, then GET will return a 1-by-N cell array
%   of values. If OBJ is a vector of serial port objects, then V will be 
%   a M-by-N cell array of property values where M is equal to the length
%   of OBJ and N is equal to the number of properties specified.
%
%   GET(OBJ) displays all property names and their current values for
%   serial port object OBJ.
%
%   V = GET(OBJ) returns a structure, V, where each field name is the
%   name of a property of OBJ and each field contains the value of that 
%   property.
%
%   Example:
%       s = serial('COM1');
%       get(s, {'BaudRate','DataBits'})
%       out = get(s, 'Parity')
%       get(s)
%
%   See also SERIAL/SET.
%

%   Copyright 1999-2016 The MathWorks, Inc.

% convert to char in order to accept string datatype
varargin = instrument.internal.stringConversionHelpers.str2char(varargin);

% Call builtin get if OBJ isn't an instrument object.
% Ex. get(s, s);
if ~isa(obj, 'instrument')
    try
	    builtin('get', obj, varargin{:});
    catch aException
        rethrow(aException);
    end
    return;
end

% Error if invalid.
if ~all(isvalid(obj))
   error(message('MATLAB:serial:get:invalidOBJ'));
end

if  ((nargout == 0) && (nargin == 1))
   % Ex. get(obj)
   if (length(obj) > 1)
      error(message('MATLAB:serial:get:nolhswithvector'))
   else
      localCreateGetDisplay(obj);
      return;
   end
elseif ((nargout == 1) && (nargin == 1))
   % Ex. out = get(obj);
   try
      % Call the java get method.
      output = get(igetfield(obj, 'jobject'));
  catch aException
      rethrow(aException);
   end
else
   % Ex. get(obj, 'BaudRate')
   try
      % Capture the output - call the java get method.
      output = get(igetfield(obj, 'jobject'), varargin{:});
  catch aException
      localFixError(aException);
   end	
end

% ***************************************************************
% Create the GET display.
function localCreateGetDisplay(obj)

% Get the java object.
jobject = igetfield(obj, 'jobject');

% Get an array indicating if the properties are interface specific.
interfaceSpecific = isInterfaceSpecific(java(jobject));

% Get the property names (names).
names = cell(getPropertyNames(java(jobject)));
vals = get(obj, names);

% Store interface specific properties in DEVICEPROPS.
deviceprops = {};

% Loop through each property and determine the display (dependent
% upon the class of val).
for i = 1:length(names)
   val = vals{i};
   if isnumeric(val)
      [m,n] = size(val);
      if isempty(val)
         % Print the property name only.
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = []\n', names{i})};
         else
            fprintf('    %s = []\n', names{i})
         end         
      elseif (m*n == 1)
         % SamplesPerTrigger = 1024
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = %g\n', names{i}, val)};
         else
            fprintf('    %s = %g\n', names{i}, val);
         end
      elseif ((m == 1) || (n == 1)) && (m*n <= 10)
         % The property value is a vector with a max of 10 values.
         % UserData = [1 2 3 4]
         numd = repmat('%g ',1,length(val));
         numd = numd(1:end-1);
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf(['    %s = [' numd ']\n'], names{i}, val)};
         else
            fprintf(['    %s = [' numd ']\n'], names{i}, val);
         end
      else
         % The property value is a matrix or a vector with more than 10 values.
         % UserData = [10x10 double]
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = [%dx%d %s]\n', names{i},m,n,class(val))};
         else
            fprintf('    %s = [%dx%d %s]\n', names{i},m,n,class(val));
         end
      end
   elseif ischar(val)
      % The property value is a string.
      % RecordMode = Append
      if isjava(val)
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = [1x1 struct]\n', names{i})};
         else
            fprintf('    %s = [1x1 struct]\n', names{i});
         end
      else
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = %s\n', names{i}, val)};
         else
            fprintf('    %s = %s\n', names{i}, val);
         end
      end
   else
      % The property value is an object, etc object.
      % UserData = [2x1 serial] 
      [m,n]=size(val);
      if interfaceSpecific(i)
         deviceprops = {deviceprops{:} sprintf('    %s = [%dx%d %s]\n', names{i},m,n,class(val))};
      else
         fprintf('    %s = [%dx%d %s]\n', names{i},m,n,class(val));
      end
   end
end

% Create a blank line after the property value listing.
fprintf('\n');

% Interface specific properties are displayed if they exist.
if ~isempty(deviceprops)
   
   % Create interface specific heading.
   fprintf(['    ' upper(get(obj, 'Type')) ' specific properties:\n']);
   
   % Display interface specific properties.
   for i=1:length(deviceprops)
      fprintf(deviceprops{i})
   end
   
   % Create a blank line after the interface specific property value listing.
   fprintf('\n');
end

% *******************************************************************
% Fix the error message.
function localFixError(oldException)

% Initialize variables.
out = oldException.message;
id = oldException.identifier;

if localfindstr('com.mathworks.toolbox.instrument.', out)
    out = strrep(out, sprintf('com.mathworks.toolbox.instrument.'), '');
end

if localfindstr('javahandle.', out)
	out = strrep(out, sprintf('javahandle.'), '');
end

out = localstrrep(out, 'SerialComm', 'serial port objects');
out = localstrrep(out, 'in the ''serial port objects'' class', 'for serial port objects');

% Remove the trailing carriage returns from errmsg.
while out(end) == sprintf('\n')
   out = out(1:end-1);
end

if isempty(id) || ~isempty(findstr(id, 'MATLAB:class:'))
    id = 'MATLAB:serial:get:opfailed';
end

aException=MException(id,out);
throwAsCaller(aException);


% *******************************************************************
% findstr which handles possible Japanese translation.
function result = localfindstr(str1, out)

result = findstr(sprintf(str1), out);

% *******************************************************************
% strrep which handles possible Japanese translation.
function out = localstrrep(out, str1, str2)

out = strrep(out, sprintf(str1), sprintf(str2));
