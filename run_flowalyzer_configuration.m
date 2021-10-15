%function run_flowalyzer_configuration ()

% RUN_FLOWALYZER_CONFIGURATION Run the FLOWALYZER SETUP
%
% This will input "flowalyzer-config.json" and output a  
% "flowalyzer-config.tiled.json"
%
%


configuration = load_configuration ('./config/flowalyzer-config.json');

%savejson ([], configuration, './config/flowalyzer-config.tiled.json');
%return

%% add tiled-regions flowalyzer 

h      = 64;
width  = 192;
height = 192;
ww     = 64;
wh     = 64;


configuration.image.width  = width;
configuration.image.height = height;
configuration.ROI = [];
configuration.OUTPUT = [];


fprintf ('Tiles.\n');
fprintf ('\n');


%% COMPONENT TILES 
c = 1; oc =1;
J = width/h;
K = height/h;
for j = 1:J
    for k = 1:K
                
        
        x               = h*(j - 1) + 1;
        y               = h*(k - 1) + 1;     
        nm              = sprintf('tile-%d', c);
        configuration.ROI(c).name            = nm;
        configuration.ROI(c).type            = 'static';
        configuration.ROI(c).row             = k;
        configuration.ROI(c).col             = j;
        configuration.ROI(c).x               = x;
        configuration.ROI(c).y               = y; 
        configuration.ROI(c).w               = ww;
        configuration.ROI(c).h               = wh;
        configuration.ROI(c).style.color     = 'red';
        configuration.ROI(c).style.linewidth = 2;
        fprintf ('- %d. name=%s, (row,col)=(%d, %d), (x,y)=(%d,%d)\n', c, nm, k, j, x, y);
        c = c + 1;
        
        % vx & vy-output
        nm_out = sprintf('out-%d-V', c-1);        
        configuration.OUTPUT(oc).name  = nm_out;
        configuration.OUTPUT(oc).show  = true;
        configuration.OUTPUT(oc).index = oc;
        configuration.OUTPUT(oc).selectROI   = nm;
        configuration.OUTPUT(oc).fn    = 'mean';
        fprintf ('-- %d. name="%s", fn="%s" (Vx & Vy)\n', oc, nm_out, configuration.OUTPUT(oc).fn);
        oc = oc + 1;
        
    end
end


%% GLOBAL TILE 

x               = 1;
y               = 1;     
configuration.ROI(c).name            = 'global';
configuration.ROI(c).type            = 'static';
configuration.ROI(c).row             = 0;
configuration.ROI(c).col             = 0;
configuration.ROI(c).x               = x;
configuration.ROI(c).y               = y; 
configuration.ROI(c).w               = width;
configuration.ROI(c).h               = height;
configuration.ROI(c).style.color     = 'magenta';
configuration.ROI(c).style.linewidth = 2;
fprintf ('- %d. name=%s, (row,col)=(%d, %d), (x,y)=(%d,%d)\n', c, nm, k, j, x, y);

savejson ([], configuration, './config/flowalyzer-config.tiled.json');


% configuration
% end