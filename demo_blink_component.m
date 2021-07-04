

%% define output files 

%% Saaed
%% !ffmpeg -y -i eye0.mp4 -filter:v fps=30 eye0.reduced.mp4

inputVideo      = './data/Saaed/eye0.reduced.mp4';
outputVideo     = './data/Saaed/clip0.result.mp4';
outputDataFile  = './data/Saaed/clip0.result.csv';



blinks = [ 0, 10 ];
dataTable = readtable (outputDataFile);
figure(1); clf;
show_flowalyzer_result (dataTable, 2,2);


figure(2); clf;
dataTable = filterbycolumn (dataTable, 'name', 'out-5-V');
M = size (blinks, 1);
for k = 1:M
    i = arrayfun( @(x) ((blinks(k,1) < x) && (x < blinks(k,2))), dataTable.CurrentTime);
    eachTable = dataTable (i, :);
    plot(eachTable.CurrentTime, eachTable.Vx, 'k-', 'LineWidth', 1.5);
end    

xlabel ('Time (seconds)');
ylabel ('Horizontal velocity (px/s)');
set(gca, 'FontSize', 20);
grid on;

print(gcf, '-dpng', './figures/figure-blink-example.png');