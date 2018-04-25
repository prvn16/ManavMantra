function classFcn = createWSDLClient(wsdlURL, varargin)
    %matlab.wsdl.createWSDLClient Generate interface to SOAP-based web service
    %   CLASSFCN = matlab.wsdl.createWSDLClient(WSDLURL) creates an interface to a
    %   web service based on a WSDL specification.  WSDLURL may be a URL or a file
    %   path to a WSDL document.  This function creates a MATLAB class file for each
    %   SOAP binding in the WSDL and possibly a support package.  The generated
    %   MATLAB files and folders are placed in the current folder.  Any
    %   previous files with the same names as the generated ones will be overwritten.
    %   CLASSFCN is a handle to the class that was created, or a cell array of
    %   handles if multiple classes were created.  Use 'help' on the class name to
    %   get more information on usage.
    %
    %   CLASSFCN = matlab.wsdl.createWSDLClient(WSDLURL,FOLDER) places the files in
    %   the specified FOLDER, creating it if it doesn't exist.  Any pre-existing
    %   files in FOLDER whose names do not conflict with generated files are
    %   preserved.  If FOLDER is [] the current folder is used.
    %
    %   CLASSFCN = matlab.wsdl.createWSDLClient(WSDLURL,FOLDER,'silent') suppresses
    %   printing names of the generated files and folders.
    %
    %   CLASSFCN = matlab.wsdl.createWSDLClient(WSDLURL,OPTIONS)
    %   CLASSFCN = matlab.wsdl.createWSDLClient(WSDLURL,OPTIONS,FOLDER)
    %   CLASSFCN = matlab.wsdl.createWSDLClient(WSDLURL,OPTIONS,FOLDER,'silent')
    %   In the above usages OPTIONS is a weboptions object specifying additional
    %   information needed to access the WSDL document, such as Username, Password
    %   and Timeout.
    %               
    %   In order to use this function for the first time, you must install the Java
    %   JDK and Apache CXF and specify their locations to
    %   matlab.wsdl.setWSDLToolPath.
    %
    %   You only need to run this function once for a given web service.  You can
    %   package the generated files and distribute them to other MATLAB users.
    %  
    %   Example
    %   ---------
    %   % Create a class for the stockquote web service provided by webservicex.net:
    %   url = 'http://www.webservicex.net/stockquote.asmx?WSDL'; 
    %   matlab.wsdl.createWSDLClient(url)
    %
    %   % Instantiate the service object.
    %   service = StockQuote;
    %
    %   % Get help on functions and parameters:
    %   doc StockQuote 
    %   help StockQuote 
    %   help StockQuote.GetQuote
    %
    %   % Call desired function.
    %   QetQuote(service, 'GOOG')
    %
    %   See also webread, matlab.wsdl.setWSDLToolPath, weboptions
   
    % Copyright 2014-2016 The MathWorks, Inc.
    
    % Please note that additional arguments not documented above are for internal use
    % only.
    
    % Ensure Java is available.
    error(javachk('jvm',mfilename))

    import java.io.File
    debug = false;
    validate = false;
    wsdlURL = strtrim(wsdlURL);
    
    wsdl = wsdlURL;
    
    silentState = false;
    destDir = '.';
    timestamp = datestr(now);
    wsdlFileMsg = wsdl;
    
    validateattributes(wsdl(~isspace(wsdl)), {'char'}, {'nonempty','row'}, 'webservices', 'wsdlURL', 1);
    
    webOptions = [];
    nextArgType = 1; % relative argument position for folder, silent, and debug args
    
    % Save the arguments following the wsdlURL
    for i = 1 : length(varargin)
        arg = varargin{i};
        if isempty(webOptions) && isa(arg,'weboptions')
            % allow weboptions arg to be anywhere, but just once
            webOptions = arg;
        else
            if nextArgType == 1
                % first one must be folder name, but can be empty to use pwd
                folder = arg;
                if ~isempty(folder)
                    validateattributes(folder(~isspace(folder)), {'char'}, {'row'}, 'webservices', 'folder', i+1);
                    destDir = folder;
                end
                nextArgType = 2;
            else
                % -debug and -validate args can be anywhere after folder name
                if strcmp(arg,'-debug')
                    debug = true;
                elseif strcmp(arg,'-validate')
                    validate = true;
                else
                    switch nextArgType
                        case 2
                            % next must be 'silent' or empty
                            silent = arg;
                            if ~isempty(silent) 
                                validatestring(silent, {'silent'}, 'webservices', 'silent', i+1);
                                silentState = true;
                            end
                            nextArgType = 3;
                        case 3
                            % Args after this are used for the benefit of QE tests, 
                            % so that generated files have predictable data. 
                            % A timestamp string to place in generated files; default
                            % is datestr(now)
                            validateattributes(arg, {'char'}, {'nonempty','row'}, 'webservices', 'timestamp', i+1);
                            timestamp = arg;
                            nextArgType = 4;
                        case 4
                            % The name of the WSDL file to put in generated files; 
                            % default is wsdlURL
                            validateattributes(arg, {'char'}, {'nonempty','row'}, 'webservices', 'filename', i+1);
                            wsdlFileMsg = arg;
                            nextArgType = 5;
                        otherwise
                            error(message('MATLAB:maxrhs'));
                    end
                end
            end
        end
    end
        
    % This validates and gets the paths for JDK and CXF (or JAVA_HOME and CXF_HOME,
    % if set).
    paths = matlab.wsdl.setWSDLToolPath('CXF','-validate');
    oldJavaHome = getenv('JAVA_HOME');
    if isempty(oldJavaHome) 
        oldJavaHome = '';
    end
    % Small bug: this cleanup handler that attempts to restore JAVA_HOME sets an
    % empty JAVA_HOME value on Unix if it was undefined.  No way to
    % avoid that because CXF requires us to set JAVA_HOME and there is no
    % unsetenv.
    javaHomeCleanup = onCleanup(@() setenv('JAVA_HOME', oldJavaHome));
    setenv('JAVA_HOME',paths.JDK);
    cxfDir = paths.CXF;
    
    jdestDir = File(destDir);
    if jdestDir.isAbsolute
        fullDestDir = destDir;
    else
        fullDestDir = fullfile(pwd,destDir);
    end

    if exist(fullDestDir,'dir') ~= 7 && exist(fullDestDir,'file') > 0
        error(message('MATLAB:webservices:FileExistsCantCreateFolder', destDir));
    end
    
    try 
        [localWSDL, istemp] = wsdlread(wsdlURL,webOptions);
    catch e
        error(message('MATLAB:webservices:CannotAccessWSDL', wsdlURL, e.message));
    end
    if istemp
        cleanWSDL = onCleanup(@() delete(localWSDL));
    end
    
    % Build everything in a temp dir so as not to disturb the destination in case
    % there is an error.
    myTempDir = tempname;
    javaTempDir = [myTempDir filesep 'java'];
    
    % For the MATLAB package and Java jar file name, we'll use a lowercase
    % version of the tail end of the URL, minus any query part
    [~, pkgName] = fileparts(wsdlURL);
    pkgName = matlab.lang.makeValidName(lower(regexprep(pkgName,'?.*$','')));
    while isempty(pkgName)
        pkgName = input('%s ',message('MATLAB:webservices:EnterPkgName').getString);
    end
    
    javaJar = [pkgName '.jar'];
    
    % 'true' here makes rmdir think it has an output, so it won't
    % warn if tempDir already removed
    rmdirCleanup = onCleanup(@() true && rmdir(myTempDir,'s'));
    
    % Run wsdl2java to create Java classes for the WSDL.  Java source and class files
    % go in javaTempDir and the classes are also in javaJar.
    if exist('cxf.xml', 'file')
        % CXF will be confused if working directory happens to have a cxf.xml file
        oldwd = pwd;
        cd(matlabroot);
        cwdCleanup = onCleanup(@() cd(oldwd));
    end
    if ismac
        % On the Mac, this path set in the MATLAB environment messes up wsdl2java
        oldpath = getenv('DYLD_LIBRARY_PATH');
        pathCleanup = onCleanup(@() setenv('DYLD_LIBRARY_PATH',oldpath));
        setenv('DYLD_LIBRARY_PATH','');
    end
    if validate
        validateOpt = '-validate';
    else
        validateOpt = '';
    end
    [status, msg] = system(sprintf(...
      '"%s" -client -d %s -clientjar ..%s%s -fe jaxws21 -b "%s" %s -p %s -autoNameResolution -compile "%s"', ...
      fullfile(cxfDir,'bin','wsdl2java'), javaTempDir, filesep, javaJar, ...
      fullfile(fileparts(mfilename('fullpath')), 'private', 'bindings.txt'), ...
      validateOpt, pkgName, localWSDL));
    clear cwdCleanup pathCleanup javaHomeCleanup

    % wsdl2java doesn't necessarily return a nonzero status code when it fails, so
    % determine whether it worked by checking if it generated at least one class file
    % in the javaTempDir/pkgName and didn't return a message with the word "Error"
    if ~exist(javaTempDir,'dir') || status ~= 0 || ...
            ~exist(fullfile(javaTempDir,pkgName),'dir') || ...
            isempty(dir(fullfile(javaTempDir,pkgName,'*.class'))) || ...
            (~isempty(msg) && ~isempty(strfind(msg,'Error')))
        % Extract and possibly edit the wsdl2java error message and put it in our own
        % exception.
        if regexp(msg, 'WSDLToJava Error', 'once')
            % Remove the "WSDLToJava Error" part of the message, if any
            msg = regexprep(msg, '^.*WSDLToJava Error: ', '');
            if regexp(msg, 'Rpc/encoded wsdls are not supported with CXF', 'once')
                % RPC encoding error can be handled by our own message
                error(message('MATLAB:webservices:NoRPCEncoded'));
            elseif regexp(msg, 'Failed to compile','once')
                % wsdl2java may fail if the current directory contains a folder with
                % the same name as the package we're generating.
                if exist(pkgName,'dir') 
                    error(message('MATLAB:webservices:TryDeletingDir',pkgName));
                else
                    error(message('MATLAB:webservices:FailedToCompile'));
                end
            end
        end
        % Remove the apache exception string
        newmsg = regexprep(msg, 'org.apache.*WSDLRuntimeException:.*Caused by : ', '');
        error(message('MATLAB:webservices:WSDLError',newmsg));
    end
    
    fullPkgName = ['wsdl.' pkgName];
    
    % Parse the WSDL file, returning info R(i) for each binding and the whole schema
    % collection
    [R, schemaCol] = parseWsdl(localWSDL, wsdlURL, fullPkgName, javaTempDir, pkgName);
    clear cleanWSDL
    
    % Create support classes and get getter (convenience method) info
    [getters, classesUsed] = ...
        makeClasses(myTempDir, fullPkgName, wsdlFileMsg, R, schemaCol, javaTempDir, ...
                    pkgName, timestamp);
            
    % Create the service class for each binding
    for i = 1 : length(R)
        % This makes the methods of the service R(i)
        [methods, methodHelp] = makeMethods(R(i), fullPkgName);
        % This makes convenience getters for any objects that the user might
        % need to create when invoking a service method or a method of one of
        % the generated classes.
        % Each service class gets the same getters, because we don't know
        % which ones will be needed by any particular binding.
        [getterCode, getterHelp] = makeGetters(getters, fullPkgName, classesUsed);
        if ~isempty(getterHelp)
            methodGetterHelp = strjoin([methodHelp ...
                sprintf('    %%\n    %% Static methods:\n    %%') ...
                getterHelp], '\n');
        else
            methodGetterHelp = strjoin(methodHelp, '\n');
        end
        
        makeServiceClass(pkgName, fullPkgName, javaTempDir, myTempDir, R(i), methods, ...
                         getterCode, methodGetterHelp, timestamp, wsdlFileMsg);
    end
    
    % Now that everything is OK, remove the destination +wsdl/+pkgName subdirectory in
    % destDir so that we can replace it with the new copy.  Leave other stuff in
    % destDir and wsdlDir unchanged.
    notRemoved = false;
    wsdlDir = fullfile(destDir, '+wsdl');
    pkgDir = fullfile(wsdlDir, ['+' pkgName]);
    pkgTempDir = fullfile(myTempDir, '+wsdl', ['+' pkgName]);
    
    if exist(pkgDir,'dir') > 0
        w = warning('query','MATLAB:RMDIR:RemovedFromPath');
        oldstate = w.state;
        warning('off','MATLAB:RMDIR:RemovedFromPath');
        cleanWarning = onCleanup(@() warning(oldstate,'MATLAB:RMDIR:RemovedFromPath'));
        try 
            success = rmdir(pkgDir, 's');
        catch
            notRemoved = true;
        end
        if ~success
            notRemoved = true;
        end
        clear cleanWarning;
    end
    
    % Make the +wsdl directory if there isn't one
    if exist(wsdlDir,'dir') == 0
        mkdir(wsdlDir);
    end
    
    if exist(pkgTempDir,'dir') > 0
        % If a +pkgDir directory was created in tempDir (i.e., there were derived
        % classes), then move everything in the pkg directory to the destination
        if notRemoved
            % If we couldn't remove the destination directory for some reason,
            % just move contents into it.
            [success, msg] = movefile(fullfile(pkgTempDir, '*'), pkgDir, 'f');
        else
            % The normal case: move the temp dir to the new directory
            
            % Due to a problem on Windows, perhaps related to a network file system,
            % movefile sometimes returns success=false with msg="Cannot create a file
            % when that file already exists."  It sometimes returns this even when it
            % works.  This shouldn't be possible since we removed the destination
            % pkgDir up above.  Trying multiple times seems to work, so keep trying
            % as long as the source directory still exists.  This needlessly tries
            % 100 times for other rare errors (e.g., file system full).
            for count = 1 : 100
                [success, msg] = movefile(pkgTempDir, pkgDir, 'f');
                if ~exist(pkgTempDir,'dir') 
                    % if the source is gone, trying again won't help, so break out
                    % but assume success if the destination now exists
                    success = exist(pkgDir,'dir');
                    break;
                end
                if success
                    break;
                end
            end
        end

        if ~success
            warning(message('MATLAB:webservices:CouldNotMoveToDest',pkgDir,strtrim(msg)));
            % if move failed, maybe a copy will work
            if notRemoved
                [success, msg, msgID] = copyfile([pkgTempDir filesep '*'], pkgDir, 'f');
            else
                % Copy the temp dir to the new directory
                [success, msg, msgID] = copyfile(pkgTempDir, pkgDir, 'f');
            end
            % for some reason the move above says it failed even though worked,
            % so assume it worked if temp dir is gone
            if ~success && exist(pkgTempDir,'dir')
                error(msgID,'%s',strtrim(msg));
            end
        end
    end
    
    % copy the Java jar to the +wsdl directory
    copyfile(fullfile(myTempDir, javaJar), wsdlDir);
    
    % copy the top level .m files to the destination (above the +wsdl directory)
    copyfile(fullfile(myTempDir, '*.m'), destDir); 
    
    if debug
        % if debugging, copy the source files; javaTempDir will likely contain a
        % single package directory with the java and class files.
        copyfile(javaTempDir, destDir);
    end

    if ~silentState
        fprintf('\n');

        % Display names of generated files, mentioning the binding name if > 1 binding
        % and the destDir if the top level class is not on the path.
        dirname = [];
        if exist(R(1).className,'class') == 0 
            % generated class not on path, print directory name
            if strcmp(destDir,'.')
                dirname = message('MATLAB:webservices:CurrentFolder').getString;
            else
                dirname = destDir;
            end
        end
        if length(R) > 1
            if ~isempty(dirname)
                arrayfun(@(r) fprintf('%s\n', message('MATLAB:webservices:CreatedXInYForZ', ...
                         r.className, r.className, dirname, r.bindingName).getString), R);
            else
                arrayfun(@(r) fprintf('%s\n', message('MATLAB:webservices:CreatedXForZ', ...
                         r.className, r.className, r.bindingName).getString), R);
            end
        else
            if ~isempty(dirname)
                fprintf('%s\n', message('MATLAB:webservices:CreatedXInY', ...
                     R(1).className, R(1).className, dirname).getString);
            else
                fprintf('%s\n', message('MATLAB:webservices:CreatedX', ...
                     R(1).className, R(1).className).getString);
            end
        end

        % Display the .m files at the top level
        arrayfun(@(x) ~x.isdir && x.name(1) ~= '.' && ...
                     fprintf('  %s%s%s\n', destDir, filesep, x.name), ...
                     dir([myTempDir filesep '*.m']));
        if debug
            % display all the other files
            fprintf('  %s\n', fullfile(wsdlDir, javaJar)); 
            arrayfun(@(x) ~x.isdir && x.name(1) ~= '.' && ...
                         fprintf('  %s%s%s\n', pkgDir, filesep, x.name), ...
                         dir(pkgDir));
        else
            % display just the top level directory name for the package
            fprintf('  %s\n', wsdlDir);
        end
    end
    
    if exist(myTempDir,'file') > 0
        try
            clear cleanDir
        catch  
            if ~silentState
                fprintf('\n%s\n\n', ...
                    message('MATLAB:webservices:TempFolderNotRemoved', myTempDir).getString);
            end
        end
    end
    
    % Tell user to add JAR file to classpath if it's not already there.  Comparison
    % is by absolute path.
    fullJarPath = fullfile(wsdlDir, javaJar);
    absJarPath = File(fullJarPath);
    if ~absJarPath.isAbsolute
        absJarPath = File(fullfile(pwd,fullJarPath)).getCanonicalFile;
    end
    jpath = javaclasspath('-all');
    if ~silentState && ~any(cellfun(@(x) absJarPath.equals(File(x).getCanonicalFile), jpath))
        fprintf('\n');
        disp(message('MATLAB:webservices:AddClasspath', R(1).serviceName, ...
                     fullJarPath, fullJarPath).getString);
    end        
    
    % Whether or not the jar is there, see if the service class is already on the path
    serviceClass = com.mathworks.jmi.OpaqueJavaInterface.findClass([R(1).servicePkg '.' R(1).className]);
    if ~isempty(serviceClass)
        % If it's on the path, see what jar file it's in
        try 
            serviceJar = File(serviceClass.getProtectionDomain.getCodeSource.getLocation.getFile);
            if ~serviceJar.getCanonicalFile.equals(absJarPath)
                % It's a different jar, so warn
                fprintf('\n');
                warning(message('MATLAB:webservices:AnotherJar', R(1).serviceName, ...
                    char(absJarPath.toString), char(serviceJar.toString)));
            end
        catch 
            % ignore Java errors: security exceptions and null results
        end
    end

    % Return handles to the created classes
    
    if length(R) == 1
        classFcn = eval(['@' R.className]);
        checkClassInPath(destDir, R.className, silentState);
    else
        classFcn = cell(1,length(R));
        for i = 1 : length(R)
            classFcn{i} = eval(['@' R(i).className]);
            checkClassInPath(destDir, R(i).className, silentState);
        end
    end
