unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs;

type

  { TForm2 }

  TForm2 = class(TForm)
    PROCEDURE FormClose(Sender: TObject; VAR CloseAction: TCloseAction);
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}
USES Unit1;

{ TForm2 }

PROCEDURE TForm2.FormClose(Sender: TObject; VAR CloseAction: TCloseAction);
BEGIN
  Form1.CheckBoxVeranschaulichung.Checked:=FALSE;
end;

end.

