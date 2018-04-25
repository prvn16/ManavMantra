function h = actxserver(progID, varargin)
%ACTXSERVER Creates a COM Automation server.
%  H = ACTXSERVER('PROGID') Creates a local or remote COM Automation server
%  where PROGID is the programmatic identifier of the COM server and H is
%  the handle of the server's default interface. 
%
%  H = ACTXSERVER('PROGID', 'param1', value1,...) creates an ActiveX
%  server with optional parameter name/value pairs. Parameter names are:
%   machine:    specifies the name of a remote machine on which to launch 
%               the server.
%   interface:  "IUnknown" if user wants MATLAB to use IUnknown interface
%               of COM object, "IDispatch" for IDispatch interface
%               (default), or a custom interface name.
%
%  Example:
%  h=actxserver('myserver.test.1', 'machine', 'machinename',
%  'Interface', 'IUnknown')
%
%  h=actxserver('myserver.test.1', 'interface', 'IUnknown')
%
%  h=actxserver('myserver.test.1')
%
%
%  The following syntaxes are deprecated and will not become obsolete.  They
%  are included for reference, but the above syntaxes are preferred.
%
%  H = ACTXSERVER(PROGID,'MACHINE') specifies the name of a remote machine 
%  on which to launch the server.
% 
%  See also: ACTXCONTROL

% Copyright 2006-2007 The MathWorks, Inc.

narginchk(1,5);

machinename = '';
interface = 'IDispatch';

if (nargin >2)
    
    param = {'machine','interface'};
    
    if mod(length(varargin), 2) == 1
        error(message('MATLAB:actxcontrol:numargs'));  
    end
    
    for i=1:2:length(varargin)
        p = lower(varargin{i});
        v = varargin{i+1};
        
        try
            fieldmatch = ismember(p,param);
        catch
            error('MATLAB:actxcontrol:unknownparam','%s',getString(message('MATLAB:actxcontrol:unknownparamPosition', i+1)));
        end

        if (~fieldmatch)
            if ischar(p)
                warning(message('MATLAB:actxcontrol:unknownparam', p));
            else
                warning('MATLAB:actxcontrol:unknownparam','%s', getString(message('MATLAB:actxcontrol:unknownparamPosition', i+1)));
            end    
        end 

        switch p
            case 'machine'
                machinename = v;
            case 'interface' 
                interface = v;
        end %switch
    end %for loop

else
    if (nargin == 2)
        machinename = varargin{1};
    end
end %if statement



% workaround for bug parsing control name which ends with dot + integer
convertedProgID = newprogid(progID);


    try
        h=feval(['COM.' convertedProgID], 'server', machinename, interface);
    catch originalException
        if (strcmpi(originalException.identifier, 'MATLAB:Undefinedfunction'))
            newException = MException('MATLAB:COM:InvalidProgid',getString(message('MATLAB:COM:servercreationfailedProgid',progID)));
            throw(newException);
        else    
            rethrow(originalException);
        end    
    end    


% if (~isempty(machinename))
%     try
%         h=feval(['COM.' convertedProgID], 'server', machinename, interface);
%     catch
%         lastid = lasterror; lastid = lastid.identifier;
%         if (strcmpi(lastid, 'MATLAB:Undefinedfunction'))
%             disp = sprintf('Server creation failed. Invalid ProgID ''%s''', progID);
%             error('MATLAB:COM:InvalidProgid',disp);
%         else    
%             rethrow(lasterror);
%         end    
%     end    
% else
%     try
%         h=feval(['COM.' convertedProgID], 'server');
%     catch
%         lastid = lasterror; lastid = lastid.identifier;
%         if (strcmpi(lastid, 'MATLAB:Undefinedfunction'))
%             disp = sprintf('Server creation failed. Invalid ProgID ''%s''', progID);
%             error('MATLAB:COM:InvalidProgid',disp);
%         else    
%             rethrow(lasterror);
%         end    
%     end        
% end


