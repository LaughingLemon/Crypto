unit CryptTests;

interface

uses
  Crypto,
  TestFrameWork;

type
  TCryptTests = class(TTestCase)
  private
    FCryptUtil: TCryptUtil;
    FCrypt: TCrypt;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure CreateEncryptBlankFileNameException;
    procedure CreateDecryptBlankFileNameException;
    procedure CreateEncryptUnknownFileNameException;
    procedure CreateDecryptUnknownFileNameException;
  published
    // Test methods
    procedure TestArmour;
    procedure TestDearmour;
    procedure TestDecryptFile;
    procedure TestDecryptString;
    procedure TestEncryptFile;
    procedure TestEncryptString;
    procedure TestEncryptStrings;
    procedure TestDecryptStrings;
  end;

implementation

{ TCryptTests }

uses
  Classes, SysUtils;

type
  TCryptProxy = class(TCrypt)
  protected
    function InternalDecrypt(const InStream: TStream;
                             const KeyText: string): TStream; override;
    function InternalEncrypt(const InStream: TStream;
                             const KeyText: string): TStream; override;
  end;

  TCryptUtilProxy = class(TCryptUtil)
  end;

procedure TCryptTests.TestArmour;
var
  TempStream: TMemoryStream;
  ResultStream: TStream;
  Temp: Byte;
  TempChar: Char;
begin
  TempStream := TMemoryStream.Create;
  try
    Temp := $FF;
    TempStream.Write(Temp, SizeOf(Temp));

    ResultStream := (FCryptUtil as TCryptUtilProxy).Armour(TempStream);
    try
      Check(ResultStream <> nil, 'Result is nil');

      ResultStream.Position := 0;
      ResultStream.Read(TempChar, SizeOf(TempChar));
      Check(TempChar = '/', 'Result is "' + TempChar + '"');
      ResultStream.Read(TempChar, SizeOf(TempChar));
      Check(TempChar = 'w', 'Result is "' + TempChar + '"');
      ResultStream.Read(TempChar, SizeOf(TempChar));
      Check(TempChar = '=', 'Result is "' + TempChar + '"');
      ResultStream.Read(TempChar, SizeOf(TempChar));
      Check(TempChar = '=', 'Result is "' + TempChar + '"');
    finally
      FreeAndNil(ResultStream);
    end;

    TempStream.Clear;
    Temp := $FF;
    TempStream.Write(Temp, SizeOf(Temp));
    Temp := $F0;
    TempStream.Write(Temp, SizeOf(Temp));

    ResultStream := (FCryptUtil as TCryptUtilProxy).Armour(TempStream);
    try
      Check(ResultStream <> nil, 'Result is nil');

      ResultStream.Position := 0;
      ResultStream.Read(TempChar, SizeOf(TempChar));
      Check(TempChar = '/', 'Result is "' + TempChar + '"');
      ResultStream.Read(TempChar, SizeOf(TempChar));
      Check(TempChar = '/', 'Result is "' + TempChar + '"');
      ResultStream.Read(TempChar, SizeOf(TempChar));
      Check(TempChar = 'A', 'Result is "' + TempChar + '"');
      ResultStream.Read(TempChar, SizeOf(TempChar));
      Check(TempChar = '=', 'Result is "' + TempChar + '"');
    finally
      FreeAndNil(ResultStream);
    end;

    TempStream.Clear;
    Temp := $FF;
    TempStream.Write(Temp, SizeOf(Temp));
    Temp := $F0;
    TempStream.Write(Temp, SizeOf(Temp));
    Temp := $0F;
    TempStream.Write(Temp, SizeOf(Temp));

    ResultStream := (FCryptUtil as TCryptUtilProxy).Armour(TempStream);
    try
      Check(ResultStream <> nil, 'Result is nil');

      ResultStream.Position := 0;
      ResultStream.Read(TempChar, SizeOf(TempChar));
      Check(TempChar = '/', 'Result is "' + TempChar + '"');
      ResultStream.Read(TempChar, SizeOf(TempChar));
      Check(TempChar = '/', 'Result is "' + TempChar + '"');
      ResultStream.Read(TempChar, SizeOf(TempChar));
      Check(TempChar = 'A', 'Result is "' + TempChar + '"');
      ResultStream.Read(TempChar, SizeOf(TempChar));
      Check(TempChar = 'P', 'Result is "' + TempChar + '"');
    finally
      FreeAndNil(ResultStream);
    end;
  finally
    FreeAndNil(TempStream);
  end;
