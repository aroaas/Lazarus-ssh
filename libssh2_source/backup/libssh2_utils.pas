unit libssh2_utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,StrUtils,DateUtils,blcksock,
  libssh2_sftp,libssh2_ssl,libssh2;


function libssh2_sftp_PutFile (const host,port,user,pass,RemoteFname,LocalFname:string;Hook:THookSocketStatus):Integer;
function libssh2_sftp_GetFile (const host,port,user,pass,RemoteFname,LocalFname:string;Hook:THookSocketStatus):Integer;
function libssh2_sftp_FileList(const host,port,user,pass:String;Path:String;Var FileList:TstringList;Hook:THookSocketStatus):Integer;
function libssh2_sftp_TestConnection (const host,port,user,pass:string;Hook:THookSocketStatus):Integer;
function libssh2_sftp_error_desc(e:integer):String;

{
function libssh2_sftp_last_error_string(sftp: PLIBSSH2_SFTP):String;
function libssh2_sftp_opensession(var SSLsock:TTCPBlockSocket;var Session:PLIBSSH2_SESSION;host,port,user,pass:String):Boolean;
Function libssh2_sftp_closeSession(Session:PLIBSSH2_SESSION):Boolean;
 }
implementation

function libssh2_error_desc(e:integer):String;
begin
  case e of
    1:Result:='SSH_DISCONNECT_HOST_NOT_ALLOWED_TO_CONNECT = 1';
    2:Result:='SSH_DISCONNECT_PROTOCOL_ERROR = 2';
    3:Result:='SSH_DISCONNECT_KEY_EXCHANGE_FAILED = 3';
    4:Result:='SSH_DISCONNECT_RESERVED = 4';
    5:Result:='SSH_DISCONNECT_MAC_ERROR = 5';
    6:Result:='SSH_DISCONNECT_COMPRESSION_ERROR = 6';
    7:Result:='SSH_DISCONNECT_SERVICE_NOT_AVAILABLE = 7';
    8:Result:='SSH_DISCONNECT_PROTOCOL_VERSION_NOT_SUPPORTED = 8';
    9:Result:='SSH_DISCONNECT_HOST_KEY_NOT_VERIFIABLE = 9';
   10:Result:='SSH_DISCONNECT_CONNECTION_LOST = 10';
   11:Result:='SSH_DISCONNECT_BY_APPLICATION = 11';
   12:Result:='SSH_DISCONNECT_TOO_MANY_CONNECTIONS = 12';
   13:Result:='SSH_DISCONNECT_AUTH_CANCELLED_BY_USER = 13';
   14:Result:='SSH_DISCONNECT_NO_MORE_AUTH_METHODS_AVAILABLE = 14';
   15:Result:='SSH_DISCONNECT_ILLEGAL_USER_NAME = 15';

