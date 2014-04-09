program CryptoApp;

uses
  Forms,
  Controls,
  SysUtils,
  Main in 'Main.pas' {frmMain},
  TextForm in 'TextForm.pas' {frmText},
  Password in 'Password.pas' {frmPassword},
  RC4 in 'RC4.pas',
  Crypto in 'Crypto.pas';

{$R *.res}

begin
  Application.Initialize;
  //don't use CreateForm as this sets Password as the main form
  frmPassword := TfrmPassword.Create(nil);
  try
    if (frmPassword.ShowModal = mrOK) then
    begin
      TCryptUtilSingleton.Instance.Crypt := TRC4.Create;
      TCryptUtilSingleton.Instance.KeyText := frmPassword.Password.Text;
      Application.CreateForm(TfrmMain, frmMain);
    end;
  finally
    FreeAndNil(frmPassword);
  end;
  Application.Run;
end.