end;

procedure TCryptTests.TestDearmour;
var
  TempStream: TMemoryStream;
  ResultStream: TStream;
  Temp: Byte;
  TempChar: Char;
begin
  TempStream := TMemoryStream.Create;
  try
    TempChar := '/';
    TempStream.Write(TempChar, SizeOf(TempChar));
    TempChar := 'w';
    TempStream.Write(TempChar, SizeOf(TempChar));
    TempChar := '=';
    TempStream.Write(TempChar, SizeOf(TempChar));
    TempChar := '=';
    TempStream.Write(TempChar, SizeOf(TempChar));

    ResultStream := (FCryptUtil as TCryptUtilProxy).Dearmour(TempStream);
    try
      Check(ResultStream <> nil, 'Result is nil');

      Check(ResultStream.Size = 1, 'ResultStream.Size = ' + IntToStr(ResultStream.Size));
      ResultStream.Position := 0;
      ResultStream.Read(Temp, SizeOf(Temp));
      Check(Temp = $FF, 'Result is "' + IntToHex(Temp, 2) + '"');
    finally
      FreeAndNil(ResultStream);
    end;

    TempStream.Clear;
    TempChar := '/';
    TempStream.Write(TempChar, SizeOf(TempChar));
    TempChar := '/';
    TempStream.Write(TempChar, SizeOf(TempChar));
    TempChar := 'A';
    TempStream.Write(TempChar, SizeOf(TempChar));
    TempChar := '=';
    TempStream.Write(TempChar, SizeOf(TempChar));

    ResultStream := (FCryptUtil as TCryptUtilProxy).Dearmour(TempStream);
    try
      Check(ResultStream <> nil, 'Result is nil');
      Check(ResultStream.Size = 2, 'ResultStream.Size = ' + IntToStr(ResultStream.Size));

      ResultStream.Position := 0;
      ResultStream.Read(Temp, SizeOf(Temp));
      Check(Temp = $FF, 'Result is "' + IntToHex(Temp, 2) + '"');
      ResultStream.Read(Temp, SizeOf(Temp));
      Check(Temp = $F0, 'Result is "' + IntToHex(Temp, 2) + '"');
    finally
      FreeAndNil(ResultStream);
    end;

    TempStream.Clear;
    TempChar := '/';
    TempStream.Write(TempChar, SizeOf(TempChar));
    TempChar := '/';
    TempStream.Write(TempChar, SizeOf(TempChar));
    TempChar := 'A';
    TempStream.Write(TempChar, SizeOf(TempChar));
    TempChar := 'P';
    TempStream.Write(TempChar, SizeOf(TempChar));

    ResultStream := (FCryptUtil as TCryptUtilProxy).Dearmour(TempStream);
    try
      Check(ResultStream <> nil, 'Result is nil');
      Check(ResultStream.Size = 3, 'ResultStream.Size = ' + IntToStr(ResultStream.Size));

      ResultStream.Position := 0;
      ResultStream.Read(Temp, SizeOf(Temp));
      Check(Temp = $FF, 'Result is "' + IntToHex(Temp, 2) + '"');
      ResultStream.Read(Temp, SizeOf(Temp));
      Check(Temp = $F0, 'Result is "' + IntToHex(Temp, 2) + '"');
      ResultStream.Read(Temp, SizeOf(Temp));
      Check(Temp = $0F, 'Result is "' + IntToHex(Temp, 2) + '"');
    finally
      FreeAndNil(ResultStream);
    end;
  finally
    FreeAndNil(TempStream);
  end;
end;

procedure TCryptTests.CreateDecryptBlankFileNameException;
begin
  FCryptUtil.DecryptFile('');
end;

procedure TCryptTests.CreateDecryptUnknownFileNameException;
begin
  FCryptUtil.DecryptFile('unknown.asc');
end;

procedure TCryptTests.TestDecryptFile;
var
  FileText, ResultText: TStringList;
