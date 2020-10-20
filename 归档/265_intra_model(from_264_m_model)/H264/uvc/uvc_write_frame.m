function  frame_number = uvc_write_frame(fid,y,u,v)
%
%UVC_WRITE_FRAME Read a frame from a UVC file.
%
%       FRAME_NUMBER = UVC_READ_FRAME(FID,Y,U,V) writes the luminance and 
%       chrominance data specified by Y,U and V at the end of the UVC file 
%       specified by FID and returns the total number of frames written to 
%       the UVC file in FRAME_NUMBER. U and V are optional arguments and if 
%       they are not specified, only the luminance component is written to 
%       the UVC file. 
%
%       If the UVC file contains no previously written luminance and 
%       chrominance data, when the first frame is written to the UVC file, 
%       the header is updated to show the width, height and structure of 
%       the first frame. For each subsequent frame, the width, height and 
%       structure of the data is checked against the header of the UVC file
%       and if they are not identical, the frame is not written and an error
%       message is returned.
%
%       For example, to write the first two frames of output from a trial 
%       coder contained in the variables y1,u1,v1 and y2,u2,v2 to the UVC
%       file coder_out.uvc:
%
%            fid = uvc_open('cdr_out.uvc','w','Trial coder output.')
%            frame_number = uvc_write_frame(fid,y1,u1,v1);
%            frame_number = uvc_write_frame(fid,y2,u2,v2);
%
%       The value of the variable FRAME_NUMBER will now be
%
%            frame_number =
%
%                  2
%
%	On exit, FID points at the beginning of the next frame to be written.
%
%       See also UVC_OPEN, UVC_READ_FRAME.
%

%#realonly

if nargin < 2 | nargin > 4
  error('Compulsory argument omitted.');
end

fseek(fid,20,-1);
width = fread(fid,1,'uint');
height = fread(fid,1,'uint');
frame_number = fread(fid,1,'uint');

fseek(fid,60,-1);
structure = fread(fid,1,'uint');

[frm_height,frm_width] = size(y);

if nargin == 2
  frm_structure = 4;
elseif nargin == 4
  lum_size = frm_width*frm_height;
  [hc,wc] = size(u);
  chr_size = wc*hc;
    
  if lum_size == chr_size
    frm_structure = 1;
  elseif lum_size/2 == chr_size
    frm_structure = 2;
  elseif lum_size/4 == chr_size
    frm_structure = 3;
  else
    error('This structure not supported by uvc_write_frame.');
  end
end
  
if frame_number == 0

  frame_number = frame_number+1;
  
  fseek(fid,20,-1);
  fwrite(fid,frm_width,'uint');
  fwrite(fid,frm_height,'uint');
  fwrite(fid,frame_number,'uint');

  fseek(fid,60,-1);
  fwrite(fid,frm_structure,'uint');

  fseek(fid,0,1);

  y = y';
  fwrite(fid,y,'uchar');

  if frm_structure == 1 | frm_structure == 2 | frm_structure == 3
    u = u';
    fwrite(fid,u,'uchar');
    v = v';
    fwrite(fid,v,'uchar');
  end
else
  
  frame_number = frame_number+1;

  if frm_structure ~= structure
    error('Frame structure not compatible with file.')
  elseif frm_width ~= width
    error('Frame width not compatible with file.')
  elseif frm_height ~= height
    error('Frame height not compatible with file.')
  end
  
  fseek(fid,28,-1);
  fwrite(fid,frame_number,'uint');
  
  fseek(fid,0,1);

  y = y';
  fwrite(fid,y,'uchar');

  if frm_structure == 1 | frm_structure == 2 | frm_structure == 3
    u = u';
    fwrite(fid,u,'uchar');
    v = v';
    fwrite(fid,v,'uchar');
  end
  
end
