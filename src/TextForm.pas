unit TextForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdActns, ActnList, ToolWin, ImgList, StdCtrls,
  ExtCtrls;

type
  TfrmText = class(TForm)
    ToolBar1: TToolBar;
    ActionList1: TActionList;
    actEncryptText: TAction;
    actDecryptText: TAction;
    StatusBar1: TStatusBar;
    Splitter1: TSplitter;
    Panel2: TPanel;
    Label2: TLabel;
    mmoCipherText: TMemo;
    Panel1: TPanel;
    Label1: TLabel;
    mmoPlainText: TMemo;
    ImageList1: TImageList;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    actClose: TAction;
    procedure actEncryptTextUpdate(Sender: TObject);
    procedure actDecryptTextUpdate(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actEncryptTextExecute(Sender: TObject);
    procedure actDecryptTextExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmText: TfrmText;

implementation

uses
  Crypto;

{$R *.dfm}

procedure TfrmText.actEncryptTextUpdate(Sender: TObject);
begin
  actEncryptText.Enabled := (mmoPlainText.Text <> '');
end;

procedure TfrmText.actDecryptTextUpdate(Sender: TObject);
begin
  actDecryptText.Enabled := (mmoCipherText.Text <> '');
end;

procedure TfrmText.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmText.actEncryptTextExecute(Sender: TObject);
var
  Temp: TStrings;
begin
  Temp := TCryptUtilSingleton.Instance.EncryptStrings(mmoPlainText.Lines);
  try
    mmoCipherText.Lines.Assign(Temp);
  finally
    FreeAndNil(Temp);
  end;
end;

procedure TfrmText.actDecryptTextExecute(Sender: TObject);
var
  Temp: TStrings;
begin
  Temp := TCryptUtilSingleton.Instance.DecryptStrings(mmoCipherText.Lines);
  try
    mmoPlainText.Lines.Assign(Temp);
  finally
    FreeAndNil(Temp);
  end;
end;

end.
