unit Crypto;

interface

uses
  Classes, SysUtils;

type
  ECryptException = class(Exception)
  end;

  TCrypt = class(TObject)
  private
    FKeyText: string;
  protected
    function InternalDecrypt(const InStream: TStream; const KeyString: string):
        TStream; virtual; abstract;
    function InternalEncrypt(const InStream: TStream; const KeyString: string):
        TStream; virtual; abstract;
  public
    function DecryptStream(const InStream: TStream): TStream;
    function EncryptStream(const InStream: TStream): TStream;
    property KeyText: string read FKeyText write FKeyText;
  end;

  TStreamCipher = class(TCrypt)
  protected
    procedure InitialiseKeyStream(const KeyString: string); virtual; abstract;
    function InternalDecrypt(const InStream: TStream; const KeyString: string):
        TStream; override;
    function InternalEncrypt(const InStream: TStream; const KeyString: string):
        TStream; override;
    function KeyStream: Byte; virtual; abstract;
    function StreamEnDecrypt(const InStream: TStream; const KeyString: string):
        TStream;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TCryptUtil = class(TObject)
  private
    FCrypt: TCrypt;
    function GetKeyText: string;
    procedure SetKeyText(const Value: string);
  protected
    function Armour(const InStream: TStream): TStream;
    function ArmourChar(const Number: Integer): Char;
    function ArmourNumber(const Character: Char): Integer;
    procedure CheckFile(const FileName: string);
    function Dearmour(const InStream: TStream): TStream;
  public
    destructor Destroy; override;
    procedure DecryptFile(const FileName: string);
    function DecryptString(const InStr: string): string;
    function DecryptStrings(const InStrings: TStrings): TStrings;
    procedure EncryptFile(const FileName: string);
    function EncryptString(const InStr: string): string;
    function EncryptStrings(const InStrings: TStrings): TStrings;
    property Crypt: TCrypt read FCrypt write FCrypt;
    property KeyText: string read GetKeyText write SetKeyText;
  end;

  TCryptUtilSingleton = class(TCryptUtil)
  protected
    constructor CreateInstance;
    class function AccessInstance(Request: Integer): TCryptUtilSingleton;
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance: TCryptUtilSingleton;
    class procedure ReleaseInstance;
  end;


implementation

const
  BASE_64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + //1..26
            'abcdefghijklmnopqrstuvwxyz' + //27..52
            '0123456789' +                 //53..62
            '+/' ;                         //63,64

{
************************************ TCrypt ************************************
}
function TCrypt.DecryptStream(const InStream: TStream): TStream;
begin
  Result := InternalDecrypt(InStream, FKeyText);
end;

function TCrypt.EncryptStream(const InStream: TStream): TStream;
begin
  Result := InternalEncrypt(InStream, FKeyText);
end;

{
******************************** TStreamCipher *********************************
}
constructor TStreamCipher.Create;
begin
  inherited Create;
end;

destructor TStreamCipher.Destroy;
begin
  inherited Destroy;
end;

function TStreamCipher.InternalDecrypt(const InStream: TStream; const
    KeyString: string): TStream;
begin
  Result := StreamEnDecrypt(InStream, KeyString);
end;

function TStreamCipher.InternalEncrypt(const InStream: TStream; const
    KeyString: string): TStream;
begin
  Result := StreamEnDecrypt(InStream, KeyString);
end;

function TStreamCipher.StreamEnDecrypt(const InStream: TStream; const
    KeyString: string): TStream;
//1 XOR's the input stream with the key stream
var
  OutStream: TMemoryStream;
  Temp: Byte;
begin
  OutStream := TMemoryStream.Create;

  InitialiseKeyStream(KeyString);

  InStream.Position := 0;
  while (InStream.Position <> InStream.Size) do
  begin
    InStream.Read(Temp, SizeOf(Byte));
    Temp := Temp xor KeyStream;
    OutStream.Write(Temp, SizeOf(Byte));
  end;

  Result := OutStream;
end;

{
********************************** TCryptUtil **********************************
}
destructor TCryptUtil.Destroy;
begin
  if FCrypt <> nil then
    FreeAndNil(FCrypt);

  inherited Destroy;
