function name = createClassFromWsdl(wsdl)
%createClassFromWsdl Create a MATLAB object based on a WSDL-file.
%   createClassFromWsdl('source') creates MATLAB classes based on a WSDL 
%   application programming interface (API). The source argument specifies a URL
%   or file path to a WSDL API, which defines web service methods, arguments, 
%   and transactions. It returns the name of the new class.
%  
%   Based on the WSDL API, the createClassFromWSDL function creates a new folder
%   in the current directory. The folder contains a MATLAB file for each web service
%   method. In addition, two default MATLAB are created, the object's
%   display method (display.m) and its constructor (servicename.m).
%
%   Example
%  
%   cd(tempdir)
%   % Create a class for the web service provided by xmethods.net.
%   url = 'http://services.xmethods.net/soap/urn:xmethods-delayed-quotes.wsdl';
%   createClassFromWsdl(url);
%   % Instantiate the object.
%   service = StockQuoteService;
%   % getQuote returns the price of a stock.
%   getQuote(service,'GOOG')
%
%   This function will be removed in a future release.  For non-RPC/Encoded WSDLs,
%   use matlab.wsdl.createWSDLClient instead.
%
%   See also createSoapMessage, callSoapService, parseSoapResponse, 
%            matlab.wsdl.createWSDLClient.

% Copyright 1984-2015 The MathWorks, Inc.

% Parse the WSDL-file.
wsdlUrl = xmlstringinput(wsdl,true);
[R, schema] = parseWsdl(wsdlUrl);

% Create the constructor and methods
for i = 1:length(R)
    makeconstructor(R(i))
    makemethods(R(i))
end
rehash path

% Return the name of the class.
if (length(R) == 1)
    name = R.name;
else
    name = {R.name};
end

%===============================================================================
function [struct, schema] = parseWsdl(wsdl)