begin
  //Test for blank file name
  CheckException(CreateDecryptBlankFileNameException, ECryptException, 'Blank file name does not create exception');
  //Test for file that doesn't exist
  CheckException(CreateDecryptUnknownFileNameException, ECryptException, 'Unknown file does not create exception');

  FileText := TStringList.Create;
  ResultText := TStringList.Create;
  try
    FileText.Add('-----BEGIN CRYPTO MESSAGE-----');
    FileText.Add('Cipher: RC4');
    FileText.Add('');
    FileText.Add('q5eWjN+WjN+MkJKa34uah4vy9YuXnovfmJCajN+Wkd+e35mWk5ry9Z6Rm9+Il56L');
    FileText.Add('35iQmozflpHfnt+ZlpOa8vWMi56GjN+Wkd+e35mWk5ry9Q==');
    FileText.Add('');
    FileText.Add('-----END CRYPTO MESSAGE-----');

    FileText.SaveToFile('test.txt.asc');

    FCryptUtil.DecryptFile('test.txt.asc');

    Check(FileExists('test.txt'), 'File has not been created');

    ResultText.LoadFromFile('test.txt');

    Check(ResultText[0] = 'This is some text', 'Text is ' + ResultText[0]);
    Check(ResultText[1] = 'that goes in a file', 'Text is ' + ResultText[1]);
    Check(ResultText[2] = 'and what goes in a file', 'Text is ' + ResultText[2]);
    Check(ResultText[3] = 'stays in a file', 'Text is ' + ResultText[3]);
  finally
    FreeAndNil(ResultText);
    FreeAndNil(FileText);
    DeleteFile('test.txt.asc');
    DeleteFile('test.txt');
  end;
end;

procedure TCryptTests.TestDecryptString;
var
  Text: string;
begin
  //Test that Decrypting a blank string returns a blank string
  Text := 'Text';
  Text := FCryptUtil.DecryptString('');
  Check(Text = '', 'Result is not blank');

  //Test Decrypting a string
  Text := FCryptUtil.DecryptString('jJCSmouXlpGYjJCSmouXlpGY');
  Check(Text = 'somethingsomething', 'Result is ' + Text);

  //Test Decrypting a string with spaces
  Text := FCryptUtil.DecryptString('jJCSmouXlpGY34yQkpqLl5aRmN/fwA==');
  Check(Text = 'something something  ?', 'Result is ' + Text);
end;

procedure TCryptTests.CreateEncryptBlankFileNameException;
begin
  FCryptUtil.EncryptFile('');
end;

procedure TCryptTests.CreateEncryptUnknownFileNameException;
begin
  FCryptUtil.EncryptFile('unknown.txt');
end;

procedure TCryptTests.TestEncryptFile;
var
  FileText, ResultText: TStringList;
begin
  //Test for blank file name
  CheckException(CreateEncryptBlankFileNameException, ECryptException, 'Blank file name does not create exception');
  //Test for file that doesn't exist
  CheckException(CreateEncryptUnknownFileNameException, ECryptException, 'Unknown file does not create exception');

  FileText := TStringList.Create;
  ResultText := TStringList.Create;
  try
    FileText.Add('This is some text');
    FileText.Add('that goes in a file');
    FileText.Add('and what goes in a file');
    FileText.Add('stays in a file');

    FileText.SaveToFile('test.txt');

    FCryptUtil.EncryptFile('test.txt');

    Check(FileExists('test.txt.asc'), 'File has not been created');

    ResultText.LoadFromFile('test.txt.asc');

    Check(ResultText[0] = '-----BEGIN CRYPTO MESSAGE-----', 'Text is ' + ResultText[0]);
    Check(ResultText[1] = 'Cipher: RC4', 'Text is ' + ResultText[1]);
    Check(ResultText[2] = '', 'Text is ' + ResultText[2]);
    Check(ResultText[3] = 'q5eWjN+WjN+MkJKa34uah4vy9YuXnovfmJCajN+Wkd+e35mWk5ry9Z6Rm9+Il56L', 'Text is ' + ResultText[3]);
    Check(ResultText[4] = '35iQmozflpHfnt+ZlpOa8vWMi56GjN+Wkd+e35mWk5ry9Q==', 'Text is ' + ResultText[4]);
    Check(ResultText[5] = '', 'Text is ' + ResultText[4]);
    Check(ResultText[6] = '-----END CRYPTO MESSAGE-----', 'Text is ' + ResultText[5]);
  finally
    FreeAndNil(ResultText);
    FreeAndNil(FileText);
    DeleteFile('test.txt.asc');
    DeleteFile('test.txt');
  end;
end;

procedure TCryptTests.TestEncryptString;
var
  Text: string;
