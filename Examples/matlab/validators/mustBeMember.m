function mustBeMember(A, B)
%MUSTBEMEMBER Validate value is member of sepcified set or issue error
%   MUSTBEMEMBER(A, B) issues an error if A is not a member of B.
%   MATLAB calls ismember(A,B) to determine if A is a member of B.
%
%   Class support:
%   All numeric classes, logical, char, cellstr
%   MATLAB classes that define an ismember method.
%
%   See also: ismember
    
%   Copyright 2016 The MathWorks, Inc.
    if ~all(reshape(ismember(A, B), [], 1))
        throw(...
            createValidatorExceptionWithValue(...
                createPrintableList(B),...
                'MATLAB:validators:mustBeMemberGenericText',...
                'MATLAB:validators:mustBeMember'...
                )...
        );
    end
end
