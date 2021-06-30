close all;

h = 192;

Bk = 0.5*ones(192, 192, 3);

x = h/2;
y = h/2;
r = 16;

Total  = 5;  % seconds
T = 0.6;
f = 30; % frame-ratae
y0 = h/2;

t = 0:(1/f):Total;
A = 0.2*r; 
y = A * sawtooth (2*pi*t/T) + y0;

%% OUTPUT 

VidObj = VideoWriter('./data/Simulation/simulation.avi', 'Uncompressed AVI'); %set your file name and video compression
VidObj.FrameRate = f; %set your frame rate
open(VidObj);
Mov = zeros(h,h,3, length(t));
for k = 1:length(t)

    Im = insertShape(Bk, 'FilledCircle', [x y(k) r], 'Color', 'black');
    Mov(:,:,k) = rgb2gray(Im);
    writeVideo(VidObj,Mov(:,:,k));
    
end

close(VidObj);

!ffmpeg -y -i "./data/Simulation/simulation.avi" -vcodec libx264 -pix_fmt yuv420p "./data/Simulation/simulation.mp4"
