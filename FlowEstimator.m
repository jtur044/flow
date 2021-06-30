classdef FlowEstimator < handle
    
    %FLOWESTIMATOR Flow estimator 
    
    properties 
        
        
        %% generated information
        Im = []; 
        lastIm;
        
        %% configuration parameters
        config;
        
        %% data information 
        flowData = [];
        opticFlow;
        
        firstTime = true;
        
    end
    
    methods 
        
        
        function obj = FlowEstimator (config)
        
            obj.config = config;                       
            args = namedargs2cell(config);
            obj.opticFlow = opticalFlowLK(args{:});
            obj.flowData  = FlowData ();
            
        end
        
        function step (obj, Im)

            %% save data
            obj.lastIm = obj.Im;
            obj.Im = Im;
            
            if (obj.firstTime)
                obj.firstTime = false;
                return
            end
            
                                    
            %% flow as FIELDS of Vx & Vy             
            flow = estimateFlow(obj.opticFlow, im2gray(Im));                                
            set(obj.flowData, flow);
            
        end
        
        
        
        function show(obj)
            
            if (~isempty(obj.Im) & ~isempty(obj.lastIm))

                imshow(obj.Im)
                hold on
                plot(obj.flow,'DecimationFactor',[5 5],'ScaleFactor',10,'Parent',hPlot);
                hold off

            end
            
        end 
 

    end
    
end

