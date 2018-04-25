classdef DataManager < handle
    % DATAMANAGER manages the data required for the WizardController
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties(Constant)
        validationFuncMap = ["LUT", "isLUTBlock";
            "Math", "isMathFunctionBlock"];
    end
    properties(SetAccess = private, GetAccess=private)
        Problem
        Solution
        SelectedType
        AllowUpdateDiagram
        BlockPath
        DesignTypeInfo
        LUTInfo
        Units = 'bytes'
        DataAdapter
    end
    
    methods
        function this = DataManager()
            dataAdapter = FuncApproxUI.Web.DataAdapter();
            this.setDataAdapter(dataAdapter);
            this.setAllowUpdateDiagram(false);
        end
    end
    
    methods(Hidden)
        function selection = getSelectedType(this)
            selection = this.SelectedType;
        end
        
        function setSelectedType(this, selection)
            this.SelectedType = selection;
        end
        
        function setPath(this, path)
            this.BlockPath = path;
        end
        
        function path = getPath(this)
            path = this.BlockPath;
        end
        
        function dataAdapter = getDataAdapter(this)
            dataAdapter = this.DataAdapter;
        end
        
        function setDataAdapter(this, dataAdapter)
            this.DataAdapter = dataAdapter;
        end
        
        function setAllowUpdateDiagram(this, allowUpdateDiagram)
            this.AllowUpdateDiagram = allowUpdateDiagram;
        end
        
        function allowUpdateDiagram = getAllowUpdateDiagram(this)
            allowUpdateDiagram = this.AllowUpdateDiagram;
        end
        
        function solution = getSolution(this)
            solution = this.Solution;
        end
        
        function setSolution(this, solution)
            this.Solution = solution;
        end
        
        function setProblem(this, problem)
            this.Problem = problem;
        end
        
        function problem = getProblem(this)
            problem = this.Problem;
        end
        
        function designTypeInfo = getDTInfo(this)
            designTypeInfo = this.DesignTypeInfo;
        end
        
        function setDTInfo(this, designTypeInfo)
            this.DesignTypeInfo = designTypeInfo;
        end
        
        function lutInfo = getLUTInfo(this)
            lutInfo = this.LUTInfo;
        end
        
        function setLUTInfo(this, lutInfo)
            this.LUTInfo = lutInfo;
        end
        
        isPathValid = validateBlockPath(this, blockPath);
        updateOptions(this, data);
        data = updateOptimize(this, options);
        designTypeInfo = updateDesignTypeInfo(this, designTypeInfo);
        designTypeInfo = packageDesignTypeInfo(this);
        preOptimizeData = getPreOptimizeData(this);
        originalTable = getOriginalTable(this);
        data = getOriginalMemData(this);
        optimizedTable = getOptimizedTable(this);
        data = getOptimizedMemData(this);
        designTypeInfo = getDesignTypeInfo(this);
        blockPath = getCurrentBlockPath(this);
        preOptimizeData = createPreOptimizedStruct(this);
        createOptimizationTable(this);
    end
end