%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% EXTRA FUNCTIONS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef FlowRegion < handle 

    properties 
    
            %% region information 
            config;
            index; 
            name;                
            type;
            x;
            y;
            w;
            h;
            style;
            
            row;
            col;

            data;  
            master;

    end
     
    methods 

        function obj = FlowRegion (index, config, flow)

                obj.config  = config;
            
                obj.index        = index; 
                obj.name         = config.name;                
                obj.type         = config.type;
                obj.x            = config.x;
                obj.y            = config.y;
                obj.w            = config.w;
                obj.h            = config.h;
                obj.row          = config.row;
                obj.col          = config.col;
                
                obj.style        = namedargs2cell(config.style);                
                obj.master       = flow;
                
                update (obj);
        end
        
        %function setMaster (obj, flow)                        
        %        obj.master = flow;                
        %end

        function r = get (obj)                        
                r = obj.data;                
        end
        
        
        function update(obj)
                    
            if (isempty(obj.master))
                fprintf ('"%s" master is EMPTY\n', obj.config.name);
                return
            end   
            
            fprintf ('Generating sub-region.\n');
            
            
            %% create a sub-region of the main FlowData            

            flow = get(obj.master);
            Vx = flow.Vx;
            Vy = flow.Vy;
            
            r1 = obj.y;
            r2 = obj.y + obj.h - 1;
            c1 = obj.x ;
            c2 = obj.x + obj.w - 1;
            
            % create a sub-matrix
            Vx0 = Vx(r1:r2, c1:c2);
            Vy0 = Vy(r1:r2, c1:c2);            
            obj.data = opticalFlow(Vx0,Vy0);
                        
        end
        
        
        function Im = draw (obj, Im)        
            rect = [ obj.x obj.y obj.w obj.h ];    
            Im = insertShape (Im, 'Rectangle', rect, obj.style{:});

        end
        
    end
end



