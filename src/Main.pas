unit Main;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ToolWin, ComCtrls, ActnList, StdActns;

type
  TfrmMain = class(TForm)
    ToolBar1: TToolBar;
    ImageList1: TImageList;
    ActionList1: TActionList;
    actTextForm: TAction;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    actEncryptFile: TFileOpen;
    actDecryptFile: TFileOpen;
    actExit: TFileExit;
    ToolButton4: TToolButton;
    actChangePassword: TAction;
    ToolButton5: TToolButton;
    procedure actTextFormExecute(Sender: TObject);
    procedure actEncryptFileAccept(Sender: TObject);
    procedure actDecryptFileAccept(Sender: TObject);
    procedure actChangePasswordExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  TextForm, Crypto, Password;

{$R *.lfm}

procedure TfrmMain.actTextFormExecute(Sender: TObject);
begin
  Application.CreateForm(TfrmText, frmText);
  try
    frmText.ShowModal;
  finally
    FreeAndNil(frmText);
  end;
end;

procedure TfrmMain.actEncryptFileAccept(Sender: TObject);
begin
  TCryptUtilSingleton.Instance.EncryptFile(actEncryptFile.Dialog.FileName);
end;

procedure TfrmMain.actDecryptFileAccept(Sender: TObject);
begin
  TCryptUtilSingleton.Instance.DecryptFile(actDecryptFile.Dialog.FileName);
end;

procedure TfrmMain.actChangePasswordExecute(Sender: TObject);
begin
  frmPassword := TfrmPassword.Create(nil);
  try
    if (frmPassword.ShowModal = mrOK) then
    begin
      TCryptUtilSingleton.Instance.KeyText := frmPassword.Password.Text;
    end;
  finally
    FreeAndNil(frmPassword);
  end;
end;

end.