end;

function TCryptUtil.Armour(const InStream: TStream): TStream;
//1 Convers a bit stream into a stream of Base 64 ASCII Armoured characters
var
  TempStream: TMemoryStream;
  Byte1, Byte2, Byte3: Byte;
  Char1, Char2, Char3, Char4: Char;
  Temp: Integer;
begin
  TempStream := TMemoryStream.Create;

  InStream.Position := 0;
  while (InStream.Position <> InStream.Size) do
  begin
    //These are default padding characters
    Char3 := '=';
    Char4 := '=';

    InStream.Read(Byte1, SizeOf(Byte));
    Char1 := ArmourChar((Byte1 and $FC) shr 2);
    Temp := InStream.Read(Byte2, SizeOf(Byte));
    if (Temp = 0) then
    begin
      Char2 := ArmourChar((Byte1 and $03) shl 4);
    end
    else
    begin
      Char2 := ArmourChar(((Byte1 and $03) shl 4) + ((Byte2 and $F0) shr 4));

      Temp := InStream.Read(Byte3, SizeOf(Byte));
      if (Temp = 0) then
      begin
        Char3 := ArmourChar((Byte2 and $0F) shl 4);
      end
      else
      begin
        Char3 := ArmourChar(((Byte2 and $0F) shl 2) + ((Byte3 and $C0) shr 6));
        Char4 := ArmourChar(Byte3 and $3F);
      end;
    end;

    TempStream.Write(Char1, SizeOf(Char));
    TempStream.Write(Char2, SizeOf(Char));
    TempStream.Write(Char3, SizeOf(Char));
    TempStream.Write(Char4, SizeOf(Char));
  end;

  Result := TempStream;
end;

function TCryptUtil.ArmourChar(const Number: Integer): Char;
begin
  Result := BASE_64[Number + 1];
end;

function TCryptUtil.ArmourNumber(const Character: Char): Integer;
begin
  Result := Pos(Character, BASE_64) - 1;
end;

procedure TCryptUtil.CheckFile(const FileName: string);
begin
  if (Trim(FileName) = '') then
    raise ECryptException.Create('File name is blank');
  if not FileExists(FileName) then
    raise ECryptException.Create('File does not exist');
end;

function TCryptUtil.Dearmour(const InStream: TStream): TStream;
//1 Converts a Base 64 ASCII Armoured character stream into a binary one
var
  TempStream: TMemoryStream;
  Char1, Char2, Char3, Char4: Char;
  Byte1, Byte2, Byte3: Byte;
begin
  TempStream := TMemoryStream.Create;

  InStream.Position := 0;
  while (InStream.Position <> InStream.Size) do
  begin
    InStream.Read(Char1, SizeOf(Char));
    InStream.Read(Char2, SizeOf(Char));
    InStream.Read(Char3, SizeOf(Char));
    InStream.Read(Char4, SizeOf(Char));

    Byte1 := ArmourNumber(Char1) shl 2 +
             ArmourNumber(Char2) shr 4;
    TempStream.Write(Byte1, SizeOf(Byte));

    if (Char3 <> '=') then
    begin
      Byte2 := (ArmourNumber(Char2) and $0F) shl 4 +
               (ArmourNumber(Char3) and $3C) shr 2;
      TempStream.Write(Byte2, SizeOf(Byte));

      if (Char4 <> '=') then
      begin
        Byte3 := (ArmourNumber(Char3) and $03) shl 6 +
                  ArmourNumber(Char4);
        TempStream.Write(Byte3, SizeOf(Byte));
      end;
    end;
  end;

  Result := TempStream;
end;

procedure TCryptUtil.DecryptFile(const FileName: string);
//1 Decrypts a Base 64 ASCII armoured file
var
  InStream: TStringStream;
  OutFileStream: TFileStream;
  TempStream, BitStream: TStream;
  FileText: TStringList;
  I: Integer;
