function [time, accel] = extract(numSamples,PORT,offset)
    %extract Polls sensor connected to COM4 for time/acceleration data
    %   [T,A] = extract(N,port,offset) extracts time in seconds (T) and z-acc. 
    %   (m/s/s) given a # of samples, N, port identifier ('COM4'), and raw
    %   offset value
    %   ---
    %   Authour: Chris Williams | Last Updated: April 26, 2017
    %   McMaster University 2017

    GRAVITY = 9.80665;

    %Open serial communications
    imu = serial(PORT,'BaudRate',115200);
    fopen(imu);

    %Poll sensor
    y = zeros(numSamples,4);
    fprintf('Polling IMU on %s...\n', PORT)
    for i=1:numSamples
            %Debugging
            fprintf(fscanf(imu))
            fprintf(eval( [ '[', fscanf(imu), ']' ] ))

            y(i,:) = eval( [ '[', fscanf(imu), ']' ] );
    end

    %Scale data
    time = y(:,1);
    time = (time-time(1))/1000;

    accel = y(:,4);
    accel = (accel - offset)*GRAVITY;

    %Close serial communications
    fclose(instrfind);

    fprintf('Data capture complete\n')
    % beep;
end
