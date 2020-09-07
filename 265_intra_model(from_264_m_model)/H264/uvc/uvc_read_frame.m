function [y,u,v] = uvc_read_frame(fid,frame_number)
%
%UVC_READ_FRAME Read a frame from a UVC file.
%
%       [Y,U,V] = UVC_READ_FRAME(FID,FRAME_NUMBER) reads the frame specified
%       by FRAME_NUMBER from the UVC file specified by FID and returns the 
%       luminance component in Y and the two chrominance components in U and V.
%       If U and V are not specified the luminance component only is returned.
%
%       For example to read the 50th frame of the sequence "Mobile and 
%       Calendar" contained in the file /eeicl7/images/calendar_601:
%
%            fid = uvc_open('/eeicl7/images/calendar_601','r');
%            [y,u,v] = uvc_read_frame(fid,50);
%
%	If FRAME_NUMBER is not specified, the next frame is read
%
%	On exit, FID points at the beginning of the next frame to be read.
%
%       See also UVC_OPEN, UVC_WRITE_FRAME.
%

%#realonly

if nargin == 1
  frame_number = 0;
elseif nargin ~= 2
  error('Compulsory argument omitted.');
end

cur_pos = ftell(fid);

fseek(fid,16,-1);
video_offset = fread(fid,1,'uint');
width = fread(fid,1,'uint');
height = fread(fid,1,'uint');
max_frames = fread(fid,1,'uint');

fseek(fid,60,-1);
structure = fread(fid,1,'uint');

if structure < 1 | structure > 4
  error('This structure not supported by uvc_read_frame.');
end

if frame_number < 0 | frame_number > (max_frames-1)
  error('Frame number out of range.');
end

if structure == 1
  offset = 3*width*height*frame_number+video_offset;
  cw = width;
  ch = height;
elseif structure == 2
  offset = 2*width*height*frame_number+video_offset;
  cw = width/2;
  ch = height;
elseif structure == 3
  offset = 1.5*width*height*frame_number+video_offset;
  cw = width/2;
  ch = height/2;
elseif structure == 4
  offset = width*height*frame_number+video_offset;
  cw = 0;
  ch = 0;
end

if nargin == 1
  status = fseek(fid,cur_pos,-1);
else
  status = fseek(fid,offset,-1);
end

if status == -1
  error('Could not find correct position in file.');
end
  
y = fread(fid,[width,height],'uchar');
y = y';
  
if structure ~= 4
  u = fread(fid,[cw,ch],'uchar');
  u = u';
  v = fread(fid,[cw,ch],'uchar');
  v = v';
end


