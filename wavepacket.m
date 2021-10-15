function f = wavepacket (t, T, sigma)

%% WAVEPACKET 
%
%       f = 1/(sigma*sqrt(2*pi))*exp(-0.5*(t/s)^2).*sin(2*pi/T*t);
%  
% where 
%       t is the time points 
%       T is the period of the avepacket 
%       T is the period of the cycle 
%
% EXAMPLE 
%
%  T = 1; sigma = T/5;  %% 4 standard 
%  t = linspace(-0.5,0.5,501); 
%  f = wavepacket (t,T,sigma);
%  plot (t,f);
%

f = 1/(sigma*sqrt(2*pi))*exp(-0.5*(t/sigma).^2).*sin(2*pi/T*t);


return