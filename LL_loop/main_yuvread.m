% Set the video information
videoSequence = 'F:\HEVC_test_sequence\ClassF\ChinaSpeed_1024x768_30.yuv';
width = 1024;
height = 768;
nFrame = 1;

% Read the video sequence
[Y, U, V] = yuvRead(videoSequence, width, height, nFrame);