begin
  //Test that encrypting a blank string returns a blank string
  Text := 'Text';
  Text := FCryptUtil.EncryptString('');
  Check(Text = '', 'Result is not blank');

  //Test Encrypting a string
  Text := FCryptUtil.EncryptString('somethingsomething');
  Check(Text = 'jJCSmouXlpGYjJCSmouXlpGY', 'Result is ' + Text);

  //Test Encrypting a string with spaces
  Text := FCryptUtil.EncryptString('something something  ?');
  Check(Text = 'jJCSmouXlpGY34yQkpqLl5aRmN/fwA==', 'Result is ' + Text);
end;

procedure TCryptTests.SetUp;
begin
  inherited;
  FCrypt := TCryptProxy.Create;
  FCryptUtil := TCryptUtilProxy.Create;
  FCryptUtil.Crypt := FCrypt;
end;

procedure TCryptTests.TearDown;
begin
  inherited;
  FCryptUtil.Crypt := nil;
  FreeAndNil(FCrypt);
  FreeAndNil(FCryptUtil);
end;

procedure TCryptTests.TestDecryptStrings;
var
  InText: TStringList;
  ResultText: TStrings;
begin
  InText := TStringList.Create;
  try
    InText.Add('-----BEGIN CRYPTO MESSAGE-----');
    InText.Add('Cipher: RC4');
    InText.Add('');
    InText.Add('q5eWjN+WjN+MkJKa34uah4vy9YuXnovfmJCajN+Wkd+e35mWk5ry9Z6Rm9+Il56L');
    InText.Add('35iQmozflpHfnt+ZlpOa8vWMi56GjN+Wkd+e35mWk5ry9Q==');
    InText.Add('');
    InText.Add('-----END CRYPTO MESSAGE-----');

    ResultText := FCryptUtil.DecryptStrings(InText);

    Check(ResultText[0] = 'This is some text', 'Text is ' + ResultText[0]);
    Check(ResultText[1] = 'that goes in a file', 'Text is ' + ResultText[1]);
    Check(ResultText[2] = 'and what goes in a file', 'Text is ' + ResultText[2]);
    Check(ResultText[3] = 'stays in a file', 'Text is ' + ResultText[3]);
  finally
    FreeAndNil(ResultText);
    FreeAndNil(InText);
  end;
end;

procedure TCryptTests.TestEncryptStrings;
var
  InText: TStringList;
  ResultText: TStrings;
begin
  InText := TStringList.Create;
  try
    InText.Add('This is some text');
    InText.Add('that goes in a file');
    InText.Add('and what goes in a file');
    InText.Add('stays in a file');

    ResultText := FCryptUtil.EncryptStrings(InText);

    Check(ResultText[0] = '-----BEGIN CRYPTO MESSAGE-----', 'Text is ' + ResultText[0]);
    Check(ResultText[1] = 'Cipher: RC4', 'Text is ' + ResultText[1]);
    Check(ResultText[2] = '', 'Text is ' + ResultText[2]);
    Check(ResultText[3] = 'q5eWjN+WjN+MkJKa34uah4vy9YuXnovfmJCajN+Wkd+e35mWk5ry9Z6Rm9+Il56L', 'Text is ' + ResultText[3]);
    Check(ResultText[4] = '35iQmozflpHfnt+ZlpOa8vWMi56GjN+Wkd+e35mWk5ry9Q==', 'Text is ' + ResultText[4]);
    Check(ResultText[5] = '', 'Text is ' + ResultText[4]);
    Check(ResultText[6] = '-----END CRYPTO MESSAGE-----', 'Text is ' + ResultText[5]);
  finally
    FreeAndNil(ResultText);
    FreeAndNil(InText);
  end;
end;

{ TCryptProxy }

function TCryptProxy.InternalDecrypt(const InStream: TStream;
                                     const KeyText: string): TStream;
var
  ResultStream: TMemoryStream;
  Temp: Byte;
begin
  //simply inverts the bytes in the stream
  ResultStream := TMemoryStream.Create;
  InStream.Position := 0;
  while (InStream.Position <> InStream.Size) do
  begin
    InStream.Read(Temp, SizeOf(Temp));
    Temp := not Temp;
    ResultStream.Write(Temp, SizeOf(Temp));
  end;
  Result := ResultStream;
end;

function TCryptProxy.InternalEncrypt(const InStream: TStream;
                                     const KeyText: string): TStream;
begin
  //saves duplication
  Result := InternalDecrypt(InStream, KeyText);
end;

initialization

  TestFramework.RegisterTest('CryptTests Suite',
    TCryptTests.Suite);

end.
 