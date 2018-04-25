function tf = licensed(parts, schema)
% LICENSED Are the all the parts covered by a valid license?
%
% PARTS: Cell-array of strings. (Or a single string.)
% SCHEMA: A Schema object; set of heuristics influencing dependency analysis.
%
% Licensing in a deployed application is fundamentally different than
% licensing in MATLAB: the license manager is not deployed. That means all
% license management decisions must be made at application build time and 
% none may be deferred until runtime. Consequences:
%
%  1) LICENSED returns true for those normally-licensed functions for which
%     a license is available in the current MATLAB session. Normal licenses
%     have the same effect on function execution in deployed applications as
%     they do in MATLAB -- that is, the absence of a license prevents the
%     function from being included in the deployed application, and therefore
%     prevents its execution.
%
%  2) Shared-license functions (see src/services/lmgr/lmgrdata.xml) depend
%     on the runtime call-tree for authorization (in the interesting case, 
%     where a normal license is not available but a shared license is).
%     Deployed applications have no license manager, and cannot manage 
%     entitlements at runtime. Consequences:
%
%       a) LICENSED uses the transitive closure of the authorizing functions
%          as a proxy for the runtime call tree. A function with a shared
%          license is included in the deployed application if its authorizing
%          function appears in the 
%
%       b) Non-authorized clients may call any shared function included in
%          the deployed application.
%
% Deployed applications offer a weaker guarantee for shared functions. In
% theory this opens a security hole. In practice however, this hole is kept
% mostly closed by the in-MATLAB behavior. Developing an application in which
% non-authorized clients call shared functions is difficult, since the 
% application will not run in MATLAB. It is possible, however, and will
% remain possible unless and until the MCR provides runtime license management.
%
%
% Algorithm:
%   Inputs: List of parts, Schema object
%
%   1) Determine the components that own the parts.
%   2) Query MATLAB to determine which components have available licenses.
%   3) Filter the parts against the licenses.
%   4) Examine the licensed functions for authorized clients.
%   5) Temporarily enable licenses for appropriate (authorized) shared 
%      function providers (components that provide shared functions to the
%      authorized functions).
%   6) If any new licenses added to list and unlicensed functions remain,
%      go back to step 3).
    
    % Get the Schema's DependencyDepot object.
    dd = schema.depDepot;

    % Helper function to determine if a part's component is licensed.
    function tf = licensedPart(part, fileID, componentID, ...
                               componentList, authorizedClients, dd)
        tf = true;        
        if isKey(knownParts, part)
            fID = knownParts(part);
            idx = fileID == fID;
            cID = componentID(idx);
            tf = any(ismember(cID, componentList));

            % If authorizedClients is non-empty, a file must be required by
            % an authorized client in order to be licensed. If the list is
            % empty, authorization is granted if the part belongs to any
            % component on the component list.
            if ~isempty(authorizedClients)
                tf = tf && dd.requires(authorizedClients, fID);
            end
        end
    end

    % If there's no database, every part is licensed.
    tf = true(1,numel(parts));
    
    % P-files are not recorded in Table Component_Membership.
    % If we find P-files in the part list, ask for their
    % correspondent MATLAB files instead. By doing so, the component ID
    % of P-files will no longer be 0. 
    %
    % We are not going to write P-files into Table
    % Component_Membership, because that won't help us solve the
    % problem caused by the race condition between p-code generation 
    % on the prebuild platform and database building on other platforms. 
    parts = regexprep(parts, '\.p$', '.m');
    
    % If there's a database, determine which component each part
    % belongs to.
    if ~isempty(dd)
        % Licenses only apply to certain "protected" directories. If the
        % part is not in a protected directory, then it is automatically
        % licensed.
        protected = dd.protectedByLicense(parts);

        % This is potentially slow, as it needs to consult the database, 
        % so only ask this question for protected files.
        % knownParts uses platform-specific file seperators.
        [knownParts, componentID, fileID] = dd.componentMembership(parts(protected));

        % If there's no database, or if the component membership table is empty,
        % every part is licensed.
        if ~isempty(componentID)

            % Determine which components we have valid licenses for
            componentList = unique(componentID);
            licenseInfo = dd.getLicenseInfo(componentList);
            
            % Remove licenses that have empty name.
            % This is a work around, since license('test','') sometimes
            % crazily returns true.
            nonEmptyNameIdx = ~cellfun('isempty',{licenseInfo.name});
            licenseInfo = licenseInfo(nonEmptyNameIdx);

            % Find installed licenses
            installedLicIdx = cellfun(@(l)license('test',l) == 1, ...
                                      {licenseInfo.name});
            licenseInfo = licenseInfo(installedLicIdx);
            newLicenses = false;
            if ~isempty(licenseInfo)
                componentList = [licenseInfo.component];
                newLicenses = true;
                unresolved = protected; % Unprotected files are licensed.
            else
                % No license installed for files in the protected dirs.
                tf(protected) = false;
            end

            % The list of shared services is initially empty
            serviceList = int64([]);
            
            while newLicenses
                % Assume parts list adds no new licenses.
                newLicenses = false;

                % Set TF: true if the part's component is on the list of
                % licensed components, false otherwise.
                allowed = '';                                
                if iscell(parts)
                    isLicensed = cellfun(...
                        @(p)licensedPart(p, fileID, componentID, ...
                                         componentList, serviceList, dd), ...
                        strrep(parts(unresolved),'/',filesep));
                    tf(unresolved) = isLicensed;
                    unresolved = ~tf;

                    % Licensed parts
                    allowed = parts(tf);
                elseif ischar(parts)
                    tf = licensedPart(parts, fileID, componentID, ...
                                      componentList, serviceList, dd);
                    unresolved = false;
                    if tf, allowed = parts; end
                end

                % Do the licensed parts enable any shared licenses?
                [sharedComponents, sharedServices] = ...
                    dd.sharedLicenseEntitlements(allowed);

                % Only consider licenses that we have not already processed
                sharedComponents = setdiff(sharedComponents, componentList);
                sharedServices = setdiff(sharedServices, serviceList);

                % Add new licenses to component list and keep processing.
                if any(unresolved)
                    if ~isempty(sharedComponents)
                        componentList = sort([componentList sharedComponents]);
                        newLicenses = true;
                    end
                    if ~isempty(sharedServices)
                        serviceList = sort([serviceList sharedServices]);
                        newLicenses = true;
                    end
                end
            end
        end
    end
end

