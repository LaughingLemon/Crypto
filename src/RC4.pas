unit RC4;

{$MODE Delphi}

interface

uses
  Classes, SysUtils, Crypto;

type
  TRC4ByteArray = array [$00..$FF] of Byte;

  TRC4 = class(TStreamCipher)
  private
    FCounter1: Byte;
    FCounter2: Byte;
  protected
    FKeyStream: TRC4ByteArray;
    procedure InitialiseKeyStream(const KeyString: string); override;
    function KeyStream: Byte; override;
  end;


implementation

{
************************************* TRC4 *************************************
}
procedure TRC4.InitialiseKeyStream(const KeyString: string);
var
  I, J, TempKey, Temp: Byte;
  KeyLength: Integer;
begin
  //Initialise elements $00 to $FF
  for I := $00 to $FF do
    FKeyStream[I] := I;

  J := $00;
  KeyLength := Length(KeyString);
  for I := $00 to $FF do
  begin
    //Calculate J from I and previous J
    TempKey := Ord(KeyString[(I mod KeyLength) + 1]) mod 256;
    J := (J + FKeyStream[I] + TempKey) mod 256;
    //swap elements I and J arounf
    Temp := FKeyStream[I];
    FKeyStream[I] := FKeyStream[J];
    FKeyStream[J] := Temp;
  end;

  FCounter1 := 0;
  FCounter2 := 0;
end;

function TRC4.KeyStream: Byte;
var
  Temp: Byte;
begin
  //Calculate the new counter values
  FCounter1 := (FCounter1 + 1) mod 256;
  FCounter2 := (FCounter2 + FKeyStream[FCounter1]) mod 256;

  //Swap the elements around
  Temp := FKeyStream[FCounter1];
  FKeyStream[FCounter1] := FKeyStream[FCounter2];
  FKeyStream[FCounter2] := Temp;

  Result := FKeyStream[(FKeyStream[FCounter1] + FKeyStream[FCounter2]) mod 256]
end;


end.
