function [t, V, maxtab] = detectblinkv (t, V, fps, varargin)


p = inputParser ();
p.addOptional ('blink_duration', 0.5);
p.addOptional ('blink_threshold', 1);
p.parse(varargin{:});
res = p.Results;
th  = res.blink_threshold;
T   = res.blink_duration;

%% time constant 
%t = ((1:length(V))-1) / fps;

%% detect Blink Like features 
sigma = T/5;  %% 5 standard 
t0  = linspace(-T/2,T/2,T*fps); 
f   = wavepacket (t0,T,sigma);

%% The correlation 
[c0, lags] = xcorr (V, f);
i  = (lags >= 0);
c  = c0(i);

%% Maxima correspond to peaks 
%
% this is from "eyetrack/extra/peakdet.m"
[maxtab, mintab] = peakdet(V, 0.1*th);

i = mintab(:,2) < -th;
mintab = mintab(i,:);
t = t(mintab(:,1));
V = V(mintab(:,1));

end