end    

%===============================================================================
function [struct, schemaCol] = parseWsdl(localWSDL, wsdlURL, pkgname, javaDir, javaPkg)
    % Parse the WSDL, returning information about the methods and parameters:
    %   localWsdl: path to local copy of the WSDL file
    %   wsdlURL:   the WSDL URL as the user specified it
    %   pkgname:   the MALTLAB package name
    %   javaDir:   location where Java .class files are located
    %   javaPkg:   Java package name
    % Returns:
    %   struct:    array of structures of parsed WSDL, one per binding
    %             serviceName: 'HelloWorld' (same for all bindings)
    %             bindingName: 'HelloWorldImplPortBinding'
    %               className: 'HelloWorld1' name of the top level MATLAB class for binding
    %            wsdlLocation: 'http://com.mathworks.myhost/myHelloWorld?wsdl'
    %                endpoint: 'http://com.mathworks.myHost/myHelloWorld'
    %     serviceNamespaceURI: 'http://server.hw.demo/'
    %              servicePkg: 'demo.hw.server'
    %                portName: 'HelloWorldImplPort'
    %                   style: [1x1 java.lang.String]
    %                 methods: [1xN struct] for each method
    %
    %     method:
    %            javaMethodName: 'sayHi' (the Java function to call)
    %                methodName: 'SayHi' (from the WSDL, uniquified)
    %                     input: [1xN struct] one per parameter
    %                    output: [1xN struct] one per output
    %                   wsdlDoc: any doc from WSDL (becomes part of H1 line)
    %             documentation: wsdlDoc plus input and output parameter doc
    %        targetNamespaceURI: 'http://server.hw.demo/'
    %                soapAction: ''
    %
    %        where method.input or method.output has structure array from extractParams
    %   schemaCol:  XmlSchemaCollection
    
    % Parse and process WSDL file. 
    wsdlFactory = javax.wsdl.factory.WSDLFactory.newInstance(); 
    wsdlReader = wsdlFactory.newWSDLReader(); 
    % turn off verbosity, so we don't get a 'Retrieving document...' from wsdl4j
    wsdlReader.setFeature('javax.wsdl.verbose', false);

    try
        definition = wsdlReader.readWSDL(localWSDL);
        defTypes = definition.getTypes();
        imports = definition.getImports();
        if ~isempty(imports) && ~isEmpty(imports)
            warning(message('MATLAB:webservices:NoImports'));
        end
        len = defTypes.getExtensibilityElements().size();
        schemaCol = org.apache.ws.commons.schema.XmlSchemaCollection();
        extElements = defTypes.getExtensibilityElements();
        for i = 0 : len-1
            extElement = extElements.get(i).getElement(); 
            schemaCol.read(extElement); 
        end
    catch e
        if(isa(e, 'matlab.exception.JavaException'))
            exception = e.message;
            if ~isempty(exception)
                if regexp(exception, ...
                        '^java.net.ConnectException: Connection refused: connect','once')
                    error(message('MATLAB:webservices:ConnectionRefused'));
                end
                if regexp(exception, ...
                        'ice.net.URLNotFoundException: Document not found on server','once')
                    error(message('MATLAB:webservices:URLNotFound'))
                end
                host = regexp(exception,'java.net.UnknownHostException: (.*)','tokens','once');
                if ~isempty(host)
                    error(message('MATLAB:webservices:UnknownHost', host{ 1 }))
                end
                sax = regexp(exception,'org.xml.sax.SAXException: (.*)','tokens','once');
                if ~isempty(sax)
                    error(message('MATLAB:webservices:BadXml', sax{1}))
                end
                error(message('MATLAB:webservices:Exception',exception))
            else
                rethrow(e)
            end
        else
            rethrow(e)
        end
    end 

    % delete the tmp wsdl
    clear c;

    symbolTable = definition.getBindings.values;
 %   typeData = definition.getTypes; 

    % This is the structure to return.
    struct = [];

    % Extracting information about each binding to create a MATLAB class.
    it = symbolTable.iterator();
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
            while portIterator.hasNext
                testPort = portIterator.next;
                if binding.getQName.equals(testPort.getBinding.getQName)
                    % Found it.  Keep variables port and service.
                    port = testPort;  % javax.wsdl.port (com.ibm.wsdl.PortImpl)
                    break
                end
            end
        end

        % Skip bindings with no ports.
        if isempty(port)
            continue
        end

        % Determine the MATLAB object name (className) for the binding from the service name, 
        % everything after the last '.' in the local part of the name. 
        serviceName = char(service.getQName.getLocalPart);
        className = makeValidName(serviceName(max([0 find(serviceName == '.')])+1:end),'Svc');
        % If there's more than one SOAP binding, append a number to the name
        bindingNum = length(struct);
        if bindingNum > 1
            className = sprintf('%s%d', className, bindingNum);
        end
        
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
            % TODO: No need keep both SOAP 1.2 bindings and SOAP 1.1 bindings.  Just
            % use the 1.2 version if there is one.
            if isa(extension,'javax.wsdl.extensions.soap.SOAPOperation') || ...
                    isa(extension,'javax.wsdl.extensions.soap12.SOAP12Operation')
                soapOperation = extension;
            else
                % Not a SOAP operation.  Skip.
                continue
            end
            op = makeOperation(className, operation,pkgname,schemaCol,javaDir,javaPkg);
            soapBody = bindingOperation.getBindingInput.getExtensibilityElements.elementAt(0);
            % add targetnamespaceURI and soapAction fields to op
            op.targetNamespaceURI = char(soapBody.getNamespaceURI);
            if isempty(op.targetNamespaceURI)
                op.targetNamespaceURI = char(definition.getTargetNamespace);
            end
            op.soapAction = char(soapOperation.getSoapActionURI);
            ops = append(ops, op);
        end
        % If there are SOAP operations defined, add binding to the list.
        if ~isempty(ops)
            % Go back and alter all the MATLAB method names to make them unique within this
            % binding 
            methodNames = makeValidName({ops.methodName},'Fcn');
            methodNames = matlab.lang.makeUniqueStrings(methodNames);
            for i = 1 : length(ops)
                methodName = methodNames{i};
                ops(i).methodName = methodName; %#ok<AGROW>
            end
            struct(end+1).serviceName = serviceName; %#ok<AGROW>
            struct(end).className = className;
            struct(end).bindingName = char(binding.getQName.getLocalPart);
            struct(end).wsdlLocation = wsdlURL;
            struct(end).endpoint = char(port.getExtensibilityElements.elementAt(0).getLocationURI);
            uri = char(service.getQName.getNamespaceURI);
            struct(end).serviceNamespaceURI = uri;
            % The Java service package name generated by Apache CXF is an algorithmic transformation of the
            % namespace URI, implemented by PackageUtils.
            struct(end).servicePkg = javaPkg;%char(org.apache.cxf.common.util.PackageUtils.getPackageNameByNameSpaceURI(uri));
            pn = char(port.getName);
            struct(end).portName = mangleName(pn,1);
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
    end
    if length(struct) > 1 
        % add 1 to first binding name since we didn't know at the time there were
        % multiples.
        struct(1).className = [struct(1).className '1'];
    end

end


%===============================================================================
function op = makeOperation(className, operation, pkgname, schemaCol, javaDir, javaPkg)
    % Return information about an operation, including documentation of its
    % parameters and return values.
    %   className - name of the MATLAB class generated for this service
    %   javaDir   - pathname of the Java source directory
    %   javaPkg   - name of the Java package (a directory in javaDir)
    % Returns 
    %   op.methodName - name based on WSDL (not necessarily final MATLAB method name)
    %   op.javaMethodName - same, mangled
    %   op.wsdlDoc - any documentation from WSDL, or empty
    %   op.input  - information and array of structs about message parts (see extractParams)
    %   op.output - same as op.input
    %   op.documentation - doc of arguments and return values
    op = [];
    if ~isequal(operation.getStyle,javax.wsdl.OperationType.REQUEST_RESPONSE)
        return
    end

    name = char(operation.getName);
    op.methodName = name;
    op.javaMethodName = mangleName(name,-1);

    % Create documentation for MATLAB file help.
    if isempty(operation.getDocumentationElement)
        op.wsdlDoc = '';  
    else
        op.wsdlDoc = char(operation.getDocumentationElement.getTextContent);
    end
    doc = sprintf('\n');
 
    % Calling parameters:
    op.input = extractParams(operation.getInput(),schemaCol,javaDir,javaPkg,pkgname);
    doc = sprintf('%sInputs:\n  obj - %s object\n', ...
                          doc, className);
    if ~isempty(op.input)
        doc = buildDoc(doc, op.input, 2);
    end
    
    % Return parameters:
    op.output = extractParams(operation.getOutput(),schemaCol,javaDir,javaPkg,pkgname);
    if ~isempty(op.output)
        if length([op.output.params]) > 1
            doc = sprintf('%sOutputs:\n', doc);
        else
            doc = sprintf('%sOutput:\n', doc);
        end
        doc = buildDoc(doc, op.output, 2);
    end

    % Save the documentation for the MATLAB file help.
    doc = regexprep(doc,'\s*$','');
    % Insert the comment character % in front of each line, so that appears
    % in the right column and indent each parameter line
    doc = regexprep(doc,'\n','\n        %    ');
    op.documentation = doc;
end

