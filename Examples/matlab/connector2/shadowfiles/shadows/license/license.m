%LICENSE Return license number or perform licensing task.
%   LICENSE, with no arguments, returns the license number for 
%   this MATLAB.
%  
%   The return value is always a string but is not guaranteed to 
%   be a number.  The return value can be the string 'demo' for 
%   demo licenses, 'student' for student licenses, or 'unknown' 
%   if the license number cannot be determined.
%
%   LICENSE('inuse') returns a list of the licenses checked out in
%   the current MATLAB session. In this list, products are listed
%   alphabetically by their license feature names, i.e., the text 
%   string used to identify products in the INCREMENT lines in a 
%   License File (license.dat). Note that the feature names returned
%   in the list contain only lower-case characters. 
%     
%   S = LICENSE('inuse') returns an array of structures, where
%   each structure represents a checked out license. The structures
%   contains two fields: feature and user. The feature field 
%   contains the license feature name. The user field contains the 
%   username of the person who has the license checked out. 
%
%   S = LICENSE('inuse', FEATURE) checks if the product specified by the
%   text string FEATURE is checked out in the current MATLAB session. If  
%   the product is checked out, LICENSE returns the license feature name 
%   and the username in the structure S.  If the product is not currently   
%   checked out, the fields in the structure are empty. 
%
%   The FEATURE string must be a license feature name, spelled exactly as 
%   it appears in the INCREMENT lines in a License File. For example, the  
%   string 'Identification_Toolbox' is the feature name for the System 
%   Identification Toolbox. The FEATURE string is not case-sensitive and 
%   must not exceed 27 characters. 
%
%   LICENSE('test', FEATURE) tests if a license exists for the product
%   specified by the text string FEATURE. The LICENSE command returns
%   1 if the license exists and 0 if the license does not exist.
%
%   Note: Testing for a license only confirms that the license
%   exists. It does not confirm that the license can be checked
%   out. For example, LICENSE will return 1 if a license exists,
%   even if the license has expired or if a system administrator
%   has excluded you from using the product in an options file.
%   The existence of a license does not indicate that the product 
%   is installed.
% 
%   LICENSE('test', FEATURE, TOGGLE) enables or disables testing
%   of the product, FEATURE, depending on the value of TOGGLE.
%   If you set TOGGLE to 'enable', the syntax LICENSE('test',FEATURE)
%   will return 1 if the product license exists and 0 if the product
%   license does not exist. If you set TOGGLE to 'disable', this 
%   syntax will always return 0 (product license does not exist) 
%   for the specified feature. 
%   
%   Note: Disabling a test for a particular product can impact
%   other tests for the existence of the license, not just
%   tests performed using the LICENSE command.
% 
%   LICENSE('checkout', FEATURE) checks out a license for
%   the product specified by the text string FEATURE, returning 1
%   if the license is checked out or 0 if the license could not be
%   checked out. 
%
%   Examples
%
%   % Get the license number of the current MATLAB.
%   license
%
%   % Get a list of all the licenses currently in use.
%   license('inuse')
%
%   % Get a list of licenses in use with information about who is
%   % using the license.
%   S = license('inuse')
%
%   % Determine if the license for MATLAB is currently in use. 
%   S = license('inuse','MATLAB')
%
%   % Determine if a license exists for a product.
%   license('test','map_toolbox')
%
%   % Check out a license for the Control Systems Toolbox.
%   license('checkout','control_toolbox')
 
%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.2.2.7 $  $Date: 2008/12/08 21:54:14 $
%   Built-in function.
function [varargout] = license(varargin)

if nargin == 0
    import com.mathworks.matlabserver.workercommon.client.*;
    clientServiceRegistryFacade = ClientServiceRegistryFactory.getClientServiceRegistryFacade();
    userManager = clientServiceRegistryFacade.getUserManager();
    entitlements = userManager.getEntitledProducts();
    if isempty(entitlements)
        varargout{1} = builtin('license');
    else
        licenses = entitlements.getLicenseNumbers();
        % Fix for g1209424: licenses may be empty even if the set of entitled products is fully populated.
        % Thus, make sure to check that licenses is not empty before indexing to avoid Java errors.
        % Note: this change was necessitated by a change in core MATLAB in which, as of 15b, indexing into an empty
        % Java array causes a Java error, instead of returning an empty array.
        if ~isempty(licenses)
            varargout{1} = char(licenses(1));
        else
            varargout{1} = '';
        end
    end
else
    % Fix for g1228449
    [varargout{1:nargout}] = builtin('license',varargin{:});
end