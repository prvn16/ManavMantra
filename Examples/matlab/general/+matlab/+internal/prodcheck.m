function prodStructFinal = prodcheck(displayIndividualResults)
% PRODCHECK Check which products are installed and licensed.
%
%    Products are considered to be installed if they are on the path and
%    are reported by the VER command.
%
%    Products are considered to have a license if we can check out a license
%    from this MATLAB session.  If a license is not checked out because all 
%    the keys are in use (an error -4 from the license manager), then we 
%    consider the license to be available since it could be checked out if 
%    someone else was not using it.
%
%    All screen output is also stored in a diary file (using the MATLAB
%    diary command).  The output file is always written into the current directory.
%    The output is also written to a .csv file.
%
%    Inputs: 1 if you want to see the list of products installed, 0 to not
%            display products.  (default is 1 if no input specified).
%
%    Returns: A structure containing all the products that we searched for
%             and the status of each product.

% Copyright 2006-2012 The MathWorks, Inc.

if (nargin == 0)
    displayIndividualResults = true;
end

% Require that the JVM be running
error(javachk('jvm'));

% Get output file names
[diaryname, csvname] = localGetOutputNames;

% enable diary
diary(diaryname);

% Display some info about the machine we are running on
displayMachineInfo;

% Get list of installed products and their data.
prodStruct = buildInstalledProdMap;

% Check if products are installed and licensed.
prodStructFinal = doChecks(prodStruct, displayIndividualResults, csvname);

% Display a summary of results
showSummary(prodStructFinal);

% disable diary
localTurnOffDiary(diaryname, csvname);


%%%%%%%%%%%%%%%%%%%
% Local functions %
%%%%%%%%%%%%%%%%%%%
function prodStruct = buildInstalledProdMap
% Get the list of installed products and their feature names.

prodStruct = struct('ProductName','','FeatureName','',...
                    'ProductVersionAndRelease','','hasLicense','');

structIdx = 1;
verStruct = ver;
verLen = length(verStruct);
for verIdx = 1:verLen
    verEntry = verStruct(verIdx);
    prodName = verEntry.Name; 
    prodIdentifier = com.mathworks.product.util.ProductIdentifier.get(prodName);
    if (~isempty(prodIdentifier))
        prodStruct(structIdx).ProductName = prodName;
        prodStruct(structIdx).FeatureName = char(prodIdentifier.getFlexName);
        prodStruct(structIdx).ProductVersionAndRelease = [verEntry.Version ' ' verEntry.Release];
        prodStruct(structIdx).hasLicense = false;
        structIdx = structIdx + 1;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function inStruct = doChecks(s, displayIndRes, csvFileName)
% Check if installed products are licensed.
% Tries to checkout a license for each product.
% Data is always written in csv format to the csvFileName input name.
%
% Inputs: Structure containing product info
%         Boolean indicating if each product's status should be displayed 
%         as it is checked.
%         The name of the .csv file to write all the data to.
%
% Output: A new structure which is a copy of the input structure, but the 
%         hasLicense field is updated based on this test.

% Check if each product is installed and if there is a license available.
inStruct = s;

% Clear out any existing .csv file
if exist(csvFileName,'file') == 2
    delete(csvFileName);
end

% Set up some static data about this session
licData = license('inuse');
staticInfoStruct.licenseNum = license;
staticInfoStruct.userName = licData(1).user;
staticInfoStruct.machineName = getMachineName;
staticInfoStruct.matlabVersion = version;

for index = 1:length(inStruct)
   [licmsg, licret] = evalc('license(''checkout'', inStruct(index).FeatureName)');
   licstatus = logical(licret);
   if (~licstatus)
       % Check if this failed because all the keys are in use (an error -4).
       % In this case we actually consider the license to be available.
       % As of R2007a we stopped adding a '.' at the end of the string.  
       % This code would also match errors starting with -4, like -40, but
       % all the errors in that range are errors that should never happen
       % in MATLAB.
       lmerrmsg = 'License Manager Error -4';
       if (~isempty(strfind(licmsg,lmerrmsg)))
           licstatus = true;
       end
   end

   inStruct(index).hasLicense = licstatus;

   if displayIndRes
       if (licstatus)
          licenseStr = 'a license.';
       else
          licenseStr = 'no license.';
       end
       disp([inStruct(index).ProductName ' installed and has ' licenseStr]);
   end
   % Send the data to a .csv file
   appendToCsv(csvFileName, staticInfoStruct, inStruct(index));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function appendToCsv(csvFileName, infoStruct, productStruct)
% Append the info to a .csv file.

[fid, errmessage] = fopen(csvFileName, 'at');
if (fid == -1)
    error(message('MATLAB:fileread:cannotOpenFile', csvFileName, errmessage));
end 

% Product, HasLicense, License #,MATLAB Version, Machine Name,Username
fprintf(fid,'%s, %d, %s, %s, %s, %s\n', ...
        productStruct.ProductName, productStruct.hasLicense, infoStruct.licenseNum, ...
        productStruct.ProductVersionAndRelease, infoStruct.machineName, infoStruct.userName );
fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showSummary(s)
%Count the products and display a summary

numInstalled = length(s);
numLicensed = sum([s.hasLicense]);

disp(' ');
disp('Test Summary:');
disp(['Number of products found installed: ' int2str(numInstalled) ]);
disp(['Number of products found installed with a license: ' int2str(numLicensed) ]);
disp('');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayMachineInfo
machineName = getMachineName;
numCPU = 0;
if ispc
    numCPU = getenv('NUMBER_OF_PROCESSORS');
    if (isempty(numCPU)) 
        numCPU = 0;
    end
end

licData = license('inuse');

disp(['Scan for machine ''' machineName ''' on ' date]);
disp(['License number: ' license]);
disp(['User name: ' licData(1).user]);
disp(['MATLAB version: ' version]);
disp(['Installation directory: ' matlabroot]);
disp(['Platform: ' computer]);
if (numCPU ~= 0)
    disp(['Number of CPUs: ' num2str(numCPU)]);
end
disp(' ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineName = getMachineName
[stat, machineName] = system('hostname');
if (stat ~= 0) 
    machineName = 'unknown';
else
    % Need to strip off newline at end of string.
    machineName(end) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fullDiaryName, fullCsvName] = localGetOutputNames
mName = getMachineName;

rightNow = now;
theMonth = datestr(rightNow, 'mmm');
theDay   = datestr(rightNow, 'dd');
theYear  = datestr(rightNow, 'yyyy');
theDate = [theMonth '_' theDay '_' theYear];

baseName = [mfilename '_' mName '_' theDate];
diaryName = [baseName '.txt'];
csvName = [baseName '.csv'];

fullDiaryName = fullfile(pwd, diaryName);
fullCsvName = fullfile(pwd, csvName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localTurnOffDiary(diaryName, csvName)
diary off;
disp(' ');
disp(['Output saved to ' diaryName ]);
disp(['CSV data saved to ' csvName]);





