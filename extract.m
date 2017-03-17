function [T, Fs, A, V, S, zV, zS, LOCS] = extract(filename)
%CPR_intg Process raw accelerometer data from CPR compressions
%   [T, Fs, A, V, S, zV, zS, LOCS] = extract(filename) calls 
%   importdata to extract time data (data column #1) and proper
%   acceleration data (data column #4). 
%   
%   Using this data CPR_intg performs numerical integration
%   (using the trapezoidal rule) and returns the elapsed times T, sampling 
%   frequency Fs, trimmed accerleation A, velocity V, and displacement S 
%   as column vectors.
%
%   Also returned are velocities zV, and displacements zS, computed using a
%   zero-reset algorithm to compensate for drift over the interval of a
%   single compression
%

%Extract Raw Data
Acc = importdata(filename);
T = Acc.data(:,1);
A = Acc.data(:,4);

Ts = (T(2)-T(1));
Fs = 1/Ts;
% [bh,ah] = butter(2,0.04,'high');
% plot(t,a,t,filter(bh,ah,a))

%Rough normalization of acceleration signal for initial peak detection
a2 = (A - mean(A))*9.80665;%

aInit = find(a2<min(a2)/2,1);
startIndex = find(T == floor(T(aInit)),1);
aFinal = find(fliplr(a2)>max(a2)/3,1);
endIndex = find(T == ceil(T(end - aFinal)),1);

%Normalize using no-motion mean,
A = (A - mean(A(1:startIndex)))*9.80665;

%Trim Data
T = T(startIndex:endIndex);
A = A(startIndex:endIndex);

% Detect compression indicator peaks
[pks,LOCS] = findpeaks(A,'MINPEAKHEIGHT',-.5);
LOCS = LOCS(pks<1.25);
pks = pks(pks<1.25);

%Remove pre-peaks
for i = 2:length(LOCS)
    if LOCS(i)-LOCS(i-1) < 15
        LOCS(i-1) = 0;
        pks(i-1)  = 0;
    end
end

pks = pks(LOCS~=0);
LOCS = LOCS(LOCS~=0);

%Initialize integrated values
V = zeros(length(T),1);
S = V;
s2 = V;
zV = V;
zS = V;

%Manual zeroing of acceleration signal
A(1:LOCS(1)-20)=0;

%Compute raw velocity & displacement
for i = LOCS(1):length(V)
    V(i) = V(i-1)+(A(i)+A(i-1))*Ts/2;
    S(i) = S(i-1)+(V(i)+V(i-1))*Ts/2;
end

% Detrend and zero velocity
v2 = detrend(V);
v2 = v2 - v2(1);

%Compute displacement from detrended velocity signal
for i = LOCS(1):length(V)
    s2(i) = s2(i-1)+(v2(i)+v2(i-1))*Ts/2;
end

%Detrend displacement
s2 = detrend(s2);

%Zero-reset algorthim (not perfectly synced)
for i = LOCS(1):length(V)
    if any(LOCS == i)
        zV(i) = 0;
        zS(i) = 0;
    else
        zV(i) = zV(i-1)+(A(i)+A(i-1))*Ts/2;
        zS(i) = zS(i-1)+(zV(i)+zV(i-1))*Ts/2;
    end
end

if nargout == 0
    showsignals
end

end

