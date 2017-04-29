function [T,A] = extract(N,port,offset)
%extract Polls sensor connected to COM4 for time/acceleration data
%   [T,A] = extract(N,port,offset) extracts time in seconds (T) and z-acc. 
%   (m/s/s) given a # of samples, N, port identifier ('COM4'), and raw
%   offset value
%   ---
%   Authour: Chris Williams | Last Updated: April 26, 2017
%   McMaster University 2017

%Open serial communications
imu = serial(port,'BaudRate',115200);
fopen(imu);

%Poll sensor
y = zeros(N,4);
fprintf('Polling IMU on %s...\n', port)
for i=1:N
        y(i,:) = eval( [ '[', fscanf(imu), ']' ] );
end

%Scale data
T = y(:,1);
T = (T-T(1))/1000;

A = y(:,4);
A = (A - offset)*9.80665;

%Close serial communications
fclose(instrfind);

fprintf('Data capture complete\n')
% beep;
end