{+// Error Codes (defined by libssh2)*/ }
    0:Result:='LIBSSH2_ERROR_NONE = 0';
   -1:Result:='LIBSSH2_ERROR_SOCKET_NONE = -1';
   -2:Result:='LIBSSH2_ERROR_BANNER_NONE = -2';
   -3:Result:='LIBSSH2_ERROR_BANNER_SEND = -3';
   -4:Result:='LIBSSH2_ERROR_INVALID_MAC = -4';
   -5:Result:='LIBSSH2_ERROR_KEX_FAILURE = -5';
   -6:Result:='LIBSSH2_ERROR_ALLOC = -6';
   -7:Result:='LIBSSH2_ERROR_SOCKET_SEND = -7';
   -8:Result:='LIBSSH2_ERROR_KEY_EXCHANGE_FAILURE = -8';
   -9:Result:='LIBSSH2_ERROR_TIMEOUT = -9';
  -10:Result:='LIBSSH2_ERROR_HOSTKEY_INIT = -10';
  -11:Result:='LIBSSH2_ERROR_HOSTKEY_SIGN = -11';
  -12:Result:='LIBSSH2_ERROR_DECRYPT = -12';
  -13:Result:='LIBSSH2_ERROR_SOCKET_DISCONNECT = -13';
  -14:Result:='LIBSSH2_ERROR_PROTO = -14';
  -15:Result:='LIBSSH2_ERROR_PASSWORD_EXPIRED = -15';
  -16:Result:='LIBSSH2_ERROR_FILE = -16';
  -17:Result:='LIBSSH2_ERROR_METHOD_NONE = -17';
  -18:Result:='LIBSSH2_ERROR_AUTHENTICATION_FAILED = -18';
//  LIBSSH2_ERROR_PUBLICKEY_UNRECOGNIZED:Result:='LIBSSH2_ERROR_AUTHENTICATION_FAILED';
  -19:Result:='LIBSSH2_ERROR_PUBLICKEY_UNVERIFIED = -19';
  -20:Result:='LIBSSH2_ERROR_CHANNEL_OUTOFORDER = -20';
  -21:Result:='LIBSSH2_ERROR_CHANNEL_FAILURE = -21';
  -22:Result:='LIBSSH2_ERROR_CHANNEL_REQUEST_DENIED = -22';
  -23:Result:='LIBSSH2_ERROR_CHANNEL_UNKNOWN = -23';
  -24:Result:='LIBSSH2_ERROR_CHANNEL_WINDOW_EXCEEDED = -24';
  -25:Result:='LIBSSH2_ERROR_CHANNEL_PACKET_EXCEEDED = -25';
  -26:Result:='LIBSSH2_ERROR_CHANNEL_CLOSED = -26';
  -27:Result:='LIBSSH2_ERROR_CHANNEL_EOF_SENT = -27';
  -28:Result:='LIBSSH2_ERROR_SCP_PROTOCOL = -28';
  -29:Result:='LIBSSH2_ERROR_ZLIB = -29';
  -30:Result:='LIBSSH2_ERROR_SOCKET_TIMEOUT = -30';
  -31:Result:='LIBSSH2_ERROR_SFTP_PROTOCOL = -31';
  -32:Result:='LIBSSH2_ERROR_REQUEST_DENIED = -32';
  -33:Result:='LIBSSH2_ERROR_METHOD_NOT_SUPPORTED = -33';
  -34:Result:='LIBSSH2_ERROR_INVAL = -34';
  -35:Result:='LIBSSH2_ERROR_INVALID_POLL_TYPE = -35';
  -36:Result:='LIBSSH2_ERROR_PUBLICKEY_PROTOCOL = -36';
  -37:Result:='LIBSSH2_ERROR_EAGAIN = -37';
  -38:Result:='LIBSSH2_ERROR_BUFFER_TOO_SMALL = -38';
  -39:Result:='LIBSSH2_ERROR_BAD_USE = -39';
  -40:Result:='LIBSSH2_ERROR_COMPRESS = -40';
  -41:Result:='LIBSSH2_ERROR_OUT_OF_BOUNDARY = -41';
  -42:Result:='LIBSSH2_ERROR_AGENT_PROTOCOL = -42';
  else Result:='Uknown error';
  end;
end;

function libssh2_sftp_error_desc(e:integer):String;
begin
  case e of
    0 : result:=' 0 = OK';
    1 : result:=' 1 = EOF';
    2 : result:=' 2 = NO SUCH FILE';
    3 : result:=' 3 = PERMISSION_DENIED';
    4 : result:=' 4 = FAILURE';
    5 : result:=' 5 = BAD_MESSAGE';
    6 : result:=' 6 = NO_CONNECTION';
    7 : result:=' 7 = CONNECTION_LOST';
    8 : result:=' 8 = OP_UNSUPPORTED';
    9 : result:=' 9 = INVALID_HANDLE';
   10 : result:='10 = NO_SUCH_PATH';
   11 : result:='11 = FILE_ALREADY_EXISTS';
   12 : result:='12 = WRITE_PROTECT';
   13 : result:='13 = NO_MEDIA';
   14 : result:='14 = NO_SPACE_ON_FILESYSTEM';
   15 : result:='15 = QUOTA_EXCEEDED';
   16 : result:='16 = UNKNOWN_PRINCIPAL';
   17 : result:='17 = LOCK_CONFLICT';
   18 : result:='18 = DIR_NOT_EMPTY';
   19 : result:='19 = NOT_A_DIRECTORY';
   20 : result:='20 = INVALID_FILENAME';
   21 : result:='21 = LINK_LOOP';
   else result:='libssh2 Error: '+IntToStr(e);
  end;
end;

function libssh2_sftp_last_error_string(sftp: PLIBSSH2_SFTP):String;
begin
  Result:= libssh2_sftp_error_desc(libssh2_sftp_last_error(sftp));
end;

{
LIBSSH2_SFTP_S_IFMT = 61440; {/* type of file mask*/}
const
  LIBSSH2_SFTP_S_IFIFO = 4096; {/* named pipe (fifo)*/}
const
  LIBSSH2_SFTP_S_IFCHR = 8192; {/* character special*/}
const
  LIBSSH2_SFTP_S_IFDIR = 16384; {/* directory*/}
const
  LIBSSH2_SFTP_S_IFBLK = 24576; {/* block special*/}
const
  LIBSSH2_SFTP_S_IFREG = 32768; {/* regular*/}
const
  LIBSSH2_SFTP_S_IFLNK = 40960; {/* symbolic link*/}
const
  LIBSSH2_SFTP_S_IFSOCK = 49152; {/* socket*/}
}
function libssh2_sftp_FtypeDesc(attrs:LIBSSH2_SFTP_ATTRIBUTES): string;
begin
    Result:='';
    if (LIBSSH2_SFTP_S_IFMT and attrs.permissions) and LIBSSH2_SFTP_S_IFDIR >0 then Result:='DIR';
    if (LIBSSH2_SFTP_S_IFMT and attrs.permissions) and LIBSSH2_SFTP_S_IFREG >0 then Result:='FILE';
end;


function libssh2_sftp_AttrsDesc(attrs:LIBSSH2_SFTP_ATTRIBUTES): string;

begin
  Result:='';
  // permissions
  // file type
  {
  mode:= info.st_mode;
  if STAT_IFLNK and mode=STAT_IFLNK then
    Result:=Result+'l'
  else
  if STAT_IFDIR and mode=STAT_IFDIR then
    Result:=Result+'d'
  else
  if STAT_IFBLK and mode=STAT_IFBLK then
    Result:=Result+'b'
  else
  if STAT_IFCHR and mode=STAT_IFCHR then
    Result:=Result+'c'
  else
    Result:=Result+'-';
  }

  // user permissions
  if (LIBSSH2_SFTP_S_IRWXU and attrs.permissions) and LIBSSH2_SFTP_S_IRUSR >0 then
    Result:=Result+'r'
  else
    Result:=Result+'-';
  if (LIBSSH2_SFTP_S_IRWXU and attrs.permissions) and LIBSSH2_SFTP_S_IWUSR >0 then
    Result:=Result+'w'
  else
    Result:=Result+'-';
  if (LIBSSH2_SFTP_S_IRWXU and attrs.permissions) and LIBSSH2_SFTP_S_IXUSR >0 then
    Result:=Result+'x'
  else
    Result:=Result+'-';
  Result:=Result+' ';

  // group permissions
  if (LIBSSH2_SFTP_S_IRWXG and attrs.permissions) and LIBSSH2_SFTP_S_IRGRP >0 then
    Result:=Result+'r'
  else
    Result:=Result+'-';
  if (LIBSSH2_SFTP_S_IRWXG and attrs.permissions) and LIBSSH2_SFTP_S_IWGRP >0 then
    Result:=Result+'w'
  else
    Result:=Result+'-';
  if (LIBSSH2_SFTP_S_IRWXG and attrs.permissions) and LIBSSH2_SFTP_S_IXGRP >0 then
    Result:=Result+'x'
  else
    Result:=Result+'-';
  Result:=Result+' ';

  // other permissions
  if (LIBSSH2_SFTP_S_IRWXO and attrs.permissions) and LIBSSH2_SFTP_S_IROTH >0 then
    Result:=Result+'r'
  else
    Result:=Result+'-';
  if (LIBSSH2_SFTP_S_IRWXO and attrs.permissions) and LIBSSH2_SFTP_S_IWOTH >0 then
    Result:=Result+'w'
  else
    Result:=Result+'-';
  if (LIBSSH2_SFTP_S_IRWXO and attrs.permissions) and LIBSSH2_SFTP_S_IXOTH >0 then
    Result:=Result+'x'
  else
    Result:=Result+'-';
{
  // user name
  //Result:=Result+' Owner: '+IntToStr(info.uid)+'.'+IntToStr(info.gid);

  // size
  Result:=Result+lrsSize+IntToStr(info.st_size);

  // date + time
  Result:=Result+lrsModified;
  try
    Result:=Result+FormatDateTime('DD/MM/YYYY hh:mm',
                           FileDateToDateTime(FileAgeUTF8(AFilename)));
  except
    Result:=Result+'?';
  end;}
end;


function libssh2_sftp_opensession(var SSLsock:TTCPBlockSocket;var Session:PLIBSSH2_SESSION;host,port,user,pass:String):Boolean;
var
  fingerprint:PAnsiChar;
  wl:string;
  i:integer;
begin
  // SSLsock must be created by caller if you want to assign Hook ??
  Result:=false;
{  if SSLsock=nil
  then begin
    //wln('SSLsock = nil...');
    Exit;
  end;}
  SSLsock.DoStatus(HR_Wln,'LibName      : ' + SSLsock.SSL.LibName);
  SSLsock.DoStatus(HR_Wln,'LibVersion   : ' + SSLsock.SSL.LibVersion);
  SSLsock.Connect(host,port);  // Create socket automatic if not already created
  if SSLsock.LastError=0 then
  begin
    session := libssh2_session_init();
    if libssh2_session_startup(session, SSLsock.Socket)<>0 then
    begin
      SSLsock.DoStatus(HR_Msg,SSLsock.LastErrorDesc);
      //('Cannot establishing SSH session');
      Exit;
    end;
    SSLsock.DoStatus(HR_Msg,'SHH session established');
    fingerprint := libssh2_hostkey_hash(session, LIBSSH2_HOSTKEY_HASH_SHA1);
    i:=0;
    while fingerprint[i]<>#0 do
      begin
      wl:=wl+(inttohex(ord(fingerprint[i]),2)+':');
      i:=i+1;
      end;
    SSLsock.DoStatus(HR_Msg,'Host fingeprint: '+ wl);
    if libssh2_userauth_password(session, pchar(user), pchar(pass))<>0 then
    begin
      SSLsock.DoStatus(HR_Msg,'Authentication by password failed');
      libssh2_session_disconnect(session,'Thank you for using sshtest');
      libssh2_session_free(session);
      Exit;
    end;
    SSLsock.DoStatus(HR_Msg,'Authentication succeeded');
    Result:=true;
  end
  else
    SSLsock.DoStatus(HR_Msg,'Unknown host...');
end;

Function libssh2_sftp_closeSession(Session:PLIBSSH2_SESSION):Boolean;
begin
  Result:=true;
  if Session = nil then Exit;
  //wln('Session disconnect...');
  libssh2_session_disconnect(session,'Thank you for using sshtest');
  libssh2_session_free(session);
end;


function libssh2_sftp_FileList(const host,port,user,pass:String;Path:String;Var FileList:TstringList;Hook:THookSocketStatus):Integer;
const
  buffer_size=1024;
var
  SSLsock:TTCPBlockSocket;
  Session:PLIBSSH2_SESSION;
  sftp:PLIBSSH2_SFTP;
  sftp_filehandle: PLIBSSH2_SFTP_HANDLE;
 // pattrs: PLIBSSH2_SFTP_ATTRIBUTES;
  attrs: LIBSSH2_SFTP_ATTRIBUTES;
  pattrs:^LIBSSH2_SFTP_ATTRIBUTES;
  i:integer;
  DT_atime,DT_mtime:TDateTime;
  longentry,buffer:PChar;
begin
  SSLsock := TTCPBlockSocket.CreateWithSSL(TSSLLibSSH2);
  //SSLsock := TTCPBlockSocket.CreateWithSSL(TSSLOpenSSL);
  SSLsock.OnStatus:=Hook;
  if libssh2_sftp_opensession(SSLsock,session,host,port,user,pass)
  then begin
    sftp:=libssh2_sftp_init(session);
    FileList.Clear;
    Result:=0;
    new(pattrs);
    buffer:=StrAlloc(buffer_size);
    longentry:=StrAlloc(buffer_size);
    path:='./'+path;
    FileList.Add('');
    FileList.Add('Directory listing for: '+path);
    FileList.Add('');

    sftp_filehandle:=libssh2_sftp_opendir(sftp,pchar(path));

    if libssh2_sftp_last_error(sftp)=0
    then begin
      {$IFDEF WINDOWS}
      FileList.Add(PadRight('Name',40)+
          PadLeft('Flags',10)+
          PadLeft('FileSize',10)+
          PadLeft('User Id',10)+
          PadLeft('Group Id',10)+
          PadLeft('Permissions',15)+
          PadLeft('atime (Create)',25)+
          PadLeft('Last Modified',25)
          );
      {$ELSE}
      FileList.Add(PadRight('Attributes',10)+
                   PadLeft('X',5)+
                   PadLeft('OWN',9)+
                   PadLeft('GRP',9)+
                   PadLeft('Size',9)+
                   PadRight(' Date',13)+
                   PadRight(' Filename',25)
                   );
      {$ENDIF}
      FileList.Add('');

      while libssh2_sftp_readdir_ex(sftp_filehandle,buffer,buffer_size,longentry,buffer_size,pattrs) > 0 do
      begin
        inc(result);
        {$IFDEF WINDOWS}
        attrs:=pattrs^;
        DT_atime:=UnixToDateTime(attrs.atime);
        DT_mtime:=UnixToDateTime(attrs.mtime);
        if (attrs.flags and LIBSSH2_SFTP_ATTR_PERMISSIONS) > 0 then;
        FileList.Add(PadRight(strpas(buffer),40)+
            PadLeft(libssh2_sftp_FtypeDesc(attrs),10)+
            PadLeft(IntToStr(attrs.filesize),10)+
            PadLeft(IntToStr(attrs.uid),10)+
            PadLeft(IntToStr(attrs.gid),10)+
            PadLeft(libssh2_sftp_AttrsDesc(attrs),15)+
            PadLeft(FormatDateTime('yyyy-mm-dd hh:mm:ss',DT_atime),25)+
            PadLeft(FormatDateTime('yyyy-mm-dd hh:mm:ss',DT_mtime),25)
            );
        {$ELSE}
        FileList.Add(strpas(longentry));
        {$ENDIF}
      end; // while libssh_sftp_readdir > 0
      libssh2_sftp_closedir(sftp_filehandle);
      FileList.Add('');
      FileList.Add('closedir: '+ libssh2_sftp_last_error_string(sftp));
    end
    else
      FileList.Add(libssh2_sftp_last_error_string(sftp));
    StrDispose(buffer);
    StrDispose(longentry);
    Dispose(pattrs);
    libssh2_sftp_shutdown(sftp);
  end;
  if libssh2_sftp_closesession(session) then;
  SSLsock.Free;
end;

{ Early version
function libssh2_sftp_FileList(Session:PLIBSSH2_SESSION;path:String;Var FileList:TstringList):Integer;
const
  buffer_size=255;
var
  sftp:PLIBSSH2_SFTP;
  sftp_filehandle: PLIBSSH2_SFTP_HANDLE;
  pattrs: PLIBSSH2_SFTP_ATTRIBUTES;
  attrs: LIBSSH2_SFTP_ATTRIBUTES;
  i:integer;
  DT_atime,DT_mtime:TDateTime;
  buffer:PChar;
begin
  sftp:=libssh2_sftp_init(session);
  FileList.Clear;
  Result:=0;
  new(pattrs);
  buffer:=StrAlloc(buffer_size);
  path:='./'+path;
  FileList.Add('');
  FileList.Add('Directory listing for: '+path);
  FileList.Add('');

  sftp_filehandle:=libssh2_sftp_opendir(sftp,pchar(path));

  if libssh2_sftp_last_error(sftp)=0
  then begin

    FileList.Add(PadRight('Name',40)+
        PadLeft('Flags',10)+
        PadLeft('FileSize',10)+
        PadLeft('User Id',10)+
        PadLeft('Group Id',10)+
        PadLeft('Permissions',15)+
        PadLeft('atime (Create)',25)+
        PadLeft('Last Modified',25)
        );

    i:=1;
    while i > 0 do
    begin
      i:=libssh2_sftp_readdir(sftp_filehandle,buffer,buffer_size,pattrs);
      if i > 0 then
      begin
        //if libssh2_sftp_fstat(sftp_filehandle,attrs) = -1 then ;
        attrs:=pattrs^;;
        inc(result);
        DT_atime:=UnixToDateTime(attrs.atime);
        DT_mtime:=UnixToDateTime(attrs.mtime);
        if (pattrs^.flags and LIBSSH2_SFTP_ATTR_PERMISSIONS) > 0 then;
        FileList.Add(PadRight(strpas(buffer),40)+
            PadLeft(libssh2_sftp_FtypeDesc(attrs),10)+
            PadLeft(IntToStr(attrs.filesize),10)+
            PadLeft(IntToStr(attrs.uid),10)+
            PadLeft(IntToStr(attrs.gid),10)+
            PadLeft(libssh2_sftp_AttrsDesc(attrs),15)+
            PadLeft(FormatDateTime('yyyy-mm-dd hh:mm:ss',DT_atime),25)+
            PadLeft(FormatDateTime('yyyy-mm-dd hh:mm:ss',DT_mtime),25)
            );
        FileList.Add(PadRight(' ',10)+
            PadLeft('Flags: '+IntToBin(attrs.flags,4),12)+
            PadLeft('Perm : '+IntToBin(attrs.permissions,20),30)+
            PadLeft('Value: '+IntToStr(attrs.permissions),20)+
            PadLeft('atime: '+IntToStr(attrs.atime),20)+
            PadLeft('mtime: '+IntToStr(attrs.mtime),20)
            );
        FileList.Add(PadRight(' ',10)+
            PadLeft(' ',12)+
            PadLeft('IFMT : '+IntToBin(LIBSSH2_SFTP_S_IFMT,20),30)
            );
        FileList.Add(PadRight(' ',10)+
            PadLeft(' ',12)+
            PadLeft('And  : '+IntToBin((LIBSSH2_SFTP_S_IFMT and attrs.permissions),20),30)
            );
        FileList.Add(PadRight(' ',10)+
            PadLeft(' ',12)+
            PadLeft('IFDIR: '+IntToBin(LIBSSH2_SFTP_S_IFDIR,20),30)
            );
        FileList.Add(PadRight(' ',10)+
            PadLeft(' ',12)+
            PadLeft('IFREG: '+IntToBin(LIBSSH2_SFTP_S_IFREG,20),30)
            );
      end;
    end;
    libssh2_sftp_closedir(sftp_filehandle);
    FileList.Add('');
    FileList.Add('closedir: '+ libssh2_sftp_last_error_string(sftp));
  end
  else
    FileList.Add(libssh2_sftp_last_error_string(sftp));
  StrDispose(buffer);
  Dispose(pattrs);
  libssh2_sftp_shutdown(sftp);
end;
}


function libssh2_sftp_GetFile(const host,port,user,pass,RemoteFname,LocalFname:string;Hook:THookSocketStatus): Integer;
Const
  BufferSize=10240;
var
  TotalBytes:int64=0;
  FilePath,HomePath,FilePathName:string;
  SSLsock:TTCPBlockSocket;
  Session:PLIBSSH2_SESSION;
  sftp:PLIBSSH2_SFTP;
  sftp_filehandle: PLIBSSH2_SFTP_HANDLE;
  Buffer:TBytes;
  SendStream: TStream;
  Size_t: int64;

begin
  Result:=LIBSSH2_FX_OK;
  SSLsock := TTCPBlockSocket.CreateWithSSL(TSSLLibSSH2);
  //SSLsock := TTCPBlockSocket.CreateWithSSL(TSSLOpenSSL);
  SSLsock.OnStatus:=Hook; //@Form1.HookSocketStatus;
  if libssh2_sftp_OpenSession(SSLsock,Session,host,port,user,pass)
  then begin
    sftp:=Libssh2_sftp_init(session);
    SSLsock.DoStatus(HR_Msg,'sftp_init: '+ libssh2_sftp_last_error_string(sftp));
    HomePath:='./';
    FilePath:=ExtractFilePath(HomePath+RemoteFname);
    FilePathName:=HomePath+RemoteFname;
    SSLsock.DoStatus(HR_Msg,'HomePath: '+homepath);
    SSLsock.DoStatus(HR_Msg,'FilePath: '+FilePath);
 //   If SSL_DirectoryExists(FilePath);
    sftp_filehandle:=libssh2_sftp_open(sftp,pchar(FilePathName),LIBSSH2_FXF_READ,0);
    if libssh2_sftp_last_error(sftp)=0
    then begin
      SSLsock.DoStatus(HR_Msg,'sftp_open ok '+FilePathName);
      SSLsock.DoStatus(HR_Msg,'FilePath of LocalFname: '+ExtractFilePath(LocalFname));
      if (ExtractFilePath(LocalFname) = '') or DirectoryExists(ExtractFilePath(LocalFname))
      then begin
        SSLsock.DoStatus(HR_Msg,'Local Directory ok -> saving to: '+LocalFname);
        SendStream := TFileStream.Create(LocalFname,fmCreate);
        SendStream.Position:=0;
        SetLength(Buffer,BufferSize);
        SSLsock.DoStatus(HR_Msg,'Starting read loop with BufferSize: '+IntToStr(BufferSize));
        size_t:=1;
        While (size_t>0) do
        begin
          size_t:=libssh2_sftp_read(sftp_filehandle,Pointer(Buffer),BufferSize);
          if (size_t > 0)
          then begin
//            SSLsock.DoStatus(HR_Msg,'Last read size_t: '+inttostr(size_t));
            SendStream.Write(Pointer(Buffer)^,size_t);
            TotalBytes:=TotalBytes+size_t;
          end
          else SSLsock.DoStatus(HR_Msg,'Exit Loop with size_t: '+IntToStr(size_t));
        end;
        SSLsock.DoStatus(HR_Msg,'sftp_read status : '+libssh2_sftp_last_error_string(sftp));
        SSLsock.DoStatus(HR_Msg,'Total bytes read : '+IntToStr(TotalBytes));
        SSLsock.DoStatus(HR_Msg,'Total bytes write: '+IntToStr(SendStream.Position));
        SSLsock.DoStatus(HR_Msg,'LocalFile write done');
        Result:=(TotalBytes-SendStream.Position);
        SendStream.Free;
        SetLength(Buffer,0);
      end
      else begin
        SSLsock.DoStatus(HR_Msg,'Error Local Directory missing');
        Result:=LIBSSH2_FX_NO_SUCH_PATH;
      end;
      libssh2_sftp_close(sftp_filehandle);
    end
    else begin
      SSLsock.DoStatus(HR_Msg,'Error opening remote file: '+FilePathName);
      Result:=LIBSSH2_FX_NO_SUCH_FILE;
    end;
    SSLsock.DoStatus(HR_Msg,'sftp_shutdown next...');
    libssh2_sftp_shutdown(sftp);
    SSLsock.DoStatus(HR_Msg,'CloseSSLsession next...');
    libssh2_sftp_CloseSession(Session);
  end
  else begin
    SSLsock.DoStatus(HR_Msg,'Error opening session: '+libssh2_sftp_last_error_string(sftp));
    Result:=LIBSSH2_FX_NO_CONNECTION;
  end;

  SSLsock.DoStatus(HR_Msg,'SSLsock.Free next...');
  SSLsock.Free;
end;


function libssh2_sftp_PutFile(const host,port,user,pass,RemoteFname,LocalFname:string;Hook:THookSocketStatus): Integer;
const
  BufferSize=10240;
var
  TotalBytes:int64=0;
  BytesInBuffer:Integer;
  LoopCount:Integer=0;
  target:Pchar;
  FilePath,HomePath,FilePathName:string;
  SSLsock:TTCPBlockSocket;
  Session:PLIBSSH2_SESSION;
  sftp:PLIBSSH2_SFTP;
  sftp_filehandle: PLIBSSH2_SFTP_HANDLE;
  Buffer:TBytes;
  SendStream: TStream;
  StorSize,Size_t: int64;
  s:String;
//  P:PAnsiChar;

begin
  Result:=LIBSSH2_FX_OK;
  Target:=StrAlloc(255);
  Session:=nil;
  sftp:=nil;
  sftp_filehandle:=nil;
  SSLsock := TTCPBlockSocket.CreateWithSSL(TSSLLibSSH2);
  //SSLsock := TTCPBlockSocket.CreateWithSSL(TSSLOpenSSL);
  SSLsock.OnStatus:=Hook; //@Form1.HookSocketStatus;
  if libssh2_sftp_OpenSession(SSLsock,Session,host,port,user,pass)
  then begin
    sftp:=Libssh2_sftp_init(session);
    SSLsock.DoStatus(HR_Msg,'sftp_init: '+ libssh2_sftp_last_error_string(sftp));
    HomePath:='./';
    FilePath:=ExtractFilePath(HomePath+RemoteFname);
    FilePathName:=HomePath+RemoteFname;
    SSLsock.DoStatus(HR_Msg,'HomePath: '+homepath);
    SSLsock.DoStatus(HR_Msg,'FilePath: '+FilePath);
 //   If SSL_DirectoryExists(FilePath);
    sftp_filehandle:=libssh2_sftp_opendir(sftp,pchar(FilePath));
    if libssh2_sftp_last_error(sftp)=0
    then begin
      libssh2_sftp_closedir(sftp_filehandle);
      SSLsock.DoStatus(HR_Msg,'Remote Directory ok. Will try to save to : '+HomePath+RemoteFname);
      If FileExists(LocalFname)
      then begin
        SSLsock.DoStatus(HR_Msg,'Local file ok: '+LocalFname);
        sftp_filehandle:=libssh2_sftp_open(sftp,pchar(FilePathName),LIBSSH2_FXF_WRITE+LIBSSH2_FXF_CREAT+LIBSSH2_FXF_TRUNC,
                                                                    LIBSSH2_SFTP_S_IRUSR+LIBSSH2_SFTP_S_IWUSR+
                                                                    LIBSSH2_SFTP_S_IRGRP+LIBSSH2_SFTP_S_IROTH);
        if libssh2_sftp_last_error(sftp)=0
        then begin
          SSLsock.DoStatus(HR_Msg,'sftp_filehandle for creating file ok');
          SendStream := TFileStream.Create(LocalFname,fmOpenRead or fmShareDenyWrite);
          SSLsock.DoStatus(HR_Msg,'Size of LocalFile: '+IntToStr(SendStream.Size));
          SetLength(Buffer,BufferSize);
          StorSize := SendStream.Size - SendStream.Position;
          Size_t:=1;
          while (StorSize >0) and(Size_t>0) do
          begin
            BytesInBuffer:=BufferSize;
            if BytesInBuffer>StorSize then BytesInBuffer:=StorSize;
            SendStream.ReadBuffer(Pointer(buffer)^,BytesInBuffer);
            size_t:=libssh2_sftp_write(sftp_filehandle,Pointer(Buffer),BytesInBuffer);
            StorSize := SendStream.Size - SendStream.Position;
            Inc(TotalBytes,Size_t);
            Inc(LoopCount);
//            SSLsock.DoStatus(HR_Msg,'BytesInBuffer: '+IntToStr(BytesInBuffer));
//            SSLsock.DoStatus(HR_Msg,'Bytes written: '+IntToStr(Size_t));
//            SSLsock.DoStatus(HR_Msg,'BytesLeft: '+IntToStr(StorSize));
//            SSLsock.DoStatus(HR_Msg,'Position : '+IntToStr(SendStream.Position));
          end;
          SSLsock.DoStatus(HR_Msg,'sftp_write status : '+libssh2_sftp_last_error_string(sftp));
          SSLsock.DoStatus(HR_Msg,'TotalBytes written: '+IntToStr(TotalBytes)+' LoopCount: '+IntToStr(LoopCount));
          libssh2_sftp_close(sftp_filehandle);
          SSLsock.DoStatus(HR_Msg,'Closing remote file: '+libssh2_sftp_last_error_string(sftp));
          Result:=(SendStream.Size-TotalBytes);
          SetLength(Buffer,0);
          SendStream.Free;
        end
        else begin
          SSLsock.DoStatus(HR_Msg,'Error Creating sftp_filehandle for uploading: '+libssh2_sftp_last_error_string(sftp));
          Result:=LIBSSH2_FX_INVALID_HANDLE;
        end;
      end
      else begin
        SSLsock.DoStatus(HR_Msg,'LocalFile DONT Exist');
        Result:=LIBSSH2_FX_NO_SUCH_FILE;
      end;
    end
    else begin
      SSLsock.DoStatus(HR_Msg,'Remote dir error '+libssh2_sftp_last_error_string(sftp));
      Result:=LIBSSH2_FX_NO_SUCH_PATH;
    end;

    SSLsock.DoStatus(HR_Msg,'sftp_shutdown next...');
    libssh2_sftp_shutdown(sftp);
    SSLsock.DoStatus(HR_Msg,'CloseSSLsession next...');
    libssh2_sftp_CloseSession(Session);
  end
  else begin
    SSLsock.DoStatus(HR_Msg,'Error opening session: '+libssh2_sftp_last_error_string(sftp));
    Result:=LIBSSH2_FX_NO_CONNECTION;
  end;
  SSLsock.DoStatus(HR_Msg,'Disposing attrs next...');
  SSLsock.DoStatus(HR_Msg,'Disposing target next...');
  StrDispose(target);
  SSLsock.DoStatus(HR_Msg,'SSLsock.Free next...');
  SSLsock.Free;
end;

function libssh2_sftp_TestConnection(const host,port,user,pass:string;Hook:THookSocketStatus): Integer;
var
  SSLsock:TTCPBlockSocket;
  Session:PLIBSSH2_SESSION;

begin
  Result:=LIBSSH2_FX_OK;
  SSLsock := TTCPBlockSocket.CreateWithSSL(TSSLLibSSH2);
  //SSLsock := TTCPBlockSocket.CreateWithSSL(TSSLOpenSSL);
  SSLsock.OnStatus:=Hook; //@Form1.HookSocketStatus;
  if libssh2_sftp_OpenSession(SSLsock,Session,host,port,user,pass)
  then begin
    SSLsock.DoStatus(HR_Msg,'CloseSSLsession next...');
    libssh2_sftp_CloseSession(Session);
  end
  else begin
    SSLsock.DoStatus(HR_Msg,'Error opening session: '+libssh2_sftp_last_error_string(Session));
    Result:=LIBSSH2_FX_NO_CONNECTION;
  end;
  SSLsock.DoStatus(HR_Msg,'SSLsock.Free next...');
  SSLsock.Free;
end;



end.

