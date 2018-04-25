function dom = createSoapMessage(tns,methodname,values,names,types,style)
%createSoapMessage Create a SOAP message, ready to send to the server.
%   createSoapMessage(NAMESPACE,METHOD,VALUES,NAMES,TYPES,STYLE) creates a SOAP
%   message.  VALUES, NAMES, and TYPES are cell arrays.  NAMES will
%   default to dummy names and TYPES will default to unspecified.  STYLE
%   specifies 'document' or 'rpc' messages ('rpc' is the default).
%
%   Example:
%
%   message = createSoapMessage( ...
%       'urn:xmethods-delayed-quotes', ...
%       'getQuote', ...
%       {'GOOG'}, ...
%       {'symbol'}, ...
%       {'{http://www.w3.org/2001/XMLSchema}string'}, ...
%       'rpc');
%   response = callSoapService( ...
%       'http://64.124.140.30:9090/soap', ...
%       'urn:xmethods-delayed-quotes#getQuote', ...
%       message);
%   price = parseSoapResponse(response)
% 
%   This function will be removed in a future release.  For non-RPC/Encoded WSDLs,
%   use matlab.wsdl.createWSDLClient instead.
%
%   See also createClassFromWsdl, callSoapService, parseSoapResponse, 
%            matlab.wsdl.createWSDLClient.

% Copyright 1984-2014 The MathWorks, Inc.

% Default to made-up names.
if (nargin < 4)
    names = cell(length(values));
    for i = 1:length(values)
        names{i} = sprintf('param%.0f',i);
    end
end
% Default to empty types.
if (nargin < 5)
    types = cell(length(values));
    types(:) = {''};
end
% Default to 'rpc'.
if (nargin < 6)
    style = 'rpc';
end

%   Form the envelope
dom = com.mathworks.xml.XMLUtils.createDocument('http://schemas.xmlsoap.org/soap/envelope/','soap:Envelope');
rootNode = dom.getDocumentElement;
switch style
    case 'rpc'
        rootNode.setAttribute('xmlns:n',tns);
end
rootNode.setAttribute('xmlns:soap','http://schemas.xmlsoap.org/soap/envelope/');
rootNode.setAttribute('xmlns:soapenc','http://schemas.xmlsoap.org/soap/encoding/');
rootNode.setAttribute('xmlns:xs','http://www.w3.org/2001/XMLSchema');
rootNode.setAttribute('xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');

% Form the body
soapBody = dom.createElement('soap:Body');
soapBody.setAttribute('soap:encodingStyle','http://schemas.xmlsoap.org/soap/encoding/');

% Method
switch style
    case 'rpc'
        soapMessage = dom.createElement(['n:' methodname]);
    case 'document'
        soapMessage = dom.createElement(methodname);
        soapMessage.setAttribute('xmlns',tns)
end
soapBody.appendChild(soapMessage);

% Add inputs.
populate(dom,soapMessage,values,names,types)

% Add the body
rootNode.appendChild(soapBody);

%===============================================================================
function populate(dom,node,values,names,types)

for i = 1:length(names)
    if ischar(types{i}) && ...
            numel(types{i} > 2) && ...
            strcmp(types{i}(end-1:end),'[]')
        soapArray = dom.createElement(names{i});
        soapArray.setAttribute('xsi:type','soapenc:Array');
        addTypeAttribute(soapArray,'soapenc:arrayType',types{i})
        v = values{i};
        if ~iscell(v)
            v = num2cell(v);
        end
        populate(dom,soapArray, ...
            v,repmat({'item'},size(values{i})), ...
            cell(size(values{i})));
        node.appendChild(soapArray);        
    elseif isstruct(values{i})
        for j = 1:length(values{i})
            soapStruct = dom.createElement(names{i});
            populate(dom,soapStruct, ...
                struct2cell(values{i}(j)),fieldnames(values{i}(j)), ...
                cell(size(fieldnames(values{i}(j)))));
            node.appendChild(soapStruct);
        end
    elseif iscell(values{i})
        populate(dom,node, ...
            values{i},repmat(names(i),size(values{i})), ...
            cell(size(values{i})));
    else
        input = dom.createElement(names{i});
        addTypeAttribute(input,'xsi:type',types{i})
        textToSend = convertToText(values{i});
        input.appendChild(dom.createTextNode(textToSend));
        node.appendChild(input);
    end
end

%===============================================================================
function addTypeAttribute(node,attribute,type)
if ~isempty(type)
    if ~isempty(strmatch('{http://www.w3.org/2001/XMLSchema}',type))
        node.setAttribute(attribute,['xs:' type(35:end)]);
    else
        % TODO: Better type handling.
        %fprintf('Could do better with "%s" in "%s".',types{i},names{i})
    end
end

%===============================================================================
function s = convertToText(x)
switch class(x)
    case 'char'
        s = x;
    otherwise
        s = mat2str(x);
end