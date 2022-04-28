function generate_configuration_snippet (outputfile, width, height, ngrid, nlevels)

% GENERATE_CONFIGURATON_SNIPPET Gnerate a snipppet configuration 
%
%  generate_configuration_enippet (outputfile, width, height, ngrid, nlevels)
%
% where 
%
%       outputfile  is the output file 
%       ngrid       is the initial grid resolution
%       nlevels     is the number of levels to go (including the initial)
%
%
% EXAMPLE 
%
% %% mfon 
% outputfile = './data/mfon/snippet.json'
% generate_configuration_snippet (outputfile, 1280, 1024, 4, 3);
%
% %% tneu 
% outputfile = './data/tneu/snippet.json'
% generate_configuration_snippet (outputfile, 832, 702, 4, 3);
%

total = [];

nw = round(linspace (1, width, ngrid+1));
nh = round(linspace (1, height, ngrid+1));


%% global element 

count = 1;
element = [];

%configuration = rmfield (configuration, 'ROI');

configuration.ROI.name   = 'global';
configuration.ROI.level  = 0;
configuration.ROI.number = 1;       
configuration.ROI.type  = 'global';
configuration.ROI.row   = 1;
configuration.ROI.col   = 1;
configuration.ROI.x     = 1;
configuration.ROI.y     = 1;
configuration.ROI.w     = width; 
configuration.ROI.h     = height;
configuration.ROI.style.color = 'red';
configuration.ROI.style.linewidth = 2;      

%% configuration.OUTPUT element 

% configuration = rmfield (configuration, 'OUTPUT');

configuration.OUTPUT.name      = sprintf ('out-%d-V', 0); 
configuration.OUTPUT.show      = true; 
configuration.OUTPUT.selectROI = configuration.ROI.name;        
configuration.OUTPUT.index     = count;       
configuration.OUTPUT.fn        = 'mean'; 

count = count + 1;

%% create sub-elements 

for k = 1:nlevels 
      
   %% grid element 
   %{
       element.name = '';
       element.type = '';
       element.row = '';
       element.col = '';
       element.x = '';
       element.y = '';
       element.w = '';
       element.h = '';
       element.style.color = 'red';
       element.style.linewidth = 2;      
       total(count) = element;
   %}
 
   
   %% gridded elements 
   
   [r0, c0] = meshgrid (1:ngrid, 1:ngrid);
   r0 = r0(:); 
   c0 = c0(:);      
   
   for l = 1:length(r0) 

       configuration.ROI (count).name   = sprintf('grid-%d-%d', k, l);
       configuration.ROI (count).level  = k;
       configuration.ROI (count).number = l;       
       configuration.ROI (count).type  = 'static';
       configuration.ROI (count).row   = r0(l);
       configuration.ROI (count).col   = c0(l);
       configuration.ROI (count).x     = nw(c0(l));
       configuration.ROI (count).y     = nh(r0(l));
       configuration.ROI (count).w     = nw(c0(l)+1) - nw(c0(l)); 
       configuration.ROI (count).h     = nh(r0(l)+1) - nh(r0(l));
       configuration.ROI (count).style.color = 'red';
       configuration.ROI (count).style.linewidth = 2;      
  
       configuration.OUTPUT (count).name      = sprintf ('out-%d-V', count); 
       configuration.OUTPUT (count).show      = true; 
       configuration.OUTPUT (count).selectROI = configuration.ROI (count).name;        
       configuration.OUTPUT (count).index     = count;       
       configuration.OUTPUT (count).fn        = 'mean'; 

       count = count + 1;
            
   end
   
   nw = midpoints (nw);    
   nh = midpoints (nh);    
   ngrid = length (nw)-1;

   
end

%% save the output file 
savejson([], configuration, outputfile);

end

%% Mid-points 

function r = midpoints (w)
    r = [];
    for k = 1:(length(w)-1)

        s1  = w(k);
        s2  = w(k+1);        
        s10 = round (0.5*(s1+s2));             
        r = [ r s1 s10 ];        
    end        
    
    r =  [ r s2 ];
    
end