classdef InspectorWorkspace < ...
		internal.matlab.variableeditor.MLWorkspace
	% A "Workspace" to retrieve component handles and give them to the
	% Inspector
	%
	% - When an App Model is created, it will create a Workspace around the
	% figure
	%
	%  - The Workspace registers itself with the Inspector framework using a
	%  key (based on the app model peer node)
	%
	% - This key is used when a selection happens in the view, and an
	% object needs to be retrieved.  The InspectorWidget will have
	% inspect() called, giving it the currently selected component peer
	% node ID and the workspace key.
	%
	% - This class's evalin() method is called, and is given the peer node
	% ID.  This class uses that ID to find the component handle and hand it
	% off to the Inspector.  Its properties are extracted, sent back tot he
	% view, and the Inspector is populated
	
	properties
		% Figure that is being inspected
		UIFigure
		
		% Workspace Key
		WorkspaceKey
	end
	
	methods
		function obj = InspectorWorkspace(uiFigureHandle, workspaceKey)
			
			narginchk(2,2);
			
			obj.UIFigure = uiFigureHandle;
			obj.WorkspaceKey = workspaceKey;
			
			% Register this workspace
			inspectorFactory = internal.matlab.inspector.peer.InspectorFactory.getInstance();
			
			workspace = obj;
			inspectorFactory.PeerManager.registerWorkspace(workspace, workspaceKey);
		end
		
		function delete(obj)
			% Unregister
			
			inspectorFactory = internal.matlab.inspector.peer.InspectorFactory.getInstance();									
			peerManager = inspectorFactory.PeerManager;
			
			peerManager.deregisterWorkspace(obj.WorkspaceKey);
		end
		
		
		function componentToInspect = evalin(obj, componentPeerNodeId)
			% Given a component ID...
			%
			% Return the model handle to inspect
			
			% strip out any dangling '''s
			componentPeerNodeId(componentPeerNodeId == '''') = [];
			
			allChildren = appdesigner.internal.application.getDescendants(obj.UIFigure);
			componentToInspect = appdesservices.internal.interfaces.controller.DesignTimeParentingController.findChild(allChildren, componentPeerNodeId);
		end
	end
end

