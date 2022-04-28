

%% define output files 

%% Saaed
%% !ffmpeg -y -i eye0.mp4 -filter:v fps=30 eye0.reduced.mp4

%inputVideo      = './data/Saaed/eye0.reduced.mp4';
%outputVideo     = './data/Saaed/clip0.result.mp4';
%outputDataFile  = './data/Saaed/clip0.result.csv';


%% j_kau 
inputVideo      = './data/j_kau/eye0.reduced.mp4';
outputVideo     = './data/j_kau/clip0.result.mp4';
outputDataFile  = './data/j_kau/clip0.result.csv';

%% j_kau_3
inputVideo      = './data/j_kau/eye0.reduced.mp4';
outputVideo     = './data/j_kau/clip0.result.mp4';
outputDataFile  = './data/j_kau/clip0.result.csv';

%% blink duration 

blink_duration  = 0.5;
fps = 30;

blinks = [ 0, 100 ];
dataTable = readtable (outputDataFile);
figure(1); clf;
show_flowalyzer_result (dataTable, 'tile-6');

% width is about half the period


%% Information 
figure(2); clf;
dataTable = filterbycolumn (dataTable, 'name', 'out-0-V');  %% same as global

M = size (blinks, 1);
for k = 1:M
    
    %% table information 
    i = arrayfun( @(x) ((blinks(k,1) < x) && (x < blinks(k,2))), dataTable.CurrentTime);
    eachTable = dataTable (i, :);
    
    %% input information 
    t  = eachTable.CurrentTime;
    Vx = eachTable.Vx;
    plot(t, Vx, 'LineWidth', 1.5);
    hold on;
    
    %% show detected start of blinks 
    [t0, V0, maxtab] = detectblinkv (t, Vx, fps, 'blink_duration', blink_duration);
    plot (t0, V0, 'rx');

end    

xlabel ('Time (seconds)');
ylabel ('Horizontal velocity');
hold on;


%% should pad this by half the template length
%plot (t, V);
%ylabel ('Cross-correlation');
%set(gca, 'FontSize', 20);
%grid on;

print(gcf, '-dpng', './figures/figure-blink-example.png');