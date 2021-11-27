classdef FlowAlyzer < FlowEstimator & handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
                
        Result    = [];
        
        %opticFlow = [];
        Region    = [];
        Output    = [];
        
        regionIndex = 0;
        outputIndex = 0;
        
        keys = [];      
        OutputKeys = [];
        
        CurrentTime;        
        outputDataFile;
        
        % firstTime = false;        
        % FlowMap = [];        
        % currIm = [];
        % lastIm = [];
        
        postFn;
        
        fid;
    end
    
    methods

       function obj = FlowAlyzer(config)
            
           
            %% Main FlowEstimator
            obj@FlowEstimator(config)
           
            %% obj.opticFlow = opticalFlowLK('NoiseThreshold',0.009);
            obj.Region = containers.Map();
            obj.Output = containers.Map();            
       end
               
       % Utilize ROI in different ways          
       %
       % EachRegion has a Master FlowData  
       %
       %
       
       function registerROI(obj, region)                 
             
             %% save a new region 
             obj.regionIndex = obj.regionIndex + 1; 
             obj.Region(region.name) = FlowRegion(obj.regionIndex, region, obj.flowData);             
             obj.keys = obj.Region.keys ();

       end
        
       % Utilize ROI in different ways          
       function registerOutput(obj, output)                 
             
             %% save a new region 
             obj.outputIndex = obj.outputIndex + 1; 
             obj.Output(output.name) = FlowOutput(obj.outputIndex, output);
             obj.OutputKeys = obj.Output.keys ();
             
        end
         
        
        %% stepper
        function ret = step(obj, Im, CurrentTime)
                        
            
            %% Estimate over-all flow over entire IMAGE  
            step@FlowEstimator (obj, Im);            
            annotatedIm = Im;
            
            %% Generate updated information (FlowRegion)         
            M = length(obj.keys);
            for k = 1:M                 
               
               eachRegion = obj.keys{k};
               update(obj.Region(eachRegion));                

               
                %% Information 
               if (~isempty(obj.postFn))              
                   obj.postFn (obj.Region(eachRegion));
               end

            end
            
            %% Estimate OUTPUT information  (FlowOutput)                  
            OutputKeys = obj.Output.keys ();
            M = length(OutputKeys);            
            for k = 1:M 
                
                eachOutput = OutputKeys{k};
                allRegions = obj.Region;
                update(obj.Output(eachOutput), allRegions, CurrentTime);                  

    
                %% Information 
                if (~isempty(obj.postFn))
                    obj.postFn (obj.Output(eachOutput));
                end
                
                %ret = getFD(obj.Output(eachOutput));                
            end
            
            % fprintf ('Updated complete.\n');
            
        end
        
        
        function annotatedIm = draw (obj, annotatedIm) 
        
            %% draw on the original
            M = length(obj.keys);
            for k =1:M           
                annotatedIm = obj.Region(obj.keys{k}).draw(annotatedIm);                
            end
        
        end
        
    end
    
    
    methods 
    
        %% OUTPUT 
        
        function open(obj, outputDataFile)        
            obj.outputDataFile = outputDataFile;
            
            if (exist(outputDataFile, 'file'))
                delete (outputDataFile);
            end
            
        end
        
        function write(obj)       
                    
            %% Information 
            OutputKeys = obj.Output.keys ();
            M = length(OutputKeys);            
            for k = 1:M 
     
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                % RECORDS : 
                %
                % timestamp 
                % index  
                % name 
                % Vx
                % Vy
                %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


                %% Get the Output 
                eachOutput      = obj.Output (OutputKeys{k});
                eachRecord      = eachOutput.get();
                eachRegion      = obj.Region(eachRecord.selectROI);
                eachRecord.row  = eachRegion.row;
                eachRecord.col  = eachRegion.col;

                eachRecord = struct2table (eachRecord);

                %eachRecord
                %obj.outputDataFile

                writetable (eachRecord, obj.outputDataFile, 'WriteMode', 'append');

            end

            
        end
    
    end 
end


