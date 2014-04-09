unit StreamCipherTests;

interface

uses
  Crypto,
  TestFrameWork;

type
  TStreamCipherClass = class of TStreamCipher;

  TStreamCipherTests = class(TTestCase)
  private
    FStreamCipher: TStreamCipher;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure CreateTStreamCipherClass(StreamCipher: TStreamCipherClass);
  published
    // Test methods
    procedure TestInternalDecrypt;
    procedure TestInternalEncrypt;
  end;

implementation

{ TStreamCipherTests }

uses
  Classes, SysUtils;

type
  TStreamCipherProxy = class(TStreamCipher)
  private
    FTestStream: TStream;
  protected
    procedure InitialiseKeyStream(const KeyString: string); override;
    function KeyStream: Byte; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property TestStream: TStream read FTestStream;
  end;

procedure TStreamCipherTests.CreateTStreamCipherClass(
  StreamCipher: TStreamCipherClass);
begin
  FStreamCipher := StreamCipher.Create;
end;

procedure TStreamCipherTests.SetUp;
begin
  inherited;
  CreateTStreamCipherClass(TStreamCipherProxy);
end;

procedure TStreamCipherTests.TearDown;
begin
  inherited;
  FreeAndNil(FStreamCipher);
end;

procedure TStreamCipherTests.TestInternalDecrypt;
var
  InStream: TMemoryStream;
  ResultStream: TStream;
  Temp: Byte;
begin
  InStream := TMemoryStream.Create;
  try
    Temp := $5A;
    InStream.Write(Temp, SizeOf(Byte));
    Temp := $8B;
    InStream.Write(Temp, SizeOf(Byte));
    Temp := $5C;
    InStream.Write(Temp, SizeOf(Byte));

    with (FStreamCipher as TStreamCipherProxy) do
    begin
      Temp := $FF;
      TestStream.Write(Temp, SizeOf(Byte));
      Temp := $F0;
      TestStream.Write(Temp, SizeOf(Byte));
      Temp := $0F;
      TestStream.Write(Temp, SizeOf(Byte));

      ResultStream := InternalDecrypt(InStream, 'TestKey');
      try
        ResultStream.Position := 0;
        ResultStream.Read(Temp, SizeOf(Byte));
        Check(Temp = $A5, 'Result is ' + IntToHex(Temp, 2));
        ResultStream.Read(Temp, SizeOf(Byte));
        Check(Temp = $7B, 'Result is ' + IntToHex(Temp, 2));
        ResultStream.Read(Temp, SizeOf(Byte));
        Check(Temp = $53, 'Result is ' + IntToHex(Temp, 2));
      finally
        FreeAndNil(ResultStream);
      end;
    end;
  finally
    FreeAndNil(InStream);
  end;
end;

procedure TStreamCipherTests.TestInternalEncrypt;
var
  InStream: TMemoryStream;
  ResultStream: TStream;
  Temp: Byte;
begin
  InStream := TMemoryStream.Create;
  try
    Temp := $A5;
    InStream.Write(Temp, SizeOf(Byte));
    Temp := $7B;
    InStream.Write(Temp, SizeOf(Byte));
    Temp := $53;
    InStream.Write(Temp, SizeOf(Byte));

    with (FStreamCipher as TStreamCipherProxy) do
    begin
      Temp := $FF;
      TestStream.Write(Temp, SizeOf(Byte));
      Temp := $F0;
      TestStream.Write(Temp, SizeOf(Byte));
      Temp := $0F;
      TestStream.Write(Temp, SizeOf(Byte));

      ResultStream := InternalEncrypt(InStream, 'TestKey');
      try
        ResultStream.Position := 0;
        ResultStream.Read(Temp, SizeOf(Byte));
        Check(Temp = $5A, 'Result is ' + IntToHex(Temp, 2));
        ResultStream.Read(Temp, SizeOf(Byte));
        Check(Temp = $8B, 'Result is ' + IntToHex(Temp, 2));
        ResultStream.Read(Temp, SizeOf(Byte));
        Check(Temp = $5C, 'Result is ' + IntToHex(Temp, 2));
      finally
        FreeAndNil(ResultStream);
      end;
    end;
  finally
    FreeAndNil(InStream);
  end;
end;

{ TStreamCipherProxy }

constructor TStreamCipherProxy.Create;
begin
  inherited Create;
  FTestStream := TMemoryStream.Create;
end;

destructor TStreamCipherProxy.Destroy;
begin
  FreeAndNil(FTestStream);
  inherited Destroy;
end;

procedure TStreamCipherProxy.InitialiseKeyStream(const KeyString: string);
begin
  inherited;
  FTestStream.Position := 0;
end;

function TStreamCipherProxy.KeyStream: Byte;
var
  Temp: Byte;
begin
  FTestStream.Read(Temp, SizeOf(Byte));
  Result := Temp;
end;

initialization

  TestFramework.RegisterTest('StreamCipherTests Suite',
    TStreamCipherTests.Suite);

end.