begin
  CheckFile(FileName);

  FileText := TStringList.Create;
  InStream := TStringStream.Create('');
  //This assumes that the file is called *.original extension.asc
  //and removes the .asc bit to give the original file name
  OutFileStream := TFileStream.Create(ChangeFileExt(FileName, ''), fmCreate);
  try
    FileText.LoadFromFile(FileName);
    //Remove header and footer
    FileText.Delete(0);
    FileText.Delete(0);
    FileText.Delete(0);
    FileText.Delete(FileText.Count - 1);
    FileText.Delete(FileText.Count - 1);

    //Make it all into one line withour any CRLFs
    for I := 0 to FileText.Count - 1 do
      InStream.WriteString(FileText[I]);

    InStream.Position := 0;
    BitStream := Dearmour(InStream);
    try
      TempStream := FCrypt.DecryptStream(BitStream);
      try
        TempStream.Position := 0;
        OutFileStream.CopyFrom(TempStream, TempStream.Size);
      finally
        FreeAndNil(TempStream);
      end;
    finally
      FreeAndNil(BitStream);
    end;
  finally
    FreeAndNil(OutFileStream);
    FreeAndNil(InStream);
  end;
end;

function TCryptUtil.DecryptString(const InStr: string): string;
//1 Decrypts a single Base 64 ASCII Armoured string
var
  InStream, OutStream: TStringStream;
  TempStream, TextStream: TStream;
begin
  InStream := TStringStream.Create(InStr);
  OutStream := TStringStream.Create('');
  try
    TempStream := Dearmour(InStream);
    try
      TextStream := FCrypt.DecryptStream(TempStream);
      try
        TextStream.Position := 0;
        OutStream.CopyFrom(TextStream, TextStream.Size);
        Result := OutStream.DataString;
      finally
        FreeAndNil(TextStream);
      end;
    finally
      FreeAndNil(TempStream);
    end;
  finally
    FreeAndNil(InStream);
    FreeAndNil(OutStream);
  end;
end;

function TCryptUtil.DecryptStrings(const InStrings: TStrings): TStrings;
//1 Decrypts TStrings
var
  InStream: TStringStream;
  TempStream, BitStream: TStream;
  TempText: TStringList;
  I: Integer;
begin
  TempText := TStringList.Create;
  TempText.Assign(InStrings);

  InStream := TStringStream.Create('');
  try
    //Remove header and footer
    TempText.Delete(0);
    TempText.Delete(0);
    TempText.Delete(0);
    TempText.Delete(TempText.Count - 1);
    TempText.Delete(TempText.Count - 1);

    //Make it all into one line withour any CRLFs
    for I := 0 to TempText.Count - 1 do
      InStream.WriteString(TempText[I]);

    InStream.Position := 0;
    BitStream := Dearmour(InStream);
    try
      TempStream := FCrypt.DecryptStream(BitStream);
      try
        TempStream.Position := 0;
        TempText.LoadFromStream(TempStream);
      finally
        FreeAndNil(TempStream);
      end;
    finally
      FreeAndNil(BitStream);
    end;
  finally
    FreeAndNil(InStream);
  end;

  Result := TempText;
end;

procedure TCryptUtil.EncryptFile(const FileName: string);
//1 Encrypts a file to Base 64 ASCII Armoured file
var
  InFileStream: TFileStream;
  TempStream, ArmourStream: TStream;
  StrStream: TStringStream;
  OutText: TStringList;
  Temp: string;
begin
  CheckFile(FileName);

  InFileStream := TFileStream.Create(FileName, fmOpenRead);
  OutText := TStringList.Create;
  try
    InFileStream.Position := 0;
    TempStream := FCrypt.EncryptStream(InFileStream);
    try
      ArmourStream := Armour(TempStream);
      StrStream := TStringStream.Create('');
      try
        ArmourStream.Position := 0;
        StrStream.CopyFrom(ArmourStream, ArmourStream.Size);
        StrStream.Position := 0;
        while (StrStream.Position <> StrStream.Size) do
        begin
          //format output to 64 character lines
          Temp := StrStream.ReadString(64);
          OutText.Add(Temp);
        end;
      finally
        FreeAndNil(StrStream);
        FreeAndNil(ArmourStream);
      end;
    finally
      FreeAndNil(TempStream);
    end;

    //Add header and footer
    OutText.Insert(0, '-----BEGIN CRYPTO MESSAGE-----');
    OutText.Insert(1, 'Cipher: RC4');
    OutText.Insert(2, '');
    OutText.Add('');
    OutText.Add('-----END CRYPTO MESSAGE-----');
    //save to .asc file
    OutText.SaveToFile(FileName + '.asc');

  finally
    FreeAndNil(OutText);
    FreeAndNil(InFileStream);
  end;
