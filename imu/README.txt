Razor M0 IMU Setup:
1. Turn on device, flash hardware w/default firmware included in the folder (/imu)
2. Open a serial monitor and send the appropiate characters (see config.h) to disable:
	a. the magnometer ('m')
	b. the gyroscope ('g')
	c. quaternion(?) values ('q')
so that the remaining output is 'time ax ay az' @ 100 Hz
3. Terminate communication with serial monitor
