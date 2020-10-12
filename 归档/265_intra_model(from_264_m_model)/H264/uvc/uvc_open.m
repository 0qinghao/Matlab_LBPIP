function fid = uvc_open(filename,mode,comment);
%
%UVC_OPEN Open UVC file.
%
%       FID = UVC_OPEN(FILENAME,MODE,COMMENT) opens the UVC file 
%       specified by the string argument FILENAME. MODE may be one 
%       of the strings:
%
%            'r'     read
%            'w'     write (create if necessary)
%
%       COMMENT is an optional string argument which can be used to add
%       a comment to a new UVC file opened for writing.
%
%       If the UVC file is to be opened for writing, a default header is
%       written to the file with the number of frames et to zero.
%
%       If the UVC file is to be opened for reading, the first four bytes
%       of the file are checked for the UVC file identifier.
%
%       If the open is successful, FID gets a scalar MATLAB integer, the
%       file identifier, to be used as the first argument to other FileIO
%       routines. If the open was not successful, -1 is returned for FID.
%
%       For example, to open the file containing the standard sequence 
%       "Mobile and Calendar", with the filename /eeicl7/images/calendar_601
%       for reading:
%
%            fid = uvc_open('/eeicl7/images/calendar_601','r');
%
%       To open the new UVC file cdr_out.uvc for writing the output of a
%       trial coding process:
%
%            fid = uvc_open('cdr_out.uvc','w','Trial coder output.')
%
%	On exit, FID points at the beginning of the next frame.
%
%       See also UVC_READ_FRAME, UVC_WRITE_FRAME.
%

%#realonly

if nargin ~= 2 & nargin ~= 3
  error('Compulsory argument omitted.');
end

if strcmp(mode,'w') == 0 & strcmp(mode,'r') == 0
  error('Unacceptable MODE for uvc_open.');
end

if strcmp(mode,'w')
  
  if nargin < 3
    comment = '';
  end  

  comm_size = size(comment);
  if isstr(comment) == 0
    error('COMMENT must be a of type character string.');
  end

  comm_length = length(comment);

  fid = fopen(filename,'w+','b');
  if fid == -1
    error('File could not be opened for writing.')
  end
  
  
  fseek(fid,0,-1);

  fwrite(fid,1431716679,'uint');
  fwrite(fid,2,'uint');
  fwrite(fid,0,'uint');
  fwrite(fid,64,'uint');
  fwrite(fid,64+comm_length,'uint');
  fwrite(fid,720,'uint');
  fwrite(fid,576,'uint');
  fwrite(fid,0,'uint');
  fwrite(fid,25.0,'float32');
  fwrite(fid,2,'uint');
  fwrite(fid,0,'uint');
  fwrite(fid,1,'uint');
  fwrite(fid,1,'uint');
  fwrite(fid,8,'uint');
  fwrite(fid,1,'uint');
  fwrite(fid,2,'uint');

  fwrite(fid,comment,'char');
  fseek(fid,0,1);
  
elseif strcmp(mode,'r') == 1
  
  fid = fopen(filename,'r','b');
  if fid == -1
    error('File could not be opened for reading.')
  end
  
  fseek(fid,0,-1);
  uvcg = fread(fid,1,'uint32');
  if uvcg ~= 1431716679
    fclose(fid);
    error('Not a UVC file.');
  end

  % move the file pointer to the beginning of the video data
  fseek(fid,16,-1);
  video_offset = fread(fid,1,'uint');
  fseek(fid,video_offset,-1);
end
    