% Retrieve wsdl using URLREAD
msg = ['Retrieving document at ''' wsdl '''']; 
disp(msg);
downloadedData = urlread(wsdl);

% Save to local file.
tmp = 'wsdl.wsdl';
fid = fopen(tmp, 'w'); % @todo - charset
fwrite(fid, downloadedData);
fclose(fid);
localWsdl = fullfile(pwd, tmp);

% Parse and process WSDL file. 
wsdlFactory = javax.wsdl.factory.WSDLFactory.newInstance(); 
wsdlReader = wsdlFactory.newWSDLReader(); 
% turn off verbosity, so we don't get a 'Retrieving document...' from wsdl4j
wsdlReader.setFeature('javax.wsdl.verbose', false);

try
    definition = wsdlReader.readWSDL(localWsdl);
    defTypes = definition.getTypes();
    se = defTypes.getExtensibilityElements().get(0);   
    extElement = se.getElement(); 
    schemaCol = org.apache.ws.commons.schema.XmlSchemaCollection();
    schema = schemaCol.read(extElement);
catch e
    exception = regexp(e.message, ...
        'Java exception occurred: \n(.*?)\s*\n','tokens','once');
    if ~isempty(exception)
        exception = exception{1};
        if strcmp(exception, ...
                'java.net.ConnectException: Connection refused: connect')
            error(message('MATLAB:createClassFromWsdl:ConnectionRefused'));
        end
        if strcmp(exception, ...
                'ice.net.URLNotFoundException: Document not found on server')
            error(message('MATLAB:createClassFromWsdl:UrlNotFound'))
        end
        host = regexp(exception,'java.net.UnknownHostException: (.*)','tokens','once');
        if ~isempty(host)
            error(message('MATLAB:createClassFromWsdl:UnknownHost', host{ 1 }))
        end
        sax = regexp(exception,'org.xml.sax.SAXException: (.*)','tokens','once');
        if ~isempty(sax)
            error(message('MATLAB:createClassFromWsdl:BadXml', sax{1}))
        end
        error(message('MATLAB:createClassFromWsdl:Exception',exception))
    else
        rethrow(e)
    end
end

% delete the tmp wsdl
delete(localWsdl);
    
symbolTable = definition.getBindings.values;
typeData = definition.getTypes; 

% This is the structure to return.
struct = [];

% Extracting information about each binding to create a MATLAB class.
it = symbolTable.iterator();
isRPCEncoded = false;

while it.hasNext
    v = it.next();
        entry = v;
        if isa(entry,'javax.wsdl.Binding')
            bindingEntry = entry;
        else
            continue
        end
        
        % For each binding...
        binding = bindingEntry;

        % Find the service and port for this binding.
        serviceIterator = definition.getServices.values.iterator;
        port = [];
        while (isempty(port) && serviceIterator.hasNext)
            service = serviceIterator.next;
            portIterator = service.getPorts.values.iterator;
            while portIterator.hasNext;
                testPort = portIterator.next;
                if binding.getQName.equals(testPort.getBinding.getQName)
                    % Found it.  Keep variables port and service.
                    port = testPort;
                    break
                end
            end
        end

        % Skip bindings with no ports.
        if isempty(port)
            continue
        end
        
        % Determine the MATLAB object name from the service name.
        name = char(service.getQName.getLocalPart);
        name = genvarname(name(max([0 find(name == '.')])+1:end));

        % Construct the operations for this binding's portType.
        portType = binding.getPortType;
        operations = portType.getOperations().iterator();
        ops = [];
        while (operations.hasNext)
            % For each operation...
            operation = operations.next;
            bindingOperation = binding.getBindingOperation( ...
                operation.getName, ...
                operation.getInput.getName, ...
                operation.getOutput.getName);
            extension = bindingOperation.getExtensibilityElements.elementAt(0);
            if isa(extension,'javax.wsdl.extensions.soap.SOAPOperation')
                soapOperation = extension;
            else
                % Not a SOAP operation.  Skip.
                continue
            end
            op = makeOperation(operation,schema);
            soapBody = bindingOperation.getBindingInput.getExtensibilityElements.elementAt(0);
            op.targetNamespaceURI = char(soapBody.getNamespaceURI);
            if isempty(op.targetNamespaceURI)
                op.targetNamespaceURI = char(definition.getTargetNamespace);
            end
            if ~isRPCEncoded && soapBody.getUse.equals('encoded') 
                elements = binding.getExtensibilityElements;
                if ~isempty(elements) 
                    for i = 0 : length(elements) - 1
                        element = elements.get(i);
                        style = element.getStyle;
                        if strcmp(char(style),'rpc')
                            isRPCEncoded = true;    
                            break
                        end
                    end
                end
            end
            op.soapAction = char(soapOperation.getSoapActionURI);
            ops = [ops op];
        end
        % If there are SOAP operations defined, add it to the list.
        if ~isempty(ops)
            struct(end+1).name = name;
            struct(end).wsdlLocation = wsdl;
            struct(end).endpoint = char(port.getExtensibilityElements.elementAt(0).getLocationURI);
            style = char(soapOperation.getStyle);
            if isempty(style)
                for i = 0:binding.getExtensibilityElements().size-1
                    ee = binding.getExtensibilityElements().get(i);
                    if (isa(ee,'javax.wsdl.extensions.soap.SOAPBinding')) 
                        style = ee.getStyle();
                    end                    
                end                
            end
            struct(end).style = style;
            struct(end).methods = ops;
        end
    if ~isRPCEncoded
        warning(message('MATLAB:webservices:FunctionToBeRemoved'));
    end
end



%===============================================================================
function op = makeOperation(operation,schema)

op = [];
if ~isequal(operation.getStyle,javax.wsdl.OperationType.REQUEST_RESPONSE)
    return
end

name = char(operation.getName);
op.methodName = name;

% Create documentation for MATLAB file help.
if isempty(operation.getDocumentationElement)
    doc = '';
else
    doc = sprintf('%s\n\n', ...
        char(operation.getDocumentationElement.getTextContent));
end

% Calling parameters:
op.input = extractParams(operation.getInput(), schema);
doc = buildDoc(sprintf('%s  Input:\n',doc),op.input,'    ');

% Return parameter:
op.output = extractParams(operation.getOutput(), schema);
doc = buildDoc(sprintf('%s\n  Output:\n',doc),op.output,'    ');

% Save the documentation for the MATLAB file help.
doc = regexprep(doc,'\s*$','');
doc = ['%   ' regexprep(doc,'\n','\n%   ')];
op.documentation = doc;

%===============================================================================
% Extracts the parameter type information into a list from the wsdl and
% schema where necessary. 
function retList = extractParams(params,schema) 
retList = []; 
inputParamNames = params.getMessage().getOrderedParts([]); 
if ~isempty(inputParamNames) 
    iterator = inputParamNames.iterator; 
    while (iterator.hasNext) 
        msgPart = iterator.next(); 
        isArray = false; 
        nextName = '';
        nextType = ''; 
        if (~isempty(msgPart.getName()) || ~isempty(msgPart.getTypeName)) 
            qname = msgPart.getElementName();
            if (~isempty(qname))
                qname = msgPart.getElementName(); 
                xElement = schema.getElementByName(qname);
                nextRetList = extractTypeFromSchemaElement(xElement);
                if (~isempty(nextRetList)) 
                    retList = [ retList nextRetList ]; 
                end
            else % we may be parsing rpc style
                if (isempty(msgPart.getName()))                     
                   error(message('MATLAB:createClassFromWsdl:WsdlParsingFailure'));
                end
                if (~isempty(msgPart.getElementName())) 
                    qname = msgPart.getElementName(); 
                    xElement = schema.getElementByName(qname);
                    nextRetList = extractTypeFromSchemaElement(xElement); 
                    if (~isempty(nextRetList)) 
                        retList = [ retList nextRetList ]; 
                    end                
                else
                    nextName = char(msgPart.getName()); 
                    nextType = char(msgPart.getTypeName()); 
                    nextOp = struct('name',nextName, 'type',nextType, 'isArray', isArray);
                    nextRetList = extractTypeFromSchemaComplexType(msgPart,schema); 
                    if (~isempty(nextRetList))
                        retList = [ retList nextRetList ]; 
                    end
                end
            end
        end

    end        
end

%===============================================================================
% Searches the schema for the type specified in the msgPart
% This is invoked when parsing document style literal encoded wsdl
function retList = extractTypeFromSchemaComplexType(msgPart,schema) 
retList = []; 
schemaType = schema.getTypeByName(msgPart.getTypeName());
if (~isempty(schemaType) && ~isempty(schemaType.getContentModel()))
    restriction = schemaType.getContentModel().getContent();
    nextName = char(msgPart.getName()); 
    isArray = false; 
    attr = restriction.getAttributes().getItem(0);
    nextType = char(attr.getName()); 
    rawTypes = attr.getUnhandledAttributes(); 
    if (numel(rawTypes) > 0)    
        type = char(rawTypes(1));   
        if (~isempty(regexp(type,']')))
            isArray = true;
        end
        [ first, second ] = find(type == '"');
        nextType = type(second(1)+1:second(2)-3);
        % fix for g517416: which had a problem with rpc/soap-encoded arrays
        nextType = regexprep(nextType,'xsd:','{http://www.w3.org/2001/XMLSchema}');
        nextOp = struct('name',nextName, 'type',nextType, 'isArray', isArray);
        retList = [ retList nextOp ];        
    end
elseif (~isempty(regexp(char(msgPart.getTypeName()),'http://www.w3.org/.*/XMLSchema.*')))
    % Then we're looking at a simple type described in the base level www schema
    nextName = char(msgPart.getName()); 
    nextType = char(msgPart.getTypeName());
    isArray = false; 
    nextOp = struct('name',nextName, 'type',nextType, 'isArray', isArray);
    retList = [ retList nextOp ]; 
else % Exercised by rpc style literal encoded test wsdl
    nextName = char(msgPart.getName());  
    nextType = char(msgPart.getTypeName().getLocalPart()); 
    % TODO: adjust this isArray logic. But to do this, we need a sample to
    % exercise it. 
    isArray = false; 
    nextOp = struct('name',nextName, 'type',nextType, 'isArray', isArray);
    retList = [ retList nextOp ];     
end


%===============================================================================
% Searches the schema for the type specified in the msgPart
% function retList = extractTypeFromSchemaElement(msgPart,schema) 
function retList = extractTypeFromSchemaElement(xElement)
retList = []; 
if (~isempty(xElement)) 
    if (isa(xElement, 'org.apache.ws.commons.schema.XmlSchemaElement') &&...
            isa(xElement.getSchemaType(),'org.apache.ws.commons.schema.XmlSchemaComplexType'))
        eTypes = xElement.getSchemaType();
    elseif (isa(xElement, 'org.apache.ws.commons.schema.XmlSchemaComplexType'))
        eTypes = xElement; 
    end
    if (~isempty(eTypes)) 
        particle =  eTypes.getParticle();
        if (~isempty(particle)) 
            typeIterator = particle.getItems().getIterator();
            while (typeIterator.hasNext()) 
                tElement = typeIterator.next();
                nextName = char(tElement.getName()); 
                nextType = char(tElement.getSchemaType().getQName());

                if (tElement.getMaxOccurs() > 1) 
                    isArray = true; 
                else
                    isArray = false; 
                end
                nextOp = struct('name',nextName, 'type',nextType, 'isArray', isArray);
                retList = [ retList nextOp ]; 
            end    
        end
    end % this condition fails to be met when there's no subtype, e.g. in null return types    
end

%===============================================================================
function doc = buildDoc(doc,x,prefix)
for i = 1:length(x)
    if isstruct(x(i).type)
        if x(i).isArray
            array = '(:)';
        else
            array = '';
        end
        doc = buildDoc(doc,x(i).type,[prefix x(i).name array '.']);
    else
        if x(i).isArray
            array = '{:}';
        else
            array = '';
        end
        doc = s2c(doc);
        prefix = s2c(prefix);
        x(i).name = s2c(x(i).name); 
        array = s2c(array);
        localName = s2c(getLocalName(x(i).type));
        doc = sprintf('%s%s%s%s = (%s)\n', ...
            doc,prefix,x(i).name,array,localName);
    end
end

%===============================================================================
function s = s2c(s) 
if (isa(s,'java.lang.String'))
    s = char(s);
end

%===============================================================================
% TBR JRL with MS -- TODO delete: this isn't currently used
function [nextType,isArray] = extractType(typeName,typeData,nesting)

% Initialize variables.
nextType = [];
isArray = false;
typeName = getLocalName(typeName);
typeInfo = typeData.get(typeName);

% Keep track of the tree to detect recursion.
if (nargin < 3)
    nesting = {};
end
if ~isempty(strmatch(typeName,nesting,'exact'))
    warning(message('MATLAB:createClassFromWsdl:Unsupported', typeName));
    nextType = typeName;
    return
end
nesting{end+1} = typeName;

if isempty(typeInfo) || (typeInfo.size == 0)
    if isempty(regexp(typeName,'\]$','once'))
        % Simpe type.
        %    op.input(end+1).name =
        %    op.input(end+1).type =
        nextType = restoreNamespace(typeName);
    else
        % It is an array.
        nextType = extractType(typeName(1:find(typeName == '[')-1),typeData,nesting);
        isArray = true;
    end    
elseif (typeInfo.size == 1)
    % Restriction.
    %    op.input(end+1).name =
    %    op.input(end+1).type = (where type is the base class)
    [nextType,isArray] = extractType(typeInfo.elementAt(0),typeData,nesting);
else
    % Nested type.
    %    op.input(end+1).name =
    %    op.input(end+1).type(1).name =
    %    op.input(end+1).type(1).type =
    %    op.input(end+1).type(2).name =
    %    op.input(end+1).type(2).type =
    for ii = 1:2:typeInfo.size
        nextType((ii+1)/2).name = getLocalName(char(typeInfo.elementAt(ii-1)));
        [nextType((ii+1)/2).type,nextType((ii+1)/2).isArray] = ...
            extractType(typeInfo.elementAt(ii),typeData,nesting);
    end
end


%===============================================================================
function s = getLocalName(s)
s = regexprep(s2c(s),'.*[}:>]','');

%===============================================================================
function s = restoreNamespace(s)
xsd = '{http://www.w3.org/2001/XMLSchema}';
switch s
    case {'string','normalizedString','token','byte','unsignedByte','base64Binary','hexBinary','integer','positiveInteger','negativeInteger','nonNegativeInteger','nonPositiveInteger','int','unsignedInt','long','unsignedLong','short','unsignedShort','decimal','float','double','boolean','1,','time','dateTime','duration','date','gMonth','gYear','gYearMonth','gDay','gMonthDay','Name','QName','NCName','anyURI','language','ID','IDREF','IDREFS','ENTITY','ENTITIES','NOTATION','NMTOKEN'}
        ns = xsd;
    otherwise
        ns = '';
end
s = [ns s];

%===============================================================================
function child = getFirstChildNode(node)
child = node.getFirstChild;
while ~isempty(child) && (child.getNodeType == child.TEXT_NODE)
    child = child.getNextSibling;
end


%===============================================================================
%===============================================================================
function makeconstructor(R)
% Create a constructor from a structure derived from a WSDL
tf = fullfile(fileparts(mfilename('fullpath')),'private','constructor.mtl');
template = textread(tf,'%s','delimiter','\n','whitespace','');

replacements = {'$CLASSNAME$',R.name,'$ENDPOINT$', ...
    R.endpoint,'$WSDLLOCATION$',R.wsdlLocation};
for i = 1:2:length(replacements)
    template = strrep(template,replacements{i},replacements{i+1});
end

% Prepare the object output location.
dirName = ['@' R.name];
if isempty(dir(dirName))
    mkdir(dirName);
end
delete(fullfile(dirName,'*.m'))

% Create the methods.
writemfile(['@' R.name filesep R.name '.m'],template);

% Also create a display method
C = {'function display(obj)','disp(struct(obj))'};
writemfile(['@' R.name filesep 'display.m'],C);


%===============================================================================
function makemethods(R)
% Creates the methods for the WSDL described by R.

% Read in the template.
tf = fullfile(fileparts(mfilename('fullpath')),'private','genericmethod.mtl');
originalTemplate = textread(tf,'%s','delimiter','\n','whitespace','');

methodNames = genvarname({R.methods.methodName},R.name);
for iMethod = 1:length(R.methods)
    method = R.methods(iMethod);
    
    if isempty(method.output)
        outputNames = {};
    else
        outputNames = {method.output.name};
    end
    legalOutputNames = genvarname(outputNames);
    switch length(legalOutputNames)
        case 0
            outputString = '';
        case 1
            outputString = sprintf('%s = ',legalOutputNames{1});
        otherwise
            outputString = sprintf('%s,',legalOutputNames{:});
            outputString(end) = [];
            outputString = sprintf('[%s] = ',outputString);
    end

    if isempty(method.input)
        inputNames = {};
    else
        inputNames = {method.input.name};
    end
    legalInputNames = genvarname(inputNames);
    switch length(legalInputNames)
        case 0
            inputString = '(obj)';
        case 1
            inputString = sprintf('(obj,%s)',legalInputNames{1});
        otherwise
            inputString = sprintf('%s,',legalInputNames{:});
            inputString(end) = [];
            inputString = sprintf('(obj,%s)',inputString);
    end

    % Write out the parameter name, input name, and type mapping.
    s = sprintf('values = { ...\n');
    for i = 1:length(legalInputNames)
        s = sprintf('%s   %s, ...\n', ...
            s, ...
            legalInputNames{i});
    end
    s = sprintf('%s   };\n',s);
    s = sprintf('%snames = { ...\n',s);
    for i = 1:length(inputNames)
        s = sprintf('%s   ''%s'', ...\n', ...
            s, ...
            inputNames{i});
    end
    s = sprintf('%s   };\n',s);
    s = sprintf('%stypes = { ...\n',s);
    if isempty(method.input)
        inputTypes = {};
        inputTypeIsArray = [];
    elseif isstruct(method.input(1).type)
        inputTypes = {method.input.name};
        inputTypeIsArray = [method.input.isArray];
    else
        inputTypes = {method.input.type};
        inputTypeIsArray = [method.input.isArray];
    end
    for i = 1:length(inputNames)
        if isstruct(inputTypes{i})
            t = '';
        else
            t = inputTypes{i};
            if inputTypeIsArray(i)
                t = [t '[]'];
            end
        end
        s = sprintf('%s   ''%s'', ...\n', ...
            s, ...
            t);
    end
    parameterDefinition = sprintf('%s   };',s);

    replacements = {'$METHODNAME$',method.methodName,...
        '$TARGETNAMESPACEURI$',method.targetNamespaceURI,...
        '$SOAPACTION$',method.soapAction,...
        '$OUTPUT$',outputString,...
        '$INPUT$',inputString, ...
        '$PARAMETERDEFINITION$',parameterDefinition, ...
        '$STYLE$',R.style, ...
        '$DOCUMENTATION$',method.documentation};
    template = originalTemplate;
    for i = 1:2:length(replacements)
        template = strrep(template,replacements{i},char(replacements{i+1}));
    end
    writemfile(['@' R.name filesep methodNames{iMethod} '.m'],template);
end


%===============================================================================
function status = writemfile(fname,C)
% Write a cell to file.

C = cellstr(C);
count = 0;
fid = fopen([pwd filesep fname],'w');
for i = 1:length(C);
    count = count + fprintf(fid,'%s\n',C{i});
end
status = fclose(fid);
if (count~=(sum(cellfun('length',C))+length(C))) || (status==-1)
    error(message('MATLAB:createClassFromWsdl:WriteError', fname))
end

