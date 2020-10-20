function max_frames = uvc_nframes(fid)
%
%UVC_NFRAMES	Read the number of frames from UVC file FID
%
%       See also UVC_OPEN, UVC_WRITE_FRAME.
%

%#realonly

if nargin ~= 1
  error('Compulsory argument omitted.');
end

cur_pos = ftell(fid);

%
% first check this really is a UVC file
%
fseek(fid,0,-1);
uvcg = fread(fid,1,'uint32');
if uvcg ~= 1431716679
  fclose(fid);
  error('Not a UVC file.');
end

%
% read interesting info in header contents
%
fseek(fid,16,-1);
video_offset = fread(fid,1,'uint');
width = fread(fid,1,'uint');
height = fread(fid,1,'uint');
max_frames = fread(fid,1,'uint');

fseek(fid,60,-1);
structure = fread(fid,1,'uint');

if structure < 1 | structure > 5
  error('This structure not supported by uvc_read_frame.');
end

%
% put file pointer back where it started
%
fseek(fid,cur_pos,-1);