%===============================================================================
% Extracts the parameter type information into a list from the wsdl and
% schema where necessary. 
%   params      javax.wsdl.Input or javax.wsdl.Output
%   ret         array of structs about message parts (this gets plugged into 
%               method.input or method.output)
%      partName     name of part
%      isNillable   true if nillable (not set by minOccurs = 0)
%      partType     name of the part's type; empty if anonymous
%      exists       true if part is defined as complex type, even if empty
%      javaPkg      Java package name for part
%      params       array of structs about parameters in this part
%         name        name of parameter
%         type        its schema type (QName)
%         javaClass   its Java class name, if isDerived
%         javaPkg     its Java package name, if isDerived
%         matlabClass fully qualified name of corresponding MATLAB class
%         isArray     true if array
%         isNillable  true minOccurs == 0 || nillable
%         isDerived   true if derived (has javaClass)
function ret = extractParams(params, schemaCol, javaDir, javaPkgName, pkgname) 
    % This returns java.util.List of message parts
    inputParamNames = params.getMessage().getOrderedParts([]); 
    retListIndex = 0;
    if inputParamNames.size() == 0
        ret = [];
        return;
    end
    retList(inputParamNames.size()) = struct('partName',[],'partType',[],...
                                        'javaPkg',[],'isNillable',false,'params',[]);
    if ~isempty(inputParamNames) 
        iterator = inputParamNames.iterator; 
        while (iterator.hasNext) 
            msgPart = iterator.next(); 
            %isArray = false; 
            if (~isempty(msgPart.getName()) || ~isempty(msgPart.getTypeName)) 
                qname = msgPart.getElementName();
                if (~isempty(qname))
                    xElement = schemaCol.getElementByQName(qname);
                    [parameters,partType,isComplex] = extractTypeFromSchemaElement(schemaCol,javaDir,...
                                                              javaPkgName,xElement);
                    localName = qname.getLocalPart;
                    nillable = xElement.isNillable;
                else % we may be parsing rpc style
                    if (isempty(msgPart.getName()))                     
                       error(message('MATLAB:webservices:MissingQName',msgPart.getName()));
                    end
                    nillable = true;
                    localName = msgPart.getName();
                    parameters = extractTypeFromSchemaComplexType(...
                                               javaDir,javaPkgName,msgPart,schemaCol); 
                    partType = msgPart.getTypeName(); 
                end
                % Insert the pkg.name of the MATLAB class that we should generate
                % for each derived type.  Create a part if it's defined as a complex
                % type, even if there are no parameters
                if (~isempty(parameters) || isComplex)
                    for i = 1 : length(parameters)
                        param = parameters(i);
                        if param.isDerived
                            parameters(i).matlabClass = sprintf('%s.%s', ...
                                pkgname, makeValidName(param.javaClass,'Object')); 
                        else
                            parameters(i).matlabClass = '';
                        end
                    end
                    retListIndex = retListIndex+1;
                    retList(retListIndex) = ...
                                     struct('partName', char(localName), ...
                                            'partType', partType, ...
                                            'javaPkg', javaPkgName, ... 
                                            'isNillable', nillable, ...
                                            'params', parameters); 
                end
            end

        end        
    end
    ret = retList(1:retListIndex);
end

%===============================================================================
% Searches the schema for the type specified in the msgPart
% This is invoked when parsing document style literal encoded wsdl
% Returns a struct:
%         name      name of parameter
%         type      its schema type (QName)
%         javaClass Java class name, if isDerived
%         isArray   true if array
%         isNillable  true if minOccurs == 0 || nillable
%         isDerived true if derived (has javaClass)

