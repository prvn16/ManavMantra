function outputStruct = set(obj, varargin)
%SET Configure or display serial port object properties.
%
%   SET(OBJ,'PropertyName',PropertyValue) sets the value, PropertyValue,
%   of the specified property, PropertyName, for serial port object OBJ.
%
%   OBJ can be a vector of serial port objects, in which case SET sets 
%   the property values for all the serial port objects specified.
%
%   SET(OBJ,S) where S is a structure whose field names are object property 
%   names, sets the properties named in each field name with the values 
%   contained in the structure.
%
%   SET(OBJ,PN,PV) sets the properties specified in the cell array of
%   strings, PN, to the corresponding values in the cell array PV for all
%   objects specified in OBJ. The cell array PN must be a vector, but the 
%   cell array PV can be M-by-N where M is equal to length(OBJ) and N is
%   equal to length(PN) so that each object will be updated with a different
%   set of values for the list of property names contained in PN.
%
%   SET(OBJ,'PropertyName1',PropertyValue1,'PropertyName2',PropertyValue2,...)
%   sets multiple property values with a single statement. Note that it
%   is permissible to use param-value string pairs, structures, and
%   param-value cell array pairs in the same call to SET.
%
%   SET(OBJ, 'PropertyName') 
%   PROP = SET(OBJ,'PropertyName') displays or returns the possible values
%   for the specified property, PropertyName, of serial port object OBJ. 
%   The returned array, PROP, is a cell array of possible value strings  
%   or an empty cell array if the property does not have a finite set of
%   possible string values.
%   
%   SET(OBJ) 
%   PROP = SET(OBJ) displays or returns all property names and their
%   possible values for serial port object OBJ. The return value, PROP, is
%   a structure whose field names are the property names of OBJ, and whose 
%   values are cell arrays of possible property values or empty cell arrays.
%
%   Example:
%       s = serial('COM1');
%       set(s, 'BaudRate', 9600, 'Parity', 'even');
%       set(s, {'StopBits', 'RecordName'}, {2, 'sydney.txt'});
%       set(s, 'Name', 'MySerialObject');
%       set(s, 'Parity')
%
%   See also SERIAL/GET.
%

%   Copyright 1999-2016 The MathWorks, Inc.

% convert to char in order to accept string datatype
varargin = instrument.internal.stringConversionHelpers.str2char(varargin);

% Call builtin set if OBJ isn't an instrument object.
% Ex. set(s, 'UserData', s);
if ~isa(obj, 'instrument')
    try
	    builtin('set', obj, varargin{:});
    catch aException
        rethrow(aException);
    end
    return;
end

% Error if invalid.
if ~all(isvalid(obj))
   error(message('MATLAB:serial:set:invalidOBJ'));
end

if (nargout == 0)
   % Ex. set(obj)
   if nargin == 1
      if (length(obj) == 1)
         localCreateSetDisplay(obj);
         return;
      else
         error(message('MATLAB:serial:set:nolhswithvector'));
      end
   else
      % Ex. set(obj, 'BaudRate');
      % Ex. set(obj, 'BaudRate', 4800);
      try
         % Call the java set method.
         if (nargin == 2)
            if ischar(varargin{1}) 
                % Ex. set(obj, 'RecordMode')
				disp(char(createPropSetDisplay(java(igetfield(obj, 'jobject')), varargin(1))));
            else
                % Ex. set(obj, struct);
                tempObj = igetfield(obj, 'jobject');
            	set(tempObj, varargin{:});
            end
         else
            % Ex. set(obj, 'BaudRate', 4800); 
            tempObj = igetfield(obj, 'jobject');
            set(tempObj, varargin{:});
         end
      catch aException
         localFixError(aException);
      end	
   end
else
   % Ex. out = set(obj);
   % Ex. out = set(obj, 'BaudRate');
   try
      % Call the java set method.
      switch nargin
          case 1
              % Ex. out = set(obj);
              if (length(obj) > 1)
                  error(message('MATLAB:serial:set:scalarHandle'));
              end
              outputStruct = set(igetfield(obj, 'jobject'), varargin{:});
          case 2
              % Ex. out = set(obj, 'BaudRate')
              if ~ischar(varargin{1})
                  % Ex. out = set(obj, {'BaudRate', 'Parity'});
                  error(message('MATLAB:serial:set:invalidPVPair'));
              end
              outputStruct = cell(createPropSetArray(java(igetfield(obj, 'jobject')), varargin{1}));
          case 3
              % Ex. out = set(obj, 'BaudRate', 9600)
              set(igetfield(obj, 'jobject'), varargin{:});
      end
   catch aException
      localFixError(aException);
   end	
end	

% **********************************************************************
% Create the display for SET(OBJ)
function localCreateSetDisplay(obj)

fprintf(char(setDisplay(igetfield(obj, 'jobject'))));

% *******************************************************************
% Fix the error message.
function localFixError(aException)

% Initialize variables.
out = aException.message;
id = aException.identifier;

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
    id = 'MATLAB:serial:set:opfailed';
end

throwAsCaller(MException(id,out));
% *******************************************************************
% findstr which handles possible Japanese translation.
function result = localfindstr(str1, out)

result = findstr(sprintf(str1), out);

% *******************************************************************
% strrep which handles possible Japanese translation.
function out = localstrrep(out, str1, str2)

out = strrep(out, sprintf(str1), sprintf(str2));
