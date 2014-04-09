unit Password;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons;

type
  TfrmPassword = class(TForm)
    Label1: TLabel;
    Password: TEdit;
    OKBtn: TButton;
    CancelBtn: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPassword: TfrmPassword;

implementation

{$R *.dfm}

end.
 