function retList = extractTypeFromSchemaComplexType(javaDir,javaPkgName,msgPart,schemaCol) 
    schemaType = schemaCol.getTypeByQName(msgPart.getTypeName());
    if isempty(schemaType)
        % if it's not in the schema for some reason, 
        javaClass = getJavaClassForType(javaDir,javaPkgName,msgPart.getTypeName());
    else
        javaClass = getJavaClassForType(javaDir,javaPkgName,schemaType);
    end
    isDerived = ~isempty(javaClass);
    if (isSchemaType(schemaType,'ComplexType') && ...
            ~isempty(schemaType) && ~isempty(schemaType.getContentModel()))
        restriction = schemaType.getContentModel().getContent();
        nextName = char(msgPart.getName()); 
        isArray = false; 
        attr = restriction.getAttributes().getItem(0);
        %nextType = char(attr.getName()); 
        rawTypes = attr.getUnhandledAttributes(); 
        if (numel(rawTypes) > 0)    
            type = char(rawTypes(1));   
            if (regexp(type,']','once'))
                isArray = true;
            end
            [~, second ] = find(type == '"');
            nextType = type(second(1)+1:second(2)-3);
            % fix for g517416: which had a problem with rpc/soap-encoded arrays
            nextType = regexprep(nextType,'xsd:','{http://www.w3.org/2001/XMLSchema}');
            nextOp = struct('name',nextName, 'type',nextType, ...
                'javaClass',javaClass, 'isArray',isArray, ...
                'isNillable',true, 'isDerived',isDerived');
            retList = nextOp;    
        end
    elseif (regexp(char(msgPart.getTypeName()),'http://www.w3.org/.*/XMLSchema.*', 'once'))
        % Then we're looking at a simple type described in the base level www schema
        nextName = char(msgPart.getName()); 
        nextType = char(msgPart.getTypeName());
        isArray = false; 
        nextOp = struct('name',nextName, 'type',nextType, 'javaClass',javaClass, ... 
            'isArray',isArray, 'isNillable',true, 'isDerived',isDerived);
        retList = nextOp;
    else % Exercised by rpc style literal encoded test wsdl
        nextName = char(msgPart.getName());  
        nextType = char(msgPart.getTypeName().getLocalPart()); 
        % TODO: adjust this isArray logic. But to do this, we need a sample to
        % exercise it. 
        isArray = false; 
        nextOp = struct('name',nextName, 'type',nextType, 'javaClass',javaClass, ...
            'isArray',isArray, 'isNillable',true, 'isDerived',isDerived);
        retList = nextOp;   
    end
end

%===============================================================================
% Searches the schema for the type specified in the msgPart
% function [retList,partType] = extractTypeFromSchemaElement(schemaCol,javaDir,javaPkgName,xElement) 
%    retList: array of structs
%       name       name of the part, e.g. 'arg0'
%       type       QName of its schema type
%       javaClass  class name (if isDerived)
%       javaPkg    package for javaClass
%       isArray    true if array (maxOccurs > 1)
%       isNillable true if minOccurs > 0 && ~nillable
%       isDerived  true if we have an MCOS/Java class for its type
%    partType: name of the part's type; empty if anonymous
function [retList,partType,isComplex] = extractTypeFromSchemaElement(schemaCol,javaDir,javaPkgName,xElement)
    retList = []; 
    partType = [];
    isComplex = false;
    if (~isempty(xElement)) 
        if (isSchemaType(xElement, 'Element') &&...
                isSchemaType(xElement.getSchemaType(),'ComplexType'))
            eTypes = xElement.getSchemaType();
        elseif (isSchemaType(xElement, 'ComplexType'))
            eTypes = xElement; 
        else
            eTypes = [];
        end
        if (~isempty(eTypes)) 
            isComplex = true;
            partType = char(eTypes.getName);
            particle =  eTypes.getParticle();
            if (~isempty(particle)) 
                typeIterator = particle.getItems().getIterator();
                while (typeIterator.hasNext()) 
                    tElement = typeIterator.next();
                    nextName = char(tElement.getName()); 
                    schemaType = getSchemaType(particle.getSourceURI, schemaCol, tElement);
                    if ~isempty(schemaType) 
                        nextType = char(schemaType.getQName());
                        if isempty(nextType) 
                            nextType = tElement.getRefName();
                            if isempty(nextType)
                                warning(message('MATLAB:webservices:NoAnonymousTypes',nextName,'schema',nextName));
                                continue;
                            end
                        end
                        if isempty(schemaType.getName)
                            schemaType = nextType;
                        end
                        javaClass = getJavaClassForType(javaDir, javaPkgName, schemaType);
                        isDerived = ~isempty(javaClass);
                        isArray = tElement.getMaxOccurs() > 1;
                        isNillable = tElement.getMinOccurs() == 0 || tElement.isNillable;
                        nextOp = struct('name', nextName, 'type', nextType, ...
                            'javaClass', javaClass, 'javaPkg', javaPkgName, 'isArray', isArray, ...
                            'isNillable', isNillable, 'isDerived', isDerived);
                        retList = append(retList, nextOp);
                    end
                end    
            end
        end % this condition fails to be met when there's no subtype, e.g. in null return types    
    end
end

%===============================================================================
function doc = buildDoc(doc, parts, indent, prefix)
    % Add a line of documentation of for each parameter described in parts
    %   doc    - doc we're appending to
    %   parts  - array of structs about message parts (see extractParams)
    %   indent - (int) amount of indent betwixt % and name
    %   prefix - text prepended to name, used in recursive calls when
    %            parameter type is an array of structs; otherwise missing

    if isempty(parts)
        return
    end
    x = [parts.params]; % document just the parameters, ignoring the message parts
    for i = 1:length(x)
        if isstruct(x(i).type)
            if x(i).isArray
                array = '(:)';
            else
                array = '';
            end
            doc = buildDoc(doc, x(i).type, indent, [x(i).name array '.']);
        else
            if x(i).isArray
                array = '(:)';
            else
                array = '';
            end
            doc = char(doc);
            if nargin < 4
                prefix = '';
            end
            localName = char(getLocalName(x(i).type));
            if x(i).isDerived
                matlabDesc = sprintf('<a href="matlab:doc %s">%s</a> object', ...
                    x(i).matlabClass, regexprep(x(i).matlabClass, '^.*\.','')); 
                if x(i).isArray
                    matlabDesc = ['vector of ' matlabDesc]; %#ok<AGROW>
                end
            else
                matlabDesc = getMATLABArgDescription(localName, x(i).isArray);
            end
            doc = sprintf('%s%*s%s - %s\n', ...
                doc, indent, ' ', [prefix char(x(i).name) char(array)], matlabDesc);
        end
    end
end

%===============================================================================
function s = getLocalName(s)
    % Remove the namespace part of a QName, which can be a Java string or char
    s = regexprep(char(s),'.*[}:>]','');
end

%===============================================================================
function makeServiceClass(pkgName, fullPkgName, javaDir, dirname, R, methods, ...
                          getterCode, methodHelp, timestamp, wsdlFileMsg)
    % Create a constructor and methods from a structure derived from a WSDL
    %    pkgname     last part of package name
    %    fullPkgName full package name
    %    destdir     the name of the directory where the service class goes 
    %    dirname     the full path of the directory where the service class goes
    %    R           structure from parseWsdl
    %    getterCode  code for all the static convenience get methods 
    %    methodHelp  help for the method
    %    timestamp   timestamp for generated file
    
    tf = fullfile(fileparts(mfilename('fullpath')),'private','wsdlconstructor.mtl');
    fid = fopen(tf);
    cleanup = onCleanup(@()fclose(fid));
    template = textscan(fid,'%s','Delimiter','\n','CommentStyle','%%',...
        'Whitespace','');
    clear cleanup;
    
    % Determine the Java class name of the service.  CXF generates a class name from
    % the WSDL service name using on a messy algorithm that tries to avoid name
    % collisions with other classes in the package:  First it tries the name of the
    % service.  Then it tries adding "_Service".  Finally it appends an integer 1, 2,
    % 3 until it gets a unique name.  This is implemented in
    % org.apache.cxf.tools.wsdlto.frontend.jaxws.processor.internal.ServiceProcessor.java.mapName().
    % which we can't access, so take the simple approach of looking for one with the
    % '_Service' suffix, and if we don't find that, just use one with the WSDL
    % service name.
    serviceName = mangleName(R.serviceName,1);
    serviceClass = [serviceName '_Service'];
    if ~existFile(javaDir, [serviceClass '.class'])
        serviceClass = serviceName;
        if ~existFile(javaDir, [serviceClass '.class'])
            error(message('MATLAB:webservices:InternalErrorGeneratedFileMissing', ...
                serviceClass, [serviceClass '_Service']))
        end
    end
    
    replacements = {'$GETTERS$', getterCode, '$MCLASSNAME$', R.className, ...
        '$ENDPOINT$', R.endpoint, ...
        '$WSDLLOCATION$', R.wsdlLocation, '$SERVICENAME$', R.serviceName, ...
        '$SERVICE_NS_URI$', R.serviceNamespaceURI, ...
        '$METHODHELP$', methodHelp, '$JARNAME$', pkgName, ...
        '$SERVICE_CLASS$', [R.servicePkg '.' serviceClass], '$METHODS$', methods, ...
        '$DATETIME$', timestamp, '$PKGNAME$', fullPkgName, ...
        '$PORTNAME$', R.portName, ...
        '$WSDLLOCATIONMSG$', wsdlFileMsg};

    template = template{1};
    for i = 1:2:length(replacements)
        template = strrep(template,replacements{i},replacements{i+1});
    end

    % write the file
    writemfile([dirname filesep R.className '.m'], template);
end

%===========================================================================
function [getterCode, getterHelp] = makeGetters(getters, pkgName,  classesUsed)
% Return code for all the convenience methods for each element in getters that 
% is also in classesUsed using the gettermethod.mtl template.  If
% getters(i).className is in classesUsed, then we create a method with the name
% ['get' getters(i).className].
%
%    getters            array of information about classes we generated:
%      javaClassName     
%      matlabClassName => $CLASSNAME$
%      methodName      => $METHODNAME$
%      pkgName         => $PKGNAME$ full package name
%      args            => $ARGS$
%      documentation   => $DOCUMENTATION$
%    pkgName        full package name
%    classesUsed    classes that were referenced from elsewhere.

    getterCode = '';
    tf = fullfile(fileparts(mfilename('fullpath')),'private','gettermethod.mtl');
    fid = fopen(tf);
    cleanup = onCleanup(@()fclose(fid));
    originalTemplate = textscan(fid,'%s','Delimiter','\n',...
        'CommentStyle','%%','Whitespace','');
    clear cleanup;
    getterHelp = {};
    width = 0;
    for i = 1 : length(getters)
        if any(strcmp(classesUsed,getters(i).matlabClassName)) 
            methodName = getters(i).methodName;
            if ~isempty(methodName)
                width = max(width,length(methodName));
            end
        end
    end
        
    for i = 1 : length(getters)
        template = originalTemplate{1};
        objName = getters(i).matlabClassName;
        if any(strcmp(classesUsed,objName)) 
            methodName = getters(i).methodName;
            % If we couldn't find a unique name, just don't create a method
            if ~isempty(methodName) 
                % indent each line of documentation so it lines up with function
                if isempty(getters(i).documentation)
                    newdoc = '';
                else
                    newdoc = ['     ' regexprep(getters(i).documentation, '\n', '\n     ')];
                end
                
                args = getters(i).args;
                if isempty(args)
                    nullargs = '';
                else
                    iargs = strsplit(getters(i).args,',');
                    nullargs = cell(1,length(iargs));
                    for j = 1 : length(iargs)
                        nullargs{j} = sprintf('            if nargin < %d, %s = []; end', ...
                            j, iargs{j});
                    end
                    nullargs = strjoin(nullargs,'\n');
                end
                
                replacements = {'$CLASSNAME$', objName, '$ARGS$', getters(i).args,...
                                '$PKGNAME$', pkgName, '$NULLARGS$', nullargs, ...
                                '$DOCUMENTATION$', newdoc, '$METHODNAME$', methodName};
                for j = 1:2:length(replacements)
                    template = strrep(template,replacements{j},replacements{j+1});
                end
                getterCode = append(getterCode, [strjoin(template','\n') sprintf('\n')]);
                getterHelp = append(getterHelp, ...
                    sprintf('    %%   %-*s - Create a <a href="matlab:doc %s.%s">%s</a> object', ...
                            width, methodName, pkgName, objName, objName));
            end
        end
    end
end

%===============================================================================
function [res, methodHelp] = makeMethods(R, pkgName)
    % Creates the methods for the WSDL described by R using wsdlmethod.mtl
    %   R           result from parseWsdl
    %   pkgName     MATLAB package name for derived classes, if any
    %   res         a big string containing all the lines of all the methods 
    %               created from the template
    %   methodHelp  H1 line for method help
    
    % Read in the template.
    tf = fullfile(fileparts(mfilename('fullpath')),'private','wsdlmethod.mtl');
    fid = fopen(tf);
    cleanup = onCleanup(@()fclose(fid));
    originalTemplate = textscan(fid,'%s','Delimiter','\n',...
        'CommentStyle','%%','Whitespace','');
    clear cleanup;
    
    res = '';
    methodHelp = cell(1,length(R.methods));
    
    width = max(cellfun(@(x) length(x), {R.methods.methodName}));
    
    for iMethod = 1:length(R.methods)
        method = R.methods(iMethod);
        
        if isempty(method.output)
            outputNames = {};
            needsOutputWrapper = false;
        else
            % Output is wrapped if any output part's type is anonymous and
            %   the input struct is empty
            needsOutputWrapper = ...
                isempty(method.input) && ...
                any(cellfun(@(x) isempty(x), {method.output.partType}));
            outputNames = arrayfun(@(x) x.name, [method.output.params], 'UniformOutput', false);
        end
        
        legalOutputNames = makeValidName(outputNames,'Rtn');
        switch length(legalOutputNames)
            case 0
                outputString = '';
                origOutputString = '';
                h1return = '';
            case 1
                outputString = sprintf('%s = ',legalOutputNames{1});
                origOutputString = sprintf('%s = ',outputNames{1});
                h1return = ['returns ' legalOutputNames{1}];
            otherwise
                outputString = strjoin(legalOutputNames, ',');
                origOutputString = strjoin(outputNames, ',');
                h1return = ['returns [' origOutputString ']'];
                outputString = sprintf('[%s] = ',outputString);
                origOutputString = sprintf('[%s] = ', origOutputString);
        end

        if isempty(method.input)
            inputParams = [];
            inputNames = {};
        else
            inputParams = [method.input.params];
            inputNames = arrayfun(@(x) x.name, inputParams, 'UniformOutput', false);
        end
        legalInputNames = makeValidName(inputNames,'Val');
        if isempty(legalInputNames)
            inputString = '(obj)';
            argDoc = '()';
            h1input = '';
        else
            inputString = sprintf('(obj%s)',sprintf(',%s',legalInputNames{:}));
            argDoc = sprintf('(%s)',strjoin(legalInputNames,','));
            h1input = [argDoc ' '];
        end
        % Set H1 line in the method to the WSDL documentation or 
        % a generic message.  
        if isempty(method.wsdlDoc)
            doc = [h1input h1return];
            h1Doc = '';
        else
            doc = method.wsdlDoc;
            
            doc = regexprep(doc,'\s*$','');
            % Insert the comment character % in front of each line, so that appears
            % in the right column and indent each parameter line
            doc = regexprep(doc,'\n','\n        %    ');
            h1Doc = doc;
        end
        methodHelp{iMethod} = sprintf('    %%   %-*s - %s', ...
                                      width, method.methodName, doc);
        indent = '            ';
        nargs = length(legalInputNames);
        argTest = cell(1,nargs);  % array of missing argument tests
        inputConversions = cell(1,nargs);
        
        % Get the number of the last mandatory argument, so we can error out if
        % fewer are specified
        if nargs > 0 
            minArgs = find(~[inputParams.isNillable],1,'last');
            if ~isempty(minArgs)
                minArgTest = sprintf(...
                    '%sif nargin < %d, error(message(''MATLAB:webservices:TooFewArgs'', ''%s'')), end\n', ...
                     indent, minArgs+1, legalInputNames{minArgs});
            else 
                minArgs = 0;
                minArgTest = '';
            end
        end
        
        % If there is more than one input or output part, or if the input or output
        % part is nillable, wsdl2java creates a wrapper object for the parameters in
        % each input and output part that has to be passed into the service method,
        % rather than letting us pass in the parameters directly.
        needsWrapper = length(method.input) > 1 || ...
            (length(method.input) == 1 && method.input.isNillable) || ...
            length(method.output) > 1 || ...
            (length(method.output) == 1 && method.output.isNillable);
        if needsWrapper
            inputCode = {};
        end
        
        % Write out the parameter name, input name, and type mapping.
        
        inputNum = 0;
        args = {};
        for partNum = 1 : length(method.input)
            if needsWrapper
                % This generates something like
                %    setTestUser_ = demo.hw.server.setTestUser;
                % below we'll plug in the converted values into jobj
                partName = method.input(partNum).partName;
                partVarName = [makeValidName(partName) '_'];
                partName(1) = upper(partName(1));
                inputCode = append(inputCode, ...
                       sprintf('%s = %s.%s;', partVarName, ...
                                method.input(partNum).javaPkg, partName));
                args = append(args, partVarName);
            end
            
            for i = 1 : length(method.input(partNum).params)
                inputNum = inputNum + 1;
                input = inputParams(inputNum);
                argName = legalInputNames{inputNum};

                % argTest contains lines to set all missing arguments to [], and for
                % optional argument that are derived, replace them with their Java
                % values.  Leave all other args alone.

                if inputNum > minArgs
                    % Only arguments past minArgs could be missing, since we have tested
                    % that in the minArgTest above.  We know all of these are optional
                    % so [] is a legal value.
                    argTest{inputNum} = sprintf([indent 'if nargin < %d, %s = []; end\n'], ...
                        inputNum+1, argName); 
                else
                    argTest{inputNum} = '';
                end

                % Now the arg is defined, but may be []  
                if input.isNillable 
                    if input.isDerived
                        % Convert optional derived arg to Java if it's not empty
                        argTest{inputNum} = append(argTest{inputNum}, sprintf( ...
                            '%sif ~isempty(%s), %s = %s.getObj; end\n', ...
                            indent, argName, argName, argName));
                    end
                else
                    % Check that required arg is not empty. The empty test for char
                    % requires ischar because isempty would falsely fail a legal
                    % empty string.
                    if strcmp(getLocalName(input.type),'string') && ~input.isArray
                        test = '~ischar';
                    else
                        test = 'isempty';
                    end
                    argTest{inputNum} = append(argTest{inputNum}, sprintf( ...
                       ['%sif %s(%s)\n' ...
                        '%s    error(message(''MATLAB:webservices:EmptyArg'', ''%s''))\n' ...
                        '%send\n'], ...
                        indent, test, argName, ...
                        indent, argName, ...
                        indent));
                end

                if input.isDerived
                    % If the derived arg is mandatory, code above has left it
                    % unchanged, so we need to call getObj on it.  Otherwise we just
                    % take what above code gave us, which is either [] or the Java
                    % value for it.
                    if input.isNillable
                        inputConversion = argName;
                    else        
                        inputConversion = [argName '.getObj']; 
                    end
                else
                    % For primitive types, replace the input variable name with a
                    % call to fromMATLAB that converts the MATLAB type to the
                    % required Java type.  An optional primitive needs to boxed
                    % because wsdl2java declares it as an Object.
                    inputConversion =  ...
                        sprintf('fromMATLAB({''%s'',''%s''}, %s,''%s'',%s,%s)', ...
                                method.methodName, argName, argName, getLocalName(input.type), ...
                                l2s(input.isNillable), l2s(input.isArray));
                end
                if needsWrapper
                    argName(1) = upper(argName(1));
                    inputCode = append(inputCode, sprintf('%s.set%s(%s);', ...
                                partVarName, argName, inputConversion));
                else
                    inputConversions{inputNum} = inputConversion;
                end
            end
        end
        
        if nargs > 0 
            if needsWrapper
                % add indent in front and newline at end of all wrapper lines
                body = sprintf('%s%s\n', indent, strjoin(inputCode, ['\n' indent]));
                args = strjoin(args,',');
            else
                body = '';
                args = strjoin(inputConversions, [',...\n' indent '    ']);
            end
        else
            args = '';
            body = '';
        end
        
        if ~isempty(method.output)
            outputParams = [method.output.params];
        end
        
        % This is the number of the last IN or INOUT argument, but if there are any
        % Holder objects for multiple OUT arguments, we will be adding more input
        % args for them down below.
        lastInputArg = length(legalInputNames);

        % Make the body of the method
        
        % Process the return values.  
        needsOutputWrapper = needsOutputWrapper | needsWrapper;
        if ((length(outputNames) == 1) && ...
                ~any(strcmp(legalOutputNames{1},legalInputNames))) || ...
             (~isempty(outputNames) && needsOutputWrapper)
            % We have a single output parameter that's not also an input, or 
            % all output parameters are wrapped in a single Java object with get
            % methods returning the results.
            %       ret = obj.PortObj.METHODNAME(ARGS);
            if needsOutputWrapper
                rname = 'retWrapper';
            else
                rname = 'ret';
            end
            % Get the one return value into the variable ret or retWrapper
            if isempty(args)
                body = append(body, sprintf([indent ...
                    '%s = matlab.internal.callJava(''%s'',obj.PortObj);\n'], ...
                       rname, method.javaMethodName));
            else
                body = append(body, sprintf([indent ...
                    '%s = matlab.internal.callJava(''%s'',obj.PortObj,%s);\n'], ...
                       rname, method.javaMethodName, args));
            end
            % Above returns either the actual return value, a Java object representing
            % an anonymous type containing one or more return values, or a wrapper
            % for multiple return values.
            if needsOutputWrapper
                % To unwrap the return value(s), call the get method whose name was
                % created from the name of the return value and then post-process
                % the result to convert to a MATLAB type.
                for j = 1 : length(outputNames)
                    retName = outputNames{j};
                    retName(1) = upper(retName(1));
                    code = sprintf( ...
                        '%sret = matlab.internal.callJava(''get%s'',retWrapper);\n%s', ...
                        indent, retName, ...
                        processReturnArg(indent, outputParams(j), ...
                                 legalOutputNames{j}, pkgName));
                    body = append(body, code);
                end
            else
                % The one return value is the result
                code = processReturnArg(indent, outputParams(1), ...
                                 legalOutputNames{1}, pkgName);
                body = append(body, code);
            end
        else
            % Single return value handled above. Process case where there are zero or
            % >1 non-wrapped return values or a single return parameter that's also
            % an input parameter.
            switch length(outputNames)
                case 0
                    % no return values:
                    %     obj.PortObj.METHODNAME(ARGS);
                    body = append(body, ...
                      sprintf([indent 'obj.PortObj.%s(%s);\n'], method.javaMethodName, args));
                otherwise
                    % There is >1 return value that isn't part of an anonymous type,
                    % or there is 1 return value that is also an input value.  If
                    % we're not wrapping, the Java method expects us to pass in a
                    % javax.xml.ws.Holder for each output arg into which the Java
                    % method will deposit the result.
                    outputHolderName = cell(1,length(outputParams));
                    retValNum = 0;
                    for iOutput = 1 : length(outputParams)
                        output = outputParams(iOutput);
                        argName = legalOutputNames{iOutput}; 
                        % The output arg is a Holder unless its name is "return" in
                        % which case it is a plain return value.  (This seems to be a
                        % wsdl2java wierdness)
                        if strcmp(output.name,'return') 
                            retValNum = iOutput;
                        else
                            % Process the Holder
                            holderName = sprintf('%s_Holder', argName);
                            outputHolderName{iOutput} = holderName;

                            % see if it's also an input arg (making it INOUT)
                            if ~isempty(inputParams)
                                inputArgNum = find(strcmp({inputParams.name}, argName),1);
                            else 
                                inputArgNum = [];
                            end
                            if isempty(inputArgNum) 
                                % An OUT argument only.  It still needs to be passed
                                % in as an empty Holder to Java at the end of the arg
                                % list
                                lastInputArg = lastInputArg + 1;
                                inputArgNum = lastInputArg;
                                body = append(body, sprintf([indent '%s = javax.xml.ws.Holder;\n'], ...
                                    holderName));
                            else
                                % An INOUT argument
                                % If argument missing, create empty holder
                                body = append(body, sprintf(...
                                        [indent 'if nargin < %d\n' ...
                                         indent '    %s = javax.xml.ws.Holder;\n' ...
                                         indent 'else\n'], ...
                                        inputArgNum+1, holderName));
                                % Insert the converted input object into the Holder
                                body = append(body, sprintf(...
                                    [indent '    %s = javax.xml.ws.Holder(%s);\n' ... 
                                     indent 'end\n'], ...
                                    holderName, inputConversions{inputArgNum}));
                            end
                            % replace the input argument with the Holder name
                            inputConversions{inputArgNum} = holderName;
                        end
                    end
                    if lastInputArg > 0
                        % This comma precedes the input argument list
                        comma = ',';
                    else
                        comma = '';
                    end

                    % Make the Java call and possibly post-process the return value
                    % This generates a call that looks like:
                    %   ret = matlab.internal.callJava('methodName',obj.PortObj,arg1,arg2,...)
                    if (retValNum > 0) 
                        % It has a return value that needs post-processing
                        body = append(body, sprintf([indent ...
                            'ret = matlab.internal.callJava(''%s'',obj.PortObj%s%s);\n'], ...
                                       method.javaMethodName, comma, ...
                                       strjoin(inputConversions,[',...\n    ' indent])));
                        body = append(body, processReturnArg(indent, ...
                                                outputParams(retValNum), ...
                                                legalOutputNames{retValNum}, ...
                                                pkgName));

                    else
                        % No return value -- any outputs are Holders
                        body = append(body, sprintf([indent ...
                            'matlab.internal.callJava(''%s'',obj.PortObj%s%s);\n'], ...
                                       method.javaMethodName, comma, ...
                                       strjoin(inputConversions,[',...\n    ' indent])));
                    end
                    % Now for each output arg that isn't the return value, extract
                    % its value from the 'value' field of the Holder and assign to
                    % its output arg, possibly converted
                    for iOutput = 1 : length(outputParams)
                        if (iOutput ~= retValNum)
                            output = outputParams(iOutput);
                            type = getLocalName(output.type);
                            ohn = outputHolderName{iOutput};
                            if ~output.isDerived && ~output.isArray && ...
                                    (strcmp(type,'long') || strcmp(type,'unsignedLong'))
                                % If the Holder's value field, which is declared as
                                % Object, contains a scalar Long, we need to use
                                % getAsNumber to retain the Long, because, if we just
                                % reference the field directly, MATLAB would convert
                                % it to a double and lose precision.
                                body = append(body, sprintf(...
                                    [indent 'ret = com.mathworks.jmi.Matlab.getAsNumber(%s,''value'');\n'], ...
                                     ohn));
                            else
                                % All other types are safely retrievable from the
                                % value field.  Even though MATLAB may change the
                                % type (e.g., Integer to double) no information is
                                % lost.  
                                if strcmp(type,'anyType') || strcmp(type,'anySimpleType')
                                    % Exception is if the field is any*Type, in which
                                    % case we want to preserve the actual type in
                                    % case its value is to be input to another
                                    % any*Type that expects and object of that type.
                                    % This code uses callJava to read the field
                                    % to avoid MATLAB's conversion
                                    body = append(body, sprintf(...
                                        [indent 'ret = matlab.internal.callJava' ...
                                        '(''get'',%s.getClass.getField(''value''),%s);\n'], ...
                                        ohn, ohn));
                                else
                                    body = append(body, sprintf(...
                                            [indent 'ret = %s.value;\n'], ohn));
                                end
                            end
                            % Now process 'ret' as if it was a return value
                            if needsWrapper
                                % To unwrap the return value, call the get method
                                % whose name was created from the name of the return
                                % value.
                                retName = outputNames{iOutput};
                                retName(1) = upper(retName(1));
                                body = append(body, ...
                                    sprintf('%sret = ret.get%s;\n', indent, retName));
                            end
                            % post-process the result
                            body = append(body, processReturnArg(indent, ...
                                         output, legalOutputNames{iOutput}, ...
                                         pkgName));
                        end
                    end % end of case for >1 return arg
            end
        end
        
        % prepend any argTest lines to the body
        if nargs > 0
            body = append([minArgTest [argTest{:}]], body); 
        end
        
        replacements = {'$METHODNAME$',method.methodName,...
            '$TARGETNAMESPACEURI$',method.targetNamespaceURI,...
            '$SOAPACTION$',method.soapAction,...
            '$H1DOCUMENTATION$', h1Doc,...
            '$DOCUMENTATION$',method.documentation,...
            '$MCLASSNAME$', R.className,...
            '$DOCOUTPUT$',origOutputString,...
            '$OUTPUT$',outputString,...
            '$INPUT$',inputString, ...
            '$ARGDOC$',argDoc, ...
            '$STYLE$',R.style, ...
            '$BODY$', body};
        template = originalTemplate{1};
        for inputNum = 1:2:length(replacements)
            template = strrep(template,replacements{inputNum},char(replacements{inputNum+1}));
        end
        res = append(res, [strjoin(template','\n') sprintf('\n')]); 
    end
end

%==============================================================================
function [getters, classesUsed] = makeClasses(dirName, pkgName, wsdl, R, schemaCol, ...
                                              javaDir, javaPkgName, timestamp)
    % For each derived type among the schemas in the WSDL, write a MATLAB file
    % for an MCOS class with a constructor that provies access to the underlying 
    % Java class and a getInstance static method to create one,
    % using the template genericconstructor.mtl.  A derived type is something 
    % other than a builtin XML type, that is defined in the schema accompanying
    % this WSDL.  We'll do this for every type defined as a "complexType", for
    % which we find a Java class that CXF has generated.
    %
    %    dirName     - temp directory name where to put the .m file
    %    pkgName     - name of MATLAB package for derived class
    %    wsdl        - WSDL file name (URI), used just in the help
    %    R           - result from parseWsdl
    %    schemaCol   - XMLSchemaCollection result from parseWsdl
    %    javaDir     - location where the Java classes are generated
    %    javaPkg     - Java package name
    %    timestamp   - timestamp string
    %
    % Returns: 
    %   getters  -   array of structs needed make getter convenience methods
    %                and getInstance calls to the class, one per class
    %      className       MCOS class name (no package)
    %      getterName      method name of the convenience getter
    %      args            comma-separated names of arguments to MCOS constructor,
    %                      which are to be used for the parameters to the convenience
    %                      method
    %      documentation   documentation to appear for the convenience method
    %      qname           the complex type's QName for which this class was
    %                      generated.
    %   classesUsed   cell array of classes of all the derived field types referenced
    %                 in parameters to these classes or their return values
    %   javaPkgName   Java package name for all Java code
    
    getters = [];
    mindent = '    ';            % indent to 'methods' and its 'end' statement
    findent = [mindent mindent]; % indent to 'function' and 'end' statements
    indent = [findent mindent];  % indent to function body statements
    % get all the Java classes derived from complex types
    javaClasses = getJavaClasses(schemaCol, javaDir, javaPkgName, pkgName); 
    if isempty(javaClasses) 
        classesUsed = [];
        return
    end
    
    % Before generating any code, we need to determine which of all the derived types
    % in the XML schema we actually need to generate class files for, and for those,
    % what methods they need to implement based on how they are referenced by other
    % classes.  If we just generate code for all derived types in the XML schema we
    % would be creating a huge number of useless classes that we never reference.
    % E.g., the schema defines two types for each operation, one for the message to
    % be transmitted and one for the result returned, but we don't need MATLAB
    % classes for these because Java takes care of processing those.
    
    % ClassesUsed specifies all referenced derived classes. Input params and fields
    % need getter methods, output params (return values) need getInstance methods,
    % etc.
    classesUsed = struct('name', {}, 'matlabClass', {}, 'needsGetter', [], ...
                         'needsGetInstance', []);
    needsGetters = {}; % classes for which we need getter convenience methods
    % All types referenced directly as fields, parameters, return values.
    % Does not contain types that are subclasses of referenced types if not
    % referenced directly.
    allTypes = {}; 
    
    % The getter method names need to be unique across all generated service classes,
    % since each class contains the same getter methods, so get all those names to
    % start.
    
    allMethods = [R.methods];
    methodNames = {allMethods.methodName};
    
    % Add types of all arguments and return values of all service methods to
    % classesUsed
    for i = 1 : length(allMethods)
        if ~isempty(allMethods(i).input)
            input = [allMethods(i).input.params];
            % process arguments
            for j = 1 : length(input)
                if input(j).isDerived
                    type = mangleName(getLocalName(input(j).type),1);
                    f = find(strcmp({classesUsed.name}, type), 1);
                    if isempty(f)
                        classesUsed(end+1).name = type; %#ok<AGROW>
                        classesUsed(end).matlabClass = input(j).matlabClass;
                        classesUsed(end).needsGetInstance = true;
                        f = length(classesUsed);
                        allTypes = addUnique(allTypes, type);
                    end
                    classesUsed(f).needsGetter = true; 
                    needsGetters = addUnique(needsGetters, type);
                end
            end
        end
        % process return values
        if ~isempty(allMethods(i).output)
            output = [allMethods(i).output.params];
            for j = 1 : length(output)
                if output(j).isDerived
                    type = mangleName(getLocalName(output(j).type),1);
                    f = find(strcmp({classesUsed.name}, type), 1);
                    if isempty(f)
                        classesUsed(end+1).name = type; %#ok<AGROW>
                        classesUsed(end).matlabClass = output(j).matlabClass;
                        classesUsed(end).needsGetter = false;
                        f = length(classesUsed);
                        allTypes = addUnique(allTypes, type);
                    end
                    classesUsed(f).needsGetInstance = true;
                end
            end
        end
    end
    
    % Populate allTypes with the names of all the derived types that are actually
    % referenced in fields of other types, because javaClasses contains all possible
    % ones we may not want.  Also include all superclasses, as they may not be
    % referenced directly but may need to be defined for documentation purposes.
    for i = 1 : length(javaClasses)
        javaClassInfo = javaClasses(i);
        for k = 1 : length(javaClassInfo.fields)
            field = javaClassInfo.fields(k);
            type = mangleName(getLocalName(field.type),1);
            allTypes = addUnique(allTypes, type);
        end
    end
    
    % Add types of all fields of derived types to classesUsed.  This may add extra 
    % types to classesUsed that are never needed, if the derived type itself is not
    % in classesUsed, but it's not worth worrying about that.
    for i = 1 : length(javaClasses)
        javaClassInfo = javaClasses(i);
        thisType = javaClassInfo.clazz;
        isEnum = javaClassInfo.isEnum;
        if javaClassInfo.isSimple, continue, end; % skip primitive types
        if ~isEnum && any(strcmp(allTypes, thisType))
            % This type is not an enum and is referenced directly, so add all its
            % fields to classesUsed
            
            % Set fieldsNeedGetters if this class, or one of its subclasses is
            % referenced as a field of another class or input parameter to a method.
            fieldsNeedGetters = any(strcmp(needsGetters, javaClassInfo.clazz));
            if ~fieldsNeedGetters
                for j = 1 : length(javaClassInfo.subclasses)
                    subclass = javaClasses(javaClassInfo.subclasses(j));
                    fieldsNeedGetters = any(strcmp(needsGetters, subclass.clazz));
                    if fieldsNeedGetters
                        break
                    end
                end
            end
            for k = 1 : length(javaClassInfo.fields)
                field = javaClassInfo.fields(k);
                if field.isDerived
                    type = mangleName(getLocalName(field.type),1);
                    f = find(strcmp({classesUsed.name}, type), 1);
                    if isempty(f)
                        classesUsed(end+1).name = type; %#ok<AGROW>
                        classesUsed(end).matlabClass = field.matlabClass;
                        f = length(classesUsed);
                        needsGetters = addUnique(needsGetters, type);
                        classesUsed(end).needsGetter = false;
                    end
                    classesUsed(f).needsGetter = classesUsed(f).needsGetter | fieldsNeedGetters;
                    % A field needs getInstance if this javaClassInfo, or any other
                    % class containing this class, and so on, have getInstance. This
                    % is too hard to check for so just set it.
                    classesUsed(f).needsGetInstance = true;
                end
            end
        end
        % If the class itself isn't in allTypes, but one of its supertypes is,
        % or it has any subtypes, or it's an enum, then add it to classesUsed
        sc = javaClassInfo.superclass;
        if ~any(strcmp(allTypes, thisType)) || isEnum
            added = false;
            while ~isempty(sc) 
                if any(strcmp(allTypes, sc)) 
                    added = true;
                    classesUsed(end+1).name = thisType;  %#ok<AGROW>
                    classesUsed(end).matlabClass = javaClassInfo.matlabClass;
                    classesUsed(end).needsGetter = ~javaClassInfo.isAbstract;
                    classesUsed(end).needsGetInstance = true;
                    break;
                end
                % find the javaClasses entry for the superclass and go to its
                % superclass
                super = find(strcmp({javaClasses.clazz},sc), 1);
                assert(~isempty(super));
                sc = javaClasses(super).superclass;
            end
            if ~added && (isEnum || ~isempty(javaClassInfo.subclasses))
                classesUsed(end+1).name = thisType; %#ok<AGROW>
                classesUsed(end).matlabClass = javaClassInfo.matlabClass;
                classesUsed(end).needsGetter = ~javaClassInfo.isAbstract;
                classesUsed(end).needsGetInstance = true;
            end
        end
    end
    
    % get cell array of class names with ',?' in front of each one
    % this is for the access attribute of certain methods we generate
    classNames = cellfun(@(x) sprintf(',?%s', x), ...
                          {classesUsed.matlabClass}, 'UniformOutput', false)';
    
    serviceNames = strjoin(strcat({'<a href="matlab:doc '}, {R.className}, ...
                            '">', {R.className}, '</a>'), ', ');

    if isempty(classNames)
        classnames = '';
    else
        classnames = strcat(classNames{:});
    end
    services = [strjoin({R.className}, ',?') ',?matlab.wsdl.internal.WsdlObject'];
        
    % Finally, ready to generate code for all javaClasses that are listed in
    % classesUsed
    for i = 1 : length(javaClasses)
        javaClassInfo = javaClasses(i);
        javaClass = javaClassInfo.clazz;
        classesUsedIndex = find(strcmp({classesUsed.name}, javaClass), 1);
        if isempty(classesUsedIndex)
            continue
        end
        % we break if the package name changes
        %assert(~exist('javaPkgName','var') || strcmp(javaPkgName,javaClassInfo.pkgName))
        javaPkgName = javaClassInfo.pkgName;
        
        fields = javaClassInfo.fields;
        numFields = length(fields);
        
        % The documentation line(s) for the class from the WSDL
        if ~isempty(javaClassInfo.documentation)
            h1Doc = strjoin(javaClassInfo.documentation,'\n    %    ');
        else
            h1Doc = sprintf('%s object for use with %s web client', ...
                               javaClass, serviceNames);
        end
        
        subclasses = javaClassInfo.subclasses;
        cases = '';
           
        if ~isempty(subclasses)
            caseIndent(1:16) = ' ';
        end
        subtypes = '';
        
        % If abstract, we won't be creating a class file for it -- just a help file
        % so leading spaces are different.
        if javaClassInfo.isAbstract
            spaces = '';
        else
            spaces = '    ';
        end
        
        for j = 1 : length(subclasses)
            % list all the concrete subclass in help, and generate a case statement
            % for each one
            subInfo = javaClasses(subclasses(j));
            if ~subInfo.isAbstract
                subtypes = append(subtypes, sprintf( ...
                    '%s%%    <a href="matlab:doc %s">%s</a>\n', ...
                    spaces, subInfo.matlabClass, subInfo.clazz));
                cases = append(cases, sprintf( ...
                    '%scase ''%s.%s''\n%s    getit = @%s.getInstance;\n', ...
                    caseIndent, javaPkgName, subInfo.clazz, caseIndent, subInfo.matlabClass));
            end
        end
        
        % remove trailing newlines
        if ~isempty(subtypes)
            subtypes(end) = []; 
        end
        if ~isempty(cases)
            cases(end) = [];
        end
            
        % If this type has superclasses, set inherits and superclass help
        superclasses = '';
        if isempty(javaClassInfo.superclass)
            inherits = 'matlab.wsdl.internal.WsdlObject';
        else
            next = javaClassInfo.superclass;
            inherits = sprintf('%s.%s', pkgName, next);
            sc = {};
            while ~isempty(next)
                sc = append(sc, next);
                next = javaClasses(find(strcmp({javaClasses.clazz},next), 1)).superclass;
            end
            superclasses = sprintf('    %%    This is a type of %s.\n', ...
                strjoin(strcat({'<a href="matlab:doc '}, [pkgName '.'], sc, '">', sc, '</a>'), ', '));
        end
        
        % If the class is abstract, generate a file containing help that names
        % the concrete subclasses and a switch statement invoking the getInstance
        % method for each concrete subclass.
        if javaClassInfo.isAbstract
            if ~isempty(subtypes)
                if ~exist('abstractTemplate','var')
                    tf = fullfile(fileparts(mfilename('fullpath')),'private','wsdlabstracttype.mtl');
                    abstractFid = fopen(tf);
                    cleanup1 = onCleanup(@() fclose(abstractFid));
                    abstractTemplate = textscan(abstractFid,'%s','Delimiter','\n',...
                                        'CommentStyle','%%','Whitespace','');
                    clear cleanup1;
                end
                template = abstractTemplate{1};
                replacements = {'$CLASSNAME$',     javaClass, ...
                                '$INHERITS$',      inherits, ...
                                '$H1DOC$',         h1Doc, ...
                                '$SERVICES$',      services, ...
                                '$SUBTYPES$',      subtypes, ...
                                '$DATETIME$',      timestamp, ...
                                '$CLASSES$',       classnames, ...
                                '$CASES$',         cases, ...
                                '$WSDL$',          wsdl, ...
                                '$NAMES$',         serviceNames};
                writeMFile(dirName,pkgName,javaClass,template,replacements);
            end    
            continue;
        end
        
        cu = classesUsed(classesUsedIndex);

        % Add this class to getters list, if needed
        if cu.needsGetter
            getters(end+1).javaClassName = javaClass; %#ok<AGROW>
            getters(end).matlabClassName = makeValidName(javaClass,'Object');
            getters(end).qname = char(javaClassInfo.item.getQName);
            methodName = uniqueGetMethodName(['get' javaClass], methodNames);
            getters(end).methodName = methodName;
            methodNames = append(methodNames, methodName);
            getterhelp = sprintf('To create a %s, use <a href="matlab:doc %s.%s">%s.%s</a>.\n    %%', ...
                javaClass, R(1).className, methodName, R(1).className, methodName);
        else 
            getterhelp = '';
        end

        % If an enum type, the class just contains one Value field with enumerated
        % values for the types, stored in fields.name
        if javaClassInfo.isEnum
            docs = cell(1,numFields);
            prefix = '    %      ';
            for idoc = 1 : numFields
                fdoc = fields(idoc).documentation;
                if isempty(fdoc)
                    docs{idoc} = sprintf('%s%s\n', prefix, fields(idoc).name);
                else
                    docs{idoc} = sprintf('%s%s - %s\n', prefix, ...
                    fields(idoc).name, strjoin(fields(idoc).documentation,[prefix '  ']));
                end
            end    
            documentation = [docs{:}];
            typestr = getMATLABArgDescription(javaClassInfo.baseType, false);
            documentation(end) = [];
            
            if cu.needsGetter
                getters(end).documentation = sprintf( ...
                    '    %%     VALUE is a %s with one of the following values:\n%s', ...
                    typestr, documentation);
                getters(end).args = 'VALUE';
            end
            if ~exist('enumTemplate','var')
                tf = fullfile(fileparts(mfilename('fullpath')),'private','wsdlenum.mtl');
                enumFid = fopen(tf);
                cleanup2 = onCleanup(@() fclose(enumFid));
                enumTemplate = textscan(enumFid,'%s','Delimiter','\n',...
                                        'CommentStyle','%%','Whitespace','');
                clear cleanup2
            end
            template = enumTemplate{1};
            replacements = {'$CLASSNAME$',     javaClass, ...
                            '$PKGNAME$',       pkgName, ...
                            '$JAVAPKGNAME$',   javaPkgName, ...
                            '$H1DOC$',         h1Doc, ...
                            '$TYPE$',          typestr, ...
                            '$DOCUMENTATION$', documentation, ...
                            '$SERVICES$',      services, ...
                            '$DATETIME$',      timestamp, ...
                            '$WSDL$',          wsdl, ...
                            '$GETTERHELP$',    getterhelp, ...
                            '$VALUES$',        strjoin({fields.name},', '), ...
                            '$NAMES$',         serviceNames, ...
                            '$CLASSES$',       classnames};
            writeMFile(dirName,pkgName,javaClass,template,replacements);
            continue;
        end
            
        
        % Go through the elements of the type, which become the parameters
        % to the MCOS constructor
        fieldNames = cell(1,numFields);
        legalNames = cell(1,numFields);
        % This array contains code to populate the properties of the MCOS
        % object from the constructor args
        savers = cell(1,numFields);
        % This array contains lines of code to populate the fields of the Java object
        % called 'jobj' from the properties of this MCOS class by invoking
        % the setXXX method for each field, converting MATLAB types to Java
        % types as needed.
        setparams = cell(1,numFields);
        % This array contains function calls that extract the fields from the
        % Java object 'jobj' and converts them to MATLAB types
        getparams = cell(1,numFields);
        % This is the documentation of the parameters, 1 element per parameter
        doc = cell(1,numFields);
        
        imported = false;
        
        requiredFields = {}; % names of non-optional fields (~isNillable)
        derivedFields = {};  % names of derived fields
        
        % setMethod{k} is a set method that validates the type of the field being set
        setMethod = cell(numFields, 1);
        
        properties = {};
        
        for k = 1 : numFields
            field = fields(k);
            fieldName = field.name;
            % The schema field name becomes the name of the parameter, MATLAB-ized
            fieldNames{k} = fieldName;
            legalName = makeValidName(fieldName,'Prop');
            legalNames{k} = legalName;
            type = field.type;
            if ~field.fromSuperclass
                properties = append(properties, legalName);
            end
            
            % This builds the contents of the constructor (savers) and set methods (setMethods)
            savers{k} = sprintf( ...
                       ['%sif nargin > %d\n' ...
                        '%s    obj.%s = %s;\n' ...
                        '%send'], ...
                       indent, k-1, ...
                       indent, legalName, legalName, ...
                       indent);
            if ~field.isNillable 
                requiredFields = append(requiredFields, legalName);
            end
            
            % every field gets a setMethod
            if field.isDerived
                % derived fields test the class of the object
                fullType = field.matlabClass;
                setMethodPart = sprintf( ...
                       ['%sif ~isempty(value) && ~isa(value,''%s'')\n' ...
                        '%s    error(message(''MATLAB:webservices:VarShouldBeAType'',' ...
                                             '''%s'', ''%s'', ''%s''))\n' ...
                        '%send\n'], ...
                        indent, fullType, ...
                        indent, legalName, fullType, type, ...
                        indent);
                derivedFields = append(derivedFields, ['x.' legalName]);
            else
                % primitive fields use toMATLAB to test for valid values
                fullType = getMATLABArgDescription(type, field.isArray);
                % In the fromMATLAB call, a nillable non-derived field needs
                % to be boxed, if it's a number or boolean, because CXF has
                % declared it as an Object, not a primitive.
                classFieldName = sprintf('{''%s'',''%s''}', javaClass, legalName);
                setMethodPart = sprintf( ...
                   '%smatlab.wsdl.internal.fromMATLAB(%s,value,''%s'',%s,%s);\n', ...
                   indent, classFieldName, type, ...
                   l2s(field.isNillable), l2s(field.isArray));
            end
            
            if ~field.fromSuperclass
                % Compose the whole setMethod
                setMethod{k} = sprintf( ...
                         ['%sfunction obj = set.%s(obj, value)\n' ... 
                                '%s' ...
                                '%sobj.%s = value;\n' ...
                          '%send'], ...
                          findent, legalName, setMethodPart, indent, legalName, findent);
            else
                setMethod{k} = '';
            end
            
            % This builds the documentation for the field
            if field.isArray
                if field.isDerived
                    doc{k} = sprintf( ...
                        '    %%     %s - vector of <a href="matlab:doc %s">%s</a>\n', ...
                        legalName, fullType, type);
                else
                    doc{k} = sprintf( ...
                        '    %%     %s - %s\n', legalName, fullType);
                end
            else 
                if field.isDerived
                    doc{k} = sprintf( ...
                        '    %%     %s - <a href="matlab:doc %s">%s</a>\n', ...
                         legalName, fullType, type);
                else
                    doc{k} = sprintf( ...
                        '    %%     %s - %s\n', legalName, fullType);
                end
            end
            if ~isempty(field.documentation)
                % append documentation from the XML, if any
                prefix = '    %         ';
                doc{k} = sprintf('%s%s%s\n', doc{k}, prefix, ...
                                 strjoin(field.documentation,['\n' prefix]));
            end
            
            % This builds the part of the body of the getOneObj(obj) method that
            % populates the Java object with the fields from this object by calling
            % the Java set method for each field.
            % Uppercase first letter of field name to make the get/set method name
            % used by Java
            methodPartName = fieldName;
            methodPartName(1) = upper(methodPartName(1));
            if field.isArray
                % If field is an array, there is no set method.  CXF requires us to
                % use the get method to fetch the field as a java.util.List which we
                % populate using appropriate helper methods.
                if ~imported
                    import = sprintf('%simport matlab.wsdl.internal.WsdlObject\n', indent);
                    imported = true;
                else
                    import = '';
                end
                if field.isDerived 
                    setparams{k} = sprintf(...
                        '%s%sWsdlObject.getDerivedList(obj.%s,jobj.get%s);\n', ...
                        import, indent, legalName, methodPartName);
                else
                    setparams{k} = sprintf(...
                        '%s%sWsdlObject.getBasicList(%s,obj.%s,''%s'',jobj.get%s);\n', ...
                        import, indent, classFieldName, legalName, type, methodPartName);
                end
            else
                if field.isDerived
                    % Derived field means type is a Java class CXF generated, so
                    % we have an MCOS class for it. Call getObj() in the class to fetch
                    % the Java equivalent.  This getObj is actually implemented in the
                    % common superclass, WsdlObject.
                    if field.isNillable
                        setparams{k} = sprintf( ...
                           ['%sif ~isempty(obj.%s)\n' ...
                            '%s    jobj.set%s(obj.%s.getObj);\n' ...
                            '%send\n'], ...
                            indent, legalName, ...
                            indent, methodPartName, legalName, ...
                            indent);
                    else
                        setparams{k} = sprintf( ...
                            '%sjobj.set%s(obj.%s.getObj);\n', ...
                            indent, methodPartName, legalName);
                    end
                else
                    % A builtin XML type: call converter function to make value suitable
                    % for the Java set method.  Converter always allows [] and returns [].
                    % The set method has tested whether that's OK so we don't have to
                    % test nillable here.
                    setparams{k} = sprintf( ...
                        '%sjobj.set%s(fromMATLAB(%s,obj.%s,''%s'',%s));\n', ...
                        indent, methodPartName, classFieldName, legalName, ...
                        type, l2s(field.isNillable));
                end
            end
            
            % This builds parts of the body of the getInstance(jobj,isArray) method
            if field.isDerived
                getparams{k} = sprintf( ...
                    '%s        %s.getInstance(jobj.get%s,%s)', ...
                    indent, fullType, methodPartName, l2s(field.isArray));
            else
                if strcmp(type,'boolean') && ~field.isArray
                    getter = 'is';
                else 
                    getter = 'get';
                end
                if strcmp(type,'anyType') || strcmp(type,'anySimpleType')
                    % an any type needs to be accessed with callJava wrapper
                    % to preserve the original type and an additional pkgName
                    % parameter to toMATLAB
                    getparams{k} = sprintf( ...
                        '%s        toMATLAB(matlab.internal.callJava(''%s%s'',jobj),''%s'',%s,''%s'')', ...
                        indent, getter, methodPartName, type, l2s(field.isArray), ...
                        pkgName);
                else
                    getparams{k} = sprintf( ...
                        '%s        toMATLAB(jobj.%s%s,''%s'',%s)', ...
                        indent, getter, methodPartName, type, l2s(field.isArray));
                end
            end
        end
        args = strjoin(legalNames,',');
        properties = strjoin(properties, ['\n' findent]);
        saveparams = strjoin(savers,'\n');

        tf = fullfile(fileparts(mfilename('fullpath')), 'private', 'genericconstructor.mtl');
        fid = fopen(tf);
        cleanup = onCleanup(@()fclose(fid));
        originalTemplate = textscan(fid, '%s', 'Delimiter', '\n',...
            'CommentStyle','%%','Whitespace','');
        clear cleanup;
        
        documentation = [doc{:}];
        
        cu = classesUsed(classesUsedIndex);

        % Add getter args and docs
        if cu.needsGetter
            getters(end).args = args;
            getters(end).documentation = documentation;
        end
        
        setMethods = strjoin(setMethod',[findent '\n\n']);
        
        if ~isempty(setparams)
            setparams{end}(end) = []; % remove last newline from last setter line
        end
        
        % If it has subtypes, list them
        if ~isempty(subtypes) 
            if numFields > 0
                subtypeMsg = sprintf('    %% Other types of %s are:\n%s\n    %%\n',javaClass,subtypes);
            else
                % Some concrete classes have no fields themselves, so only the 
                % concrete subtypes make sense to construct
                subtypeMsg = sprintf('    %% Types of %s are:\n%s\n    %%\n',javaClass,subtypes);
            end
            subtypeMsg(end) = []; % remove last newline
        else
            subtypeMsg = '    %';
        end
        
        replacements = { ...
            '$CLASSNAME$',    javaClass, ...
            '$PKGNAME$',      pkgName, ...
            '$JAVAPKGNAME$',  javaPkgName, ...
            '$ARGS$',         args, ...
            '$PROPERTIES$',   properties, ...
            '$H1DOC$',        h1Doc, ...
            '$DOCUMENTATION$', documentation, ...
            '$INHERITS$',     inherits, ...
            '$SETTERS$',      [setparams{:}], ...
            '$SAVEPARAMS$',   saveparams, ...
            '$SETMETHODS$',   setMethods, ...     
            '$DERIVEDX$',     strjoin(derivedFields,','), ...
            '$REQNAMES$',     strjoin(regexprep(requiredFields,'^.*$','''$0'''), ','), ...
            '$REQX$',         strjoin(regexprep(requiredFields,'^.*$','x.$0'), ','), ...
            '$GETTERS$',      strjoin(getparams,', ...\n'), ...
            '$CLASSES$',      classnames, ...
            '$CASES$',        cases, ...
            '$WSDL$',         wsdl, ...
            '$DATETIME$',     timestamp, ...
            '$NAMES$',        serviceNames, ...
            '$SERVICES$',     services, ...
            '$SUPERCLASSES$', superclasses, ...
            '$SUBTYPES$',     subtypeMsg, ...
            '$GETTERHELP$',   getterhelp};
        
        template = originalTemplate{1};
        
        % If parts of the template are to be skipped, remove them.  This
        % conditionally copies sections between:
        %   ${NEEDSfoobar$
        %   ...
        %   $}$
        % and handles nesting.
        copyLines = true;
        newTemplate = {};
        for l = 1 : length(template)
            line = template{l};
            isNeedsLine = ~isempty(strfind(line,'${NEEDS'));
            if ~isempty(strfind(line,'$}$'))
                copyLines(end) = [];
            elseif isNeedsLine
                switch regexprep(line,'^\${NEEDS(.*)\$','$1')
                    case 'GETINSTANCE'
                        copyLines(end+1) = cu.needsGetInstance;  %#ok<AGROW>
                    case 'SUBCLASSES'
                        copyLines(end+1) = ~isempty(subclasses); %#ok<AGROW>
                    otherwise
                        assert(false,line);
                end
                % shouldn't be copying lines if the containing section isn't being
                % copied
                assert(~copyLines(end) || copyLines(end-1));
            elseif copyLines(end) 
                newTemplate = append(newTemplate, line);
            end
        end
        template = newTemplate;
        
        writeMFile(dirName,pkgName,javaClass,template,replacements);
    end
    
    % only return the names
    classesUsed = {classesUsed.name};
end

%===========================================================================
function writeMFile(dirName,pkgName,fileName,template,replacements)
    % Write a MATLAB file from the template using replacements
    %   dirName    directory containing the file
    %   fileName   name of the file, without '.m'
    %   template   source template
    %   replacement  cell array of replacements: odd element is string to search for, 
    %                subsequent even element is replacement string.
    for l = 1 : 2 : length(replacements)
        repl = replacements{l+1};
        if isempty(repl)
            repl = '';
        end
        template = strrep(template,replacements{l},repl);
    end
    pkgSubdir = strcat('+', strsplit(pkgName,'.'));
    pkgdir = fullfile(dirName, pkgSubdir{:});
    if ~exist(pkgdir, 'dir')
        mkdir(pkgdir);
    end
    loc = [pkgdir filesep fileName '.m'];
    writemfile(loc, template);
end


%===========================================================================
function javaClasses = getJavaClasses(schemaCol, javaDir, javaPkgName, pkgName)
    % Return information about all the Java classes that CXF has generated, that we
    % might possibly want to represent as MATLAB classes, plus names of simpleTypes
    % in the WSDL schema that map directly to XML builtin types, for which no class
    % was generated.  Simple types straight out of the XML schema do not appear here.
    %
    % It finds the Java class by looking for simpleTypes and complexTypes defined in
    % the schema and seeing if there is a corresponding Java class file with the same
    % name. It may return more classes than we actually need, since messages are
    % complex types themselves, but we don't need to reference their Java classes
    % from MATLAB.
    %     
    %    schemaCol   - org.apache.ws.commons.schema.XmlSchemaCollection from parseWsdl
    %    pkgName     - full MATLAB package name for derived classes
    %    javaClasses - array of structs, one per class:
    %          item        - XMLSchemaOject the class was created for   
    %          clazz       - name of the Java class, if one was generated, or if the 
    %                        it was a simpleType, name of the type
    %          javaPkgname - package name of the Java class (ignore if primitive)
    %          superclass  - the superclass name if "base" attribute specified,
    %                        mangled to a Java class name
    %          isAbstract  - true if abstract="true"
    %          isSimple    - it's an XML schema simpleType.  It will have a Java
    %                        class generated only if isEnum.
    %          isEnum      - this is an enum type (isSimple is true).  We don't 
    %                        currently handle enums for non-primitive types.
    %          matlabClass - matlab pkg.class name, if we were to generate one for this
    %                        (ignore if isSimple && ~isEnum)
    %          subclasses  - array of indicxes into javaClasses of this type's subclasses
    %          baseType    - if a simpleType, the base primitive type; field names contain values
    %          documentation - cell array of documentation strings from WSDL
    %          fields      - array of structs, one per field within this type
    %                        as defined in the schema, or one per value if isEnum.
    %                        Includes fields from all superclasses.
    %              name      - XML name of the field or enum value as a string
    %              uri       - namespace URI of the field's schema type (empty if
    %                          enum)
    %              type      - local part of the schema type QName (same as baseType
    %                          if set)
    %              isArray   - true if the field is an array (represented
    %                          as a java.util.List)
    %              isDerived - true type of field is a derived type
    %                          otherwise a basic XML type
    %              fromSuperclass - true if this is an inerited field from a concrete
    %                          superclass.
    %              documentation - cell array of documentation strings from WSDL
    %              isNillable - true if it can be missing (nillable or minOccurs==0)
    %              matlabClass - corresponding MATLAB pkg.class for type if isDerived
    javaClasses = [];
    classesUsed = {};
    xmlSchemas = schemaCol.getXmlSchemas();
    for i = 1 : length(xmlSchemas)
        soc = xmlSchemas(i).getItems;   % XMLSchemaObjectCollection
        if soc.getCount == 0, continue, end
        for j = 0 : soc.getCount-1
            item = soc.getItem(j); % XMLSchemaObject
            % If we can't find a generated Java class with as this complex type,
            % we don't need to generate a MATLAB class for this type.  Hopefully
            % this will only happen for the XML schema builtin types.
            fields = [];
            superclass = [];
            baseType = [];
            isAbstract = false;
            isSimple = false;
            isEnum = false;
            if isSchemaType(item, 'SimpleType') 
                % If class is a simple type, it's really a primitive type for which 
                % wsdl2java just uses the Java type rather than generating a class, 
                % but there are some cases where it does create a class.
                [javaClass, restriction] = getJavaClassForType(javaDir,javaPkgName,item);
                % If there is no Java class, assume it's a primitive that doesn't
                % need one, so just ignore it.
                if isempty(javaClass), continue, end;
                isSimple = true;
                if isSchemaType(restriction, 'SimpleTypeRestriction')
                    % TODO: if the baseType is not a simple XML type that MATLAB
                    % translates to a primitive, this will probably fail to generate
                    % a useful class.
                    % Get the base type and assume it's a primitive
                    baseType = char(restriction.getBaseTypeName.getLocalPart);
                    if isempty(baseType), continue, end
                    % If the restriction specifies an enumeration, then wsdl2java
                    % generates a Java enum class, so we'll need to refer to it.
                    % Otherwise it's just a plain primitive (though its name might
                    % not be a primitive name)
                    if isEnumeration(restriction)
                        facets = restriction.getFacets;
                        % Pick out all the enum values and use the fields array to 
                        % save their names.
                        for ifacet = 1 : facets.getCount
                            facet = facets.getItem(ifacet - 1);
                            if isSchemaType(facet, 'EnumerationFacet')
                                % The facet's value is the name of the enumermation
                                % item.  If none, this is probably a malformed schema.
                                value = facet.getValue;
                                if isjava(value) 
                                    value = char(value.toString);
                                end
                                fields(end+1).name = value; %#ok<AGROW>
                                fields(end).type = baseType;
                                fields(end).uri = [];
                                fields(end).isArray = false;
                                fields(end).isNillable = false;
                                fields(end).isDerived = false;
                                fields(end).matlabClass = '';
                                fields(end).documentation = getDocumentation(facet); 
                                fields(end).fromSuperclass = false;
                            end
                        end
                        isEnum = true;
                    end
                end
            elseif isSchemaType(item, 'ComplexType')
                % If class is a complex type, handle its fields
                isAbstract = item.isAbstract;
                javaClass = getJavaClassForType(javaDir,javaPkgName,item);
                part = item.getParticle;        % XMLSchemaParticle
                if isempty(part)
                    % if there's no particle, perhaps there's a content model with a
                    % particle
                    cm = item.getContentModel;
                    if ~isempty(cm)
                        content = cm.getContent;
                        if ~isempty(content) 
                            if isSchemaType(content,'ComplexContentExtension') || ...
                               isSchemaType(content,'ComplexContentRestriction')
                                part = content.getParticle;
                            else
                                % see g1187198
                                warning(message('MATLAB:webservices:NoSimpleContent', char(item.getName)));
                            end
                        end
                    end
                end
                if ~isempty(javaClass) && isSchemaType(part, 'Sequence')
                    xmlFields = part.getItems;
                    namespaceURI = part.getSourceURI;
                    % Make a struct for each field
                    for k = 0 : xmlFields.getCount-1
                        element = xmlFields.getItem(k);
                        % Only XMLSchemaElements are fields
                        if isSchemaType(element, 'Element')
                            fields(end+1).name = char(element.getName); %#ok<AGROW>
                            schemaType = getSchemaType(namespaceURI,schemaCol,element);
                            % typeQName will be empty if it's an anonymous type
                            if isempty(schemaType)
                                typeQName = javax.xml.namespace.QName('http://www.w3c.org/2001/XMLSchema','anyType');
                            else
                                typeQName = schemaType.getQName;
                            end
                            fields(end).isArray = element.getMaxOccurs > 1;
                            fields(end).isNillable = element.isNillable || element.getMinOccurs == 0;
                            if ~isempty(schemaType) && isSchemaType(schemaType,'SimpleType') 
                                % For simple type fields, special processing 
                                content = schemaType.getContent;
                                % only handle some simple cases
                                if ~isempty(content) 
                                    if isSchemaType(content,'SimpleTypeRestriction')
                                        % if a simple type use the base type unless
                                        % it's an enumeration, because Java doesn't
                                        % create a class for it
                                        if isempty(typeQName) || ~isEnumeration(content) 
                                            typeQName = content.getBaseTypeName;
                                        end
                                    elseif isSchemaType(content,'SimpleTypeUnion')
                                        % Since Java doesn't have unions, wsdl2java 
                                        % just appears to use String.
                                        typeQName = javax.xml.namespace.QName('http://www.w3.org/2001/XMLSchema','string');
                                    elseif isSchemaType(content,'SimpleTypeList')
                                        % wsdl2java treats a list just like an array
                                        typeQName = content.getItemTypeName;
                                        fields(end).isArray = true;
                                    end
                                end
                            end
                            if isempty(typeQName)
                                % Too hard to get the base type.  Also don't do
                                % anonymous complex types.  These become inner
                                % classes in the javaClass, which are a hassle to
                                % access.  Anonymous types are bad anyway:
                                % http://www.ibm.com/developerworks/library/ws-avoid-anonymous-types/
                                % To address this issue in the future, all that might
                                % be needed is to fix getJavaClassForType to return
                                % [getTypeName(item) '.' getTypeName(element.getName)], 
                                % but we need to do this recursively if the field's
                                % type contains elements that are themselves defined
                                % with anonymous complex types, resulting in multiple
                                % nesting levels.
                                tn = getTypeName(item);
                                warning(message('MATLAB:webservices:NoAnonymousTypes',...
                                    fields(end).name, tn, tn));
                                fields(end) = []; 
                                continue;
                            end
                            fields(end).uri = typeQName.getNamespaceURI;
                            javaType = getJavaClassForType(javaDir,javaPkgName,typeQName);
                            fields(end).isDerived = ~isempty(javaType);
                            if fields(end).isDerived
                                % if the field is derived, use the MATLAB class name
                                % for its type
                                classesUsed = addUnique(classesUsed, javaType);
                                type = makeValidName(javaType,'Object');
                                fields(end).matlabClass = [pkgName '.' type];
                                fields(end).type = type;
                            else
                                % if not derived, the local part of QName is the type
                                fields(end).type = char(typeQName.getLocalPart);
                                fields(end).matlabClass = '';
                            end
                            fields(end).documentation = getDocumentation(element);
                            fields(end).fromSuperclass = false;
                        end
                    end
                end
                contentModel = item.getContentModel;
                if ~isempty(contentModel)
                    content = contentModel.getContent;
                    if ~isempty(content) && ...
                       isSchemaType(content,'ComplexContentExtension')
                        baseType = content.getBaseTypeName; % a QName
                        superclass = mangleName(char(baseType.getLocalPart),1);
                    end
                end
            else
                continue
            end
            javaClasses(end+1).clazz = javaClass; %#ok<AGROW>
            javaClasses(end).pkgName = javaPkgName;
            javaClasses(end).item = item;
            javaClasses(end).fields = fields;
            javaClasses(end).isAbstract = isAbstract;
            javaClasses(end).isSimple = isSimple;
            javaClasses(end).isEnum = isEnum;
            javaClasses(end).matlabClass = [pkgName '.' makeValidName(javaClass,'Object')];
            javaClasses(end).subclasses = [];
            javaClasses(end).baseType = baseType;
            javaClasses(end).superclass = superclass;
            javaClasses(end).documentation = getDocumentation(item);
        end
    end
    % Add each type that is a subclass to each of its supertypes' subclass lists
    for i = 1 : length(javaClasses)
        info = javaClasses(i);
        if ~isempty(info.superclass)
            j = i;
            fields = info.fields;
            while ~isempty(javaClasses(j).superclass)
                % get the superclass
                j = find(strcmp({javaClasses.clazz},javaClasses(j).superclass),1);
                assert(~isempty(j));
                javaClasses(j).subclasses(end+1) = i; %#ok<AGROW>
                % also append the superclass's fields to this class, but flag them if
                % concrete
                isAbstract = javaClasses(j).isAbstract;
                for k = 1 : length(javaClasses(j).fields)
                    field = javaClasses(j).fields(k);
                    % need to weed out duplicates, because the superclass may already
                    % have its own superclass fields added to it
                    if ~isAbstract
                        field.fromSuperclass = true;
                    end
                    if isempty(fields) || ~any(strcmp({fields.name}, field.name))
                        fields = append(fields, field);
                    end
                end
            end
            javaClasses(i).fields = fields; %#ok<AGROW>
        end
    end
end

%============================================================================
function tf = isEnumeration(restriction)
    % Return true if the XmlSchemaSimpleTypeRestriction is an enumeration.  This
    % means it has at least one XmlSchemaEnumerationFacet.
    facets = restriction.getFacets;
    if ~isempty(facets)
        for ifacet = 1 : facets.getCount
            if isSchemaType(facets.getItem(ifacet - 1), 'EnumerationFacet')
                tf = true;
                return 
            end
        end
    end
    tf = false;
end

%============================================================================
function doc = getDocumentation(element)
    % Return a cell array of strings containing the documentation for the element,
    % which should be an XMLSchemaAnnoted object.  Each line of documentation is in
    % a separate cell, newlines removed.
    doc = {};
    annotation = element.getAnnotation;
    if ~isempty(annotation)
        items = annotation.getItems;
        if ~isempty(items)
            for ic = 1 : items.getCount
                docItem = items.getItem(ic-1);
                if ~isempty(docItem) && isSchemaType(docItem, 'Documentation')
                    mu = docItem.getMarkup;
                    for muc = 1 : mu.getLength
                        txt = mu.item(muc-1);
                        if isa(txt,'org.apache.xerces.dom.DeferredTextImpl')
                            % Append each line of text, whitespace trimmed.
                            % The inner call to strtrim removes newlines on the
                            % ends that strsplit would otherwise make into separate
                            % lines.
                            doc = append(doc, ...
                                  strtrim(strsplit(strtrim(char(txt.getTextContent)), '\n')));
                        end
                    end
                end
            end
        end
    end
end
%============================================================================
function [clazz, restriction] = getJavaClassForType(javaDir, javaPkgName, type)
    % Return the Java class name that CXF uses for the
    % specified type, or empty if the type is a XML builtin type.  First looks in
    % javaDir/javaPkgName for a .class file with a name that is the same as type's
    % getName but starts with an uppercase character, which is CXF's rules for
    % generating the class name.  If that is found, returns that class name.  If not,
    % and the type is an XmlSchemaSimpleType that is not one of the XML builtin
    % types, return the base type name of the restriction, which should be an XML
    % builtin type.  
    % restriction is the XMLSchemaSimpleTypeRestriction taken from type.getContent.
    [name, qname] = getTypeName(type);
    name = mangleName(name,1);
    classFilePath = fullfile(javaDir, javaPkgName, [name '.class']);
    res = exist(classFilePath,'file');
    isSimple = isSchemaType(type, 'SimpleType');
    if isSimple
        restriction = type.getContent;
    end
    if res
        % We have a class with the expected name, just use it regardless of type.
        % We'll come here for all complexTypes and simpleTypes that are enums (for
        % which wsdl2java generates a class).
        clazz = name;
    else
        % We have no class with the same name.  This is only expected for simpleTypes
        % that are not enums.
        if isSimple 
            if isSchemaType(restriction, 'SimpleTypeRestriction')
                % If a simpleType with a restriction, the restriction should be a
                % primitive type that is the real base type, so return the base type
                restrictionQName = restriction.getBaseTypeName;
                clazz = char(restrictionQName.getLocalPart);
                if isempty(strfind(char(restrictionQName.toString),'XML'))
                    % base type should be builtin
                    warning(message('MATLAB:webservices:SimpleTypeRestrictionNotXML', ...
                                    name, char(restrictionQName.toString)));
                end
            else
                % A simpleType with no restriction; assume regular simpleType
                clazz = [];
            end
        else
            % If we don't find a Java class for it, assume regular simpleType.
            clazz = [];
        end
        if isempty(clazz) && isempty(strfind(qname.toString,'XML')) 
            % If it's a simpleType with no restriction, and the type is not an XML
            % builtin type, it's either a bug in the WSDL, or our inability to get to
            % an imported WSDL that has a schema defines this type
            warning(message('MATLAB:webservices:SimpleTypeNotXML', name));
        end
    end
end

%============================================================================
function code = processReturnArg(indent, outputStruct, outputName, pkgName)
    % Return a line of MATLAB code that wraps the variable 'ret' returned from a Java
    % method in whatever is necessary to convert it to a MATLAB type.
    %   indent - forwarded parameter from makemethods
    %   outputStruct - the argument struct containing
    %         name, type, javaClass, matlabClass, isDerived, isArray, isNillable
    %   outputName   - the legal MATLAB name of this output argument  
    
    if ~outputStruct.isDerived
        % builtin XML type: run the converter to get the MATLAB type
        assert(~isempty(strfind(outputStruct.type,'XML')));
        type = getLocalName(outputStruct.type);
        if strcmp(type,'anyType') || strcmp(type,'anySimpleType')
            code = sprintf([indent '%s = toMATLAB(ret,''%s'',%s,''%s'');\n'], ...
                outputName, type, l2s(outputStruct.isArray), pkgName);
        else
            code = sprintf([indent '%s = toMATLAB(ret,''%s'',%s);\n'], ...
                outputName, type, l2s(outputStruct.isArray));
        end
    else
        % derived type: need to get an instance of the MATLAB class from the Java
        % object using the static getInstance method: 
        %      rval = MCLASS.getInstance(rval,isArray);
        assert(~isempty(outputStruct.javaClass))
        code = sprintf([indent '%s = %s.getInstance(ret,%s);\n'], ...
                       outputName, outputStruct.matlabClass, l2s(outputStruct.isArray));
    end
end

%===============================================================================
function writemfile(fname,C)
    % Write a cell to file.

    C = cellstr(C);
    count = 0;
    fid = fopen(fname,'w');
    cleanup = onCleanup(@()fclose(fid));
    for i = 1:length(C)
        % skip lines beginning with %%
        linelen = length(C{i});
        if linelen < 2 || ~strcmp(C{i}(1:2),'%%')
            count = count + fprintf(fid,'%s\n',C{i});
        else 
            count = count + linelen + 1;
        end
        msg = ferror(fid);
        if ~isempty(msg)
            error(message('MATLAB:webservices:WriteError', fname, msg))
        end
    end
end

%=============================================================================
function res = uniqueGetMethodName(name, names)
    % Return name if it's not in the cell array names
    % Otherwise return nameObj if it's not in the cell array
    % Otherwise return nameObj1, nameObj2, ...
    % If we give up, returns empty.
    if any(strcmp(names, name)) 
        % Append 'Object' and if that doesn't work, a number
        res = [name 'Object']; 
        objname = res;
        for j = 1 : 1000
            if ~strcmp(res, names), return, end
            res = [objname num2str(j)];
        end
        res = [];
    else
        res = name;
    end

end

%=============================================================================
function desc = getMATLABArgDescription(localType, isArray)
    % Return a string describing the MATLAB argument for the specified XML type. This
    % is used in the documentation of the argument of a generated function. It
    % describes all MATLAB types acceptable to the function. The types returned here
    % are those acceptable to matlab.wsdl.internal.fromMATLAB. The string
    % returned names the MATLAB type and the XML type, if different, e.g.:
    %     'numeric scalar (XML long)'
    switch localType
        case {'string','Qname','NOTATION'}
            if isArray 
                desc = 'string or cell array of strings';
            else
                desc = 'string';
            end
            return;
        case {'date','dateTime'}
            if isArray 
                desc = 'vector of datetime objects';
            else
                desc = 'datetime object';
            end
        case 'time'
            if isArray
                desc = 'vector of duration or datetime objects';
            else
                desc = 'duration or datetime object';
            end
        case 'duration'
            if isArray
                desc = 'vector of duration or calendarDuration objects';
            else
                desc = 'duration or calendarDuration object';
            end
        case 'boolean'
            if isArray
                desc = 'locical or numeric vector';
            else
                desc = 'logical or numeric scalar';
            end
        case {'hexBinary','base64Binary'}
            desc = 'vector of numbers 0-255';
        case {'anyType','anySimpleType'}
            if isArray
                desc = 'vector of any type';
            else
                desc = 'any type';
            end
        otherwise
            if isArray
                desc = 'numeric vector';
            else
                desc = 'numeric scalar';
            end
    end
    desc = [desc ' (XML ' localType ')'];
end

%=================================================================================

function tf = l2s(v)
    % Convert logical to string
    if v 
        tf = 'true';
    else
        tf = 'false';
    end
end

%============================================================================
function res = existFile(dirName, fileName)
    % Search for existence of fileName in dirName recursively
    fn = fullfile(dirName, fileName);
    res = exist(fn,'file') ~= 0;
    if ~res
        dirs = dir(dirName);
        dirsAt = [dirs.isdir];
        subdirs = {dirs(dirsAt).name};
        subdirs = subdirs(~ismember(subdirs,{'.','..'}));
        res = any(cellfun(@(dir) existFile(dir,fileName), fullfile(dirName,subdirs)));
    end
end

%===========================================================================
function res = addUnique(c,s)
    % append S to cell array C if it's not already there
    res = c;
    if ~isempty(s)
        if isempty(c) || ~any(strcmp(c,s))
            res = [c s];
        end
    end
end

%===========================================================================
function res = append(c,s)
    % Append s to c, avoiding inspector warning.  c can be an array or cell array.
    % If both are cell arrays, concatentate them.
    res = c;
    if ~isempty(s)
        res = [c s];
    elseif iscell(c) && ischar(s)
        % we need to allow an empty string to be appended as another element to a
        % cell array
        res = c;
        res{end+1} = s;
    end
end

%===========================================================================
function res = makeValidName(name,suffix)
    % Make a name that is a valid property, variable or method name.
    if iscell(name) 
        res = cellfun(@(x) makeValidName(x), name, 'UniformOutput', false);
    else
        res = matlab.lang.makeValidName(name);
        if iskeyword(res) || ...
            any(strcmp({'events','properties','methods','enumeration'},res))
            if nargin > 1 
                res = [res suffix];
            else
                res = [res '_'];
            end
        end
    end
end

%============================================================================
function checkClassInPath(destDir, name, silentState)
    % Issue a warning if we find name on the path as but it's not the the one at
    % dirname.  Also tell user if it's not on the path.
    
    % get absolute path of file we're looking for
    name = [name '.m'];
    namePath = fullfile(destDir,name);
    nameFile = java.io.File(namePath);
    if ~nameFile.isAbsolute
        namePath = fullfile(pwd,destDir,name);
        nameFile = java.io.File(namePath).getCanonicalFile;
    end
    % Get all locations of name in path
    locs = which(name,'-all');
    for i = 1 : length(locs)
        loc = locs{i};
        locFile = java.io.File(loc).getCanonicalFile;
        if locFile.equals(nameFile)
            % we found it in the path
            if i ~= 1
                % not first in path means it's shadowed
                warning(message('MATLAB:webservices:ClassOnWrongPath', ...
                                locs{1}, namePath, name));
            end
            return
        end
    end
    % if we get here we didn't find it in path
    if ~silentState
        pathDir = fileparts(namePath);
        disp(message('MATLAB:webservices:AddPath',name,pathDir,pathDir).getString);
    end
end

%=============================================================================
function schemaType = getSchemaType(namespaceURI, schemaCol, element)
    % Return the schemaType for an element, chasing through "ref" attributes
    %  namespaceURI the URI of the namespace referencing this
    %  schemaCol   xmlSchemaCollection
    %  element     XmlSchemaElement
    %  schemaType  XmlSchemaType
    
    typeName = element.getSchemaTypeName;
    if ~isempty(typeName)
        schemaType = schemaCol.getTypeByQName(typeName);
        if isempty(schemaType) 
            error(message('MATLAB:webservices:NoElementType', ...
                char(typeName.toString), char(element.getQName.toString)));
        end
    else
        % element has no type of its own, so get from reference
        nextElement = element;
        while isempty(nextElement.getSchemaType) && ~isempty(nextElement.getRefName)
            refName = nextElement.getRefName;
            refURI = refName.getNamespaceURI;
            if isempty(refURI) 
                refURI = namespaceURI;
            end
            % form a new QName from the reference URI and the local part of the ref
            % QName
            qname = javax.xml.namespace.QName(refURI, refName.getLocalPart);
            nextElement = schemaCol.getElementByQName(qname);
            if isempty(nextElement)
                error(message('MATLAB:webservices:CouldNotFindElement', ...
                    char(qname.toString), char(element.getQName.toString)));
            end
        end
        schemaType = nextElement.getSchemaType;
        
    end
end   

%============================================================================
function res = mangleName(name,capitalize)
     % Roughly replicate the algorithm in apache\cxf\tools\util\NameUtil.java to 
     % convert a WSDL name to a Java identifier.  This is needed so
     % that we can call the Java functions created by wsdl2java. 
     %   capitalize - case of 1st character: -1 lower, 0 leave, +1 upper
     if nargin == 1
         capitalize = 0;
     end
     delim = false;
     % Uppercase first letter of every "word" except the first
     for i = 1 : length(name)
         c = name(i);
         if strfind('_.:-', c)
             delim = true;
         else
             if delim
                 name(i) = upper(c);
             end
             delim = false;
         end
     end
     % Remove special characters 
     res = regexprep(name,'[^a-zA-Z0-9]','');
     if capitalize < 0
         res(1) = lower(res(1));
     elseif capitalize > 0
         res(1) = upper(res(1));
     end
end

%===========================================================================
function [name, qname] = getTypeName(type)
    % Return the name and qname for a QName or XMLSchemaType
    %  name  a string naming the element
    %  qname its Java QName, which is same as type if it's already a QName
    if isa(type,'javax.xml.namespace.QName')
        qname = type;
    else
        qname = type.getQName;
    end
    name = char(qname.getLocalPart);
end
     
%===========================================================================
function tf = isSchemaType(item, type)
    % Return true if item is a Java object of the specified XML schema type
    tf = isa(item, ['org.apache.ws.commons.schema.XmlSchema' type]);
end
             

   
            
