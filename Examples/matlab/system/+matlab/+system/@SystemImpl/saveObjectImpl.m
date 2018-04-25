% saveObjectImpl Default definition of the saveObjectImpl method
% S = saveObjectImpl(OBJ) converts object OBJ to struct S with the
% following attributes for saving to a MAT file.
%   * All public (with public set and public get) non-transient 
%     properties of OBJ are added to S    
%   * State information is added to S
