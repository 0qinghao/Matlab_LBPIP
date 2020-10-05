% Set the video information
videoSequence = 'F:\HEVC_test_sequence\ClassC\BasketballDrill_832x480_50.yuv';
width = 832;
height = 480;
nFrame = 1;

% Read the video sequence
[Y, U, V] = yuvRead(videoSequence, width, height, nFrame);

Y = Y(1:448, 1:832);
