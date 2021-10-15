classdef FlowOutput < handle 

    properties 
    
            %% region information 
            config;
            index; 
            name;                
            type;
            x;
            y;
            
            CurrentTime = 0;
            LastTime = 0;
            data;
    end
     
    methods 

        function obj = FlowOutput (index, config)

                obj.index   = index;
                obj.config  = config;
                obj.data    = FlowOutputData ();
        end
                
        function s = get (obj)
            
            s = struct( 'CurrentTime',  obj.CurrentTime, ... 
                        'index',        obj.config.index, ...             
                        'name',         obj.config.name, ... 
                        'selectROI',    obj.config.selectROI, ...
                        'Vx', obj.data.Vx, ...
                        'Vy', obj.data.Vy, ... 
                        'X',  obj.data.X, ... 
                        'Y',  obj.data.Y);
        end
        
        function update(obj, regions, CurrentTime)
                
            obj.LastTime    = obj.CurrentTime;
            obj.CurrentTime = CurrentTime;
            dT = obj.CurrentTime - obj.LastTime;
            
            
            %% get the Region and opticFlow object 
            region_data = regions(obj.config.selectROI);
            of = get(region_data);              

            if (isempty(of))
                fprintf ('"%s" Region not ready.\n', obj.config.name);
                return
            end
            
            Vx = of.Vx;
            Vy = of.Vy;
            
            %% configuration 
            switch (obj.config.fn)
            
                case { 'mean' }    
                    
                    %N = sum((Vx ~= 0) | (Vy ~= 0), 'all');
                    Vx = mean2(Vx)/dT;
                    Vy = mean2(Vy)/dT;                    
                    obj.data.update(Vx, Vy, dT);                    
                    return
                    
                case { 'sum' }     
                    
                    Vx = sum(Vx, 'all');
                    Vy = sum(Vy, 'all');                    
                    obj.data.update(Vx, Vy, dT);                    
                    return
                    
                otherwise 
                    error ('Unkown FN call.');
            end
        end
        
    end
end