end;

function TCryptUtil.EncryptString(const InStr: string): string;
//1 Encrypts a character string to a Base 64 ASCII Armoured output
var
  InStream, OutStream: TStringStream;
  TempStream, ArmourStream: TStream;
begin
  InStream := TStringStream.Create(InStr);
  OutStream := TStringStream.Create('');
  try
    TempStream := FCrypt.EncryptStream(InStream);
    try
      ArmourStream := Armour(TempStream);
      try
        ArmourStream.Position := 0;
        OutStream.CopyFrom(ArmourStream, ArmourStream.Size);
        Result := OutStream.DataString;
      finally
        FreeAndNil(ArmourStream);
      end;
    finally
      FreeAndNil(TempStream);
    end;
  finally
    FreeAndNil(InStream);
    FreeAndNil(OutStream);
  end;
end;

function TCryptUtil.EncryptStrings(const InStrings: TStrings): TStrings;
//1 Encrypts TStrings
var
  InStream: TMemoryStream;
  TempStream, ArmourStream: TStream;
  StrStream: TStringStream;
  OutText: TStringList;
  Temp: string;
begin
  InStream := TMemoryStream.Create;
  InStrings.SaveToStream(InStream);
  OutText := TStringList.Create;
  try
    InStream.Position := 0;
    TempStream := FCrypt.EncryptStream(InStream);
    try
      ArmourStream := Armour(TempStream);
      StrStream := TStringStream.Create('');
      try
        ArmourStream.Position := 0;
        StrStream.CopyFrom(ArmourStream, ArmourStream.Size);
        StrStream.Position := 0;
        while (StrStream.Position <> StrStream.Size) do
        begin
          //Formats text into 64 character lines
          Temp := StrStream.ReadString(64);
          OutText.Add(Temp);
        end;
      finally
        FreeAndNil(StrStream);
        FreeAndNil(ArmourStream);
      end;
    finally
      FreeAndNil(TempStream);
    end;

    //add header and footer
    OutText.Insert(0, '-----BEGIN CRYPTO MESSAGE-----');
    OutText.Insert(1, 'Cipher: RC4');
    OutText.Insert(2, '');
    OutText.Add('');
    OutText.Add('-----END CRYPTO MESSAGE-----');

  finally
    FreeAndNil(InStream);
  end;

  Result := OutText
end;

function TCryptUtil.GetKeyText: string;
begin
  Result := FCrypt.KeyText;
end;

procedure TCryptUtil.SetKeyText(const Value: string);
begin
  FCrypt.KeyText := Value;
end;

{
***************************** TCryptUtilSingleton ******************************
}
constructor TCryptUtilSingleton.Create;
begin
  inherited Create;
  raise Exception.CreateFmt('Access class %s through Instance only',
      [ClassName]);
end;

constructor TCryptUtilSingleton.CreateInstance;
begin
  inherited Create;
end;

destructor TCryptUtilSingleton.Destroy;
begin
  if AccessInstance(0) = Self then AccessInstance(2);
  inherited Destroy;
end;

class function TCryptUtilSingleton.AccessInstance(Request: Integer):
    TCryptUtilSingleton;

  {$WRITEABLECONST ON}
  const FInstance: TCryptUtilSingleton = nil;
  {$WRITEABLECONST OFF}

begin
  case Request of
    0 : ;
    1 : if not Assigned(FInstance) then FInstance := CreateInstance;
    2 : FInstance := nil;
  else
    raise Exception.CreateFmt('Illegal request %d in AccessInstance',
        [Request]);
  end;
  Result := FInstance;
end;

class function TCryptUtilSingleton.Instance: TCryptUtilSingleton;
begin
  Result := AccessInstance(1);
end;

class procedure TCryptUtilSingleton.ReleaseInstance;
begin
  AccessInstance(0).Free;
end;



end.
