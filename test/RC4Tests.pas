unit RC4Tests;

interface

uses
  RC4,
  TestFrameWork;

type
  TRC4Tests = class(TTestCase)
  private
    FRC4: TRC4;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    // Test methods
    procedure TestInitialiseKeyStream;
    procedure TestKeyStream;

  end;

implementation

{ TRC4Tests }

uses
  SysUtils;

type
  TRC4Proxy = class(TRC4)
  end;

procedure TRC4Tests.SetUp;
begin
  inherited;
  FRC4 := TRC4Proxy.Create;
end;

procedure TRC4Tests.TearDown;
begin
  inherited;
  FreeAndNil(FRC4);
end;

procedure TRC4Tests.TestInitialiseKeyStream;
begin
  with (FRC4 as TRC4Proxy) do
  begin
    InitialiseKeyStream('Test Key ?');

    Check(FKeyStream[$00] = $EC, 'FKeyStream[$00] is $' +IntToHex(FKeyStream[$00],2));
    Check(FKeyStream[$E8] = $2C, 'FKeyStream[$E8] is $' +IntToHex(FKeyStream[$E8],2));
    Check(FKeyStream[$DC] = $D6, 'FKeyStream[$DC] is $' +IntToHex(FKeyStream[$DC],2));
    Check(FKeyStream[$BD] = $11, 'FKeyStream[$BD] is $' +IntToHex(FKeyStream[$BD],2));
    Check(FKeyStream[$56] = $AF, 'FKeyStream[$56] is $' +IntToHex(FKeyStream[$56],2));
    Check(FKeyStream[$A0] = $D4, 'FKeyStream[$A0] is $' +IntToHex(FKeyStream[$A0],2));
    Check(FKeyStream[$FF] = $5D, 'FKeyStream[$FF] is $' +IntToHex(FKeyStream[$FF],2));
  end;
end;

procedure TRC4Tests.TestKeyStream;
var
  I: Byte;
begin
  with (FRC4 as TRC4Proxy) do
  begin
    for I := $00 to $FF do
      FKeyStream[I] := I;

    I := KeyStream;

    Check(I = $02, 'Result is $' +IntToHex(I,2));

    I := KeyStream;

    Check(I = $05, 'Result is $' +IntToHex(I,2));
    Check(FKeyStream[$02] = $03, 'FKeyStream[$02] is $' +IntToHex(FKeyStream[$02],2));
    Check(FKeyStream[$03] = $02, 'FKeyStream[$03] is $' +IntToHex(FKeyStream[$03],2));

    I := KeyStream;

    Check(I = $07, 'Result is $' +IntToHex(I,2));
    Check(FKeyStream[$03] = $05, 'FKeyStream[$03] is $' +IntToHex(FKeyStream[$03],2));
    Check(FKeyStream[$05] = $02, 'FKeyStream[$05] is $' +IntToHex(FKeyStream[$05],2));

    I := KeyStream;

    Check(I = $0D, 'Result is $' +IntToHex(I,2));
    Check(FKeyStream[$04] = $09, 'FKeyStream[$04] is $' +IntToHex(FKeyStream[$04],2));
    Check(FKeyStream[$09] = $04, 'FKeyStream[$09] is $' +IntToHex(FKeyStream[$09],2));

    I := KeyStream;

    Check(I = $0D, 'Result is $' +IntToHex(I,2));
    Check(FKeyStream[$05] = $0B, 'FKeyStream[$05] is $' +IntToHex(FKeyStream[$05],2));
    Check(FKeyStream[$0B] = $02, 'FKeyStream[$0B] is $' +IntToHex(FKeyStream[$0B],2));
  end;
end;

initialization

  TestFramework.RegisterTest('RC4Tests Suite',
    TRC4Tests.Suite);

end.
 