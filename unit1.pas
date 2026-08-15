unit Unit1;

{$mode objfpc}{$H+}


interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonStart: TButton;
    ButtonErzeugen: TButton;
    ButtonGleich: TButton;
    ButtonEnde: TButton;
    CheckBoxVeranschaulichung: TCheckBox;
    GroupBoxZeit: TGroupBox;
    GroupBoxAnzahl: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    LabelName: TLabel;
    LabelAnzahlZuweisungen: TLabel;
    LabelZeit: TLabel;
    ListBoxStartbelegung: TListBox;
    ListBoxSortierteZahlen: TListBox;
    RadioGroupVerzoegerung: TRadioGroup;
    RadioGroupVerfahren: TRadioGroup;
    RadioGroupAnzahl: TRadioGroup;
    RadioGroupVerteilung: TRadioGroup;
    PROCEDURE ButtonGleichClick(Sender: TObject);
    procedure ButtonEndeClick(Sender: TObject);
    procedure ButtonErzeugenClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure CheckBoxVeranschaulichungClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadioGroupAnzahlClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}
USES Unit2;
//===================================================================
// Cooler Coder-Name: Dung Nguyen
//===================================================================
//               eigene globale Deklarationen
//-------------------------------------------------------------------

TYPE
  tZahlenarray = ARRAY OF WORD;  //dyna moment, setlength später!!!!!

VAR
    feld:tZahlenarray;
    GVAnz:WORD;


//===================================================================
//               eigene coole abgeschlossene Routinen
//-------------------------------------------------------------------
PROCEDURE Bremse(ms:BYTE);
VAR pot:CARDINAL;
BEGIN
  pot:=Round(Power(10,ms));                                    //top 10 1 variable sparen
  WHILE pot>0 DO BEGIN Application.ProcessMessages;
    Dec(pot);
  END;
END;

PROCEDURE ZufaelligeBelegung(VAR f:tZahlenarray);
VAR i:WORD;
BEGIN
  FOR i:= 0 TO Length(f)-1 DO f[i]:=Random(Length(f))+1;

end;

PROCEDURE AbsteigendBelegen(VAR f:tZahlenarray);
VAR i:WORD;
BEGIN
  FOR i:= 0 TO Length(f)-1 DO f[i]:=Length(f)-i;

end;

PROCEDURE AlternierendBelegen1(VAR f:tZahlenarray);
VAR
  i: WORD;
  z:WORD;
BEGIN

  FOR i := 0 TO Length(f)-1 DO f[i]:=i+1;
  z:=Length(f);

  FOR i := 0 TO Length(f)-1 DO BEGIN
    IF Odd(i) THEN BEGIN
      f[i]:= z;
      z:= z - 2;
    END;
  END;
END;

PROCEDURE AlternierendBelegen2(VAR f:tZahlenarray);
VAR
  i:WORD;
  z1,z2:WORD;
BEGIN

  FOR i := 0 TO Length(f)-1 DO f[i]:=i+1;

  z1:=1;
  z2:=Length(f);

  FOR i := 0 TO Length(f)-1 DO BEGIN
    IF NOT(Odd(i)) THEN BEGIN
      f[i]:= z1;
      z1:= z1 +1;
    END
    ELSE BEGIN
      f[i]:= z2;
      z2:= z2 - 1;
    END;
  END;

END;

PROCEDURE ZeichneLinie(pos,laenge,breite,anz:WORD;farbe:TColor;CAN:TCanvas);
BEGIN     //ZeichneLinie(x,f[x],CAN.Width,Length(f),clLime,CAN);
IF laenge<>breite THEN
  BEGIN
  CAN.Pen.Color:=clBlack;
  CAN.Line(round(breite/anz*pos),breite,round(breite/anz*pos),0);

  CAN.Pen.Color:=farbe;
  CAN.Line(round(breite/anz*pos),breite,round(breite/anz*pos),round(breite*(1-laenge/anz)));//round((anz-laenge)*breite/anz));
  END
ELSE
  BEGIN
  CAN.Pen.Color:=clBlack;
  CAN.Line(pos,breite,pos,0);

  CAN.Pen.Color:=farbe;
  CAN.Line(pos,breite,pos,anz-laenge);
  END;
END;

PROCEDURE SpecialZeichneLinie(pos,laenge,breite,anz:WORD;farbe:TColor;CAN:TCanvas);
BEGIN     //ZeichneLinie(x,f[x],CAN.Width,Length(f),clLime,CAN);
IF laenge<>breite THEN
  BEGIN
  CAN.Pen.Color:=farbe;
  CAN.Line(round(breite/anz*pos),breite,round(breite/anz*pos),round(breite*(1-laenge/anz)));//round((anz-laenge)*breite/anz));
  END
ELSE
  BEGIN
  CAN.Pen.Color:=farbe;
  CAN.Line(pos,breite,pos,anz-laenge);
  END;
END;

PROCEDURE ZeigeFeld(feld:tZahlenarray;CAN:TCanvas);
VAR i,laenge:WORD;
    quo:REAL;
BEGIN
  CAN.Clear;
  laenge:=CAN.Width;
  quo:=Length(feld)/CAN.Width;
  CAN.Brush.Color:=clBlack;
  CAN.Pen.Color:=clRed;
  Application.ProcessMessages;
  CAN.Rectangle(-1,-1,laenge+1,laenge+1);
  Application.ProcessMessages;
  FOR i:= 0 TO CAN.Width-1 DO SpecialZeichneLinie(round(quo*i),feld[round(quo*i)],CAN.Width,Length(feld),clLime,CAN);
  FOR i:= 0 TO CAN.Width-1 DO SpecialZeichneLinie(round(quo*i-0.3333333),feld[round(quo*i+0.3333333)],CAN.Width,Length(feld),clLime,CAN);
  FOR i:= 0 TO CAN.Width-1 DO SpecialZeichneLinie(round(quo*i+0.3333333),feld[round(quo*i-0.3333333)],CAN.Width,Length(feld),clLime,CAN);

END;


PROCEDURE SystematischesTauschen(VAR f:tZahlenarray;CAN:Tcanvas;verz:BYTE;VAR anz:CARDINAL;graphisch:BOOLEAN);
  VAR i,j,n,w:WORD;
BEGIN
  n:=Length(f);
  FOR i:= 0 TO n-2 DO
    FOR j:= i+1 TO n-1 DO BEGIN
      {IF graphisch THEN BEGIN
         ZeichneLinie(j,f[j],CAN.Width,Length(f),clRed,CAN);
         ZeichneLinie(i,f[i],CAN.Width,Length(f),clRed,CAN);
         END; }
      IF f[i]>f[j] THEN BEGIN
         w:=f[i];
         f[i]:=f[j];
         f[j]:=w;
         Inc(anz);
         IF graphisch THEN BEGIN
         ZeichneLinie(j,f[j],CAN.Width,Length(f),clLime,CAN);
         ZeichneLinie(i,f[i],CAN.Width,Length(f),clLime,CAN);
         END;
      END;
      Bremse(verz);

    END;

end;

PROCEDURE Bubblesort(f:tZahlenarray;CAN:TCanvas;verz:BYTE;VAR anz:CARDINAL;graphisch:BOOLEAN);
VAR i,j,n,w:WORD;
BEGIN
  n:=Length(f);
  FOR i:= n-2 DOWNTO 0 DO
    FOR j:= 0 TO i DO BEGIN
      IF f[j]>f[j+1] THEN BEGIN
        w:=f[j];
        f[j]:=f[j+1];
        f[j+1]:=w;
        Inc(anz);
        IF graphisch THEN BEGIN
          ZeichneLinie(j,f[j],CAN.Width,Length(f),clLime,CAN);
          ZeichneLinie(j+1,f[j+1],CAN.Width,Length(f),clLime,CAN);
        END;
      END;
      Bremse(verz);
    END;
END;

PROCEDURE SelectionSort(VAR f:tZahlenarray;CAN:TCanvas;verz:BYTE;VAR anz:CARDINAL;graphisch:BOOLEAN);
VAR i,j,iMax,Max,n:INTEGER;
BEGIN
  n:=Length(f);
  FOR i:= n-1 DOWNTO 1 DO BEGIN
    iMax:=i;
    Max:=f[i];
    FOR j:=0 TO i-2 DO
      IF f[j]>=Max THEN BEGIN
        iMax:=j;
        Max:=f[j];
      END; //if

    f[iMax]:=f[i];
    f[i]:=Max;
    Inc(anz);
    {IF graphisch THEN BEGIN
    ZeichneLinie(iMax,f[iMax],CAN.Width,Length(f),clRed,CAN);
    ZeichneLinie(i,f[i],CAN.Width,Length(f),clRed,CAN);
    END;}
    Bremse(verz);
    IF graphisch THEN BEGIN
    ZeichneLinie(iMax,f[iMax],CAN.Width,Length(f),clLime,CAN);
    ZeichneLinie(i,f[i],CAN.Width,Length(f),clLime,CAN);
    END;
  END;     //for i
END;

PROCEDURE InsertionSort(VAR f:tZahlenarray;CAN:TCanvas;verz:BYTE;VAR anz:CARDINAL;graphisch:BOOLEAN);
VAR i,j,merke,n:INTEGER;
BEGIN
  n:=Length(f);
  FOR i:=1 TO n-1 DO BEGIN
    merke:=f[i];
    j:=i;
    {IF graphisch THEN BEGIN
    ZeichneLinie(j,f[j],CAN.Width,Length(f),clRed,CAN);
    END;}
    WHILE (j>0) AND (f[j-1]>merke) DO BEGIN
      f[j]:=f[j-1];
      Inc(anz);
      Dec(j);
      Bremse(verz);
      IF graphisch THEN BEGIN
      ZeichneLinie(j,f[j],CAN.Width,Length(f),clLime,CAN);
      END;
    END;
    f[j]:=merke;
  END;
END;

PROCEDURE ShellSort(VAR f:tZahlenarray;CAN:TCanvas;verz:BYTE;VAR anz:CARDINAL;graphisch:BOOLEAN);
VAR i,j,merke,abstand,n:INTEGER;
    done:BOOLEAN;
BEGIN
  n:=Length(f);
  abstand:=n;
  WHILE abstand>1 DO BEGIN
    abstand:=abstand DIV 2;
    REPEAT
      done:=TRUE;
      FOR j:= 0 TO n-abstand DO BEGIN
        i:=j+abstand;
        Bremse(verz);
        IF f[j]>f[i] THEN BEGIN
          merke:=f[j];
          f[j]:=f[i];
          f[i]:=merke;
          Inc(anz);
          IF graphisch THEN BEGIN
          ZeichneLinie(j,f[j],CAN.Width,Length(f),clLime,CAN);
          ZeichneLinie(i,f[i],CAN.Width,Length(f),clLime,CAN);
          END;
          done:=FALSE;
        END;
      END;
    UNTIL done;
  END;
END;

PROCEDURE QuickSort(VAR f:tZahlenarray;l,r:WORD;CAN:TCanvas;verz:BYTE;VAR anz:CARDINAL;graphisch:BOOLEAN);
VAR i,j,merke,mitte:INTEGER;
BEGIN
  i:=l;
  j:=r;
  mitte:=f[(l+r) DIV 2];
  REPEAT
    WHILE f[i]<mitte DO Inc(i);
    WHILE mitte<f[j] DO Dec(j);
    IF i<=j THEN BEGIN
      Merke:=f[i];
      f[i]:=f[j];
      f[j]:=merke;
      Inc(anz);
      IF graphisch THEN BEGIN
          ZeichneLinie(j,f[j],CAN.Width,Length(f),clLime,CAN);
          ZeichneLinie(i,f[i],CAN.Width,Length(f),clLime,CAN);
          END;
      Inc(i);
      Dec(j);
    END;
    Bremse(verz);
  UNTIL i>j;
  IF l<j THEN QuickSort(f,l,j,CAN,verz,anz,graphisch);
  IF i<r THEN QuickSort(f,i,r,CAN,verz,anz,graphisch);
END;

PROCEDURE Merge(VAR A:tZahlenarray;p,q,r:WORD;CAN:TCanvas;verz:BYTE;VAR anz:CARDINAL;graphisch:BOOLEAN);
VAR B:tZahlenarray;
    i,j,boo:WORD;
BEGIN
  SetLength(B,r-p+1);
  i:=p;
  j:=q+1;
  boo:=0;
  WHILE (i<=q) AND (j<=r) DO
        IF A[i]<=A[j] THEN
          BEGIN
            B[boo]:=A[i];
            boo+=1;
            i+=1;
          end
          ELSE
          BEGIN
            B[boo]:=A[j];
            boo+=1;
            j+=1;
          end;
  WHILE i<=q DO BEGIN
            B[boo]:=A[i];
            boo+=1;
            i+=1;
          end;
  WHILE j<=r DO BEGIN
            B[boo]:=A[j];
            boo+=1;
            j+=1;
          end;

  FOR i:=0 TO r-p DO
    BEGIN
      A[p+i]:=B[i];
      Bremse(verz);
      Inc(anz);
      IF graphisch THEN BEGIN
          ZeichneLinie(p+i,A[p+i],CAN.Width,Length(A),clLime,CAN);
          END;
    end;
end;

PROCEDURE MergeSort(VAR f:tZahlenarray;l,r:WORD;CAN:TCanvas;verz:BYTE;VAR anz:CARDINAL;graphisch:BOOLEAN);
VAR mid:WORD;
BEGIN
  IF l<r THEN BEGIN
    mid:=(l+r) DIV 2;
    MergeSort(f,l,mid,CAN,verz,anz,graphisch);
    MergeSort(f,mid+1,r,CAN,verz,anz,graphisch);
    Merge(f,l,mid,r,CAN,verz,anz,graphisch);
  end;
end;

FUNCTION BinarySearchIndex(VAR f:tZahlenarray;ind_solved,ind_element:WORD;CAN:TCanvas;verz:BYTE; VAR anz:CARDINAL; graphisch:BOOLEAN):WORD;
VAR left,mid,right:INTEGER;
BEGIN
  left:=0;
  right:=ind_solved;

  while(left<=right) DO BEGIN
    mid:=(left+right) DIV 2;
    IF graphisch THEN BEGIN
      ZeichneLinie(mid,f[mid],CAN.Width,Length(f),clRed,CAN);
    END;
    if(f[mid]<=f[ind_element])
      then BEGIN left:=mid+1; END
      else right:=mid-1;
    Bremse(verz);
    IF graphisch THEN BEGIN
      ZeichneLinie(mid,f[mid],CAN.Width,Length(f),clLime,CAN);
    END;
  end;
  Result:=left;
end;

PROCEDURE BinaryInsertionSort(VAR f:tZahlenarray;CAN:TCanvas;verz:BYTE;VAR anz:CARDINAL;graphisch:BOOLEAN);
VAR i,j,merke,n,k:INTEGER;
BEGIN
  n:=Length(f);
  FOR i:=1 TO n-1 DO BEGIN
    merke:=f[i];
    j:=BinarySearchIndex(f,i-1,i,CAN,verz,anz,graphisch);
    FOR k:= i DOWNTO j+1 DO BEGIN
      f[k]:=f[k-1];
      Inc(anz);
      Application.ProcessMessages;
      ZeichneLinie(k,f[k],CAN.Width,Length(f),clLime,CAN);
      Application.ProcessMessages;
    end;
    f[j]:=merke;
    Application.ProcessMessages;
    ZeichneLinie(j,f[j],CAN.Width,Length(f),clLime,CAN);
  END;
END;

PROCEDURE AnzeigeListe(f:tZahlenarray;Liste:TListBox);
VAR i:WORD;
BEGIN
  Liste.Clear;
  FOR i:= 0 TO (Length(f)-1) DO Liste.Items.Append(IntToStr(f[i]));
end;

PROCEDURE GrafikVorbereiten;
BEGIN
  //graphische Veranschaulichung?
  IF Form1.CheckBoxVeranschaulichung.Checked
     THEN Form2.Visible:=TRUE
     ELSE Form2.Visible:=FALSE;
  IF (GVAnz<Screen.Height-200) THEN BEGIN Form2.Width:=GVAnz;
                                      Form2.Height:=GVAnz; END
                           ELSE BEGIN Form2.Width:=Screen.Height-250;
                                      Form2.Height:=Screen.Height-250 END;

  Form2.Left:=Form1.Left-Form2.Width;
  IF Form2.Left<74 THEN Form2.Left:=74;
  IF Screen.Height-174>Form2.Height+Form1.Top
     THEN Form2.Top:=Form1.Top
     ELSE Form2.Top:=Screen.Height-Form2.Height-174;
  Form2.Color:=clBlack;
END;

//===================================================================
//               zusammenfassende Hilfsroutinen
//-------------------------------------------------------------------



//===================================================================
//               Ereignisbehandlungsroutinen (EBR)
//-------------------------------------------------------------------

{ TForm1 }

procedure TForm1.ButtonEndeClick(Sender: TObject);
begin
  Form1.Close;
end;

PROCEDURE TForm1.ButtonGleichClick(Sender: TObject);
BEGIN
  //Grafik
  IF Form2.Visible THEN BEGIN
                          GrafikVorbereiten;
                          Application.ProcessMessages;
                          ZeigeFeld(feld,Form2.Canvas);
                        END;

  //Labels
  Form1.LabelZeit.Caption:='';
  Form1.LabelAnzahlZuweisungen.Caption:='';

  //Listbox
  Form1.ListBoxSortierteZahlen.Clear;

end;

procedure TForm1.ButtonErzeugenClick(Sender: TObject);
begin
  SetLength(feld,GVAnz);
  CASE Form1.RadioGroupVerteilung.ItemIndex OF
  0: ZufaelligeBelegung(feld);
  1: AbsteigendBelegen(feld);
  2: AlternierendBelegen1(feld);
  3: AlternierendBelegen2(feld);
  ELSE
  end;

  //in ListBox Startbelegung eintragen
  AnzeigeListe(feld,Form1.ListBoxStartbelegung);

  //Grafik
  GrafikVorbereiten;
  Application.ProcessMessages;
  IF Form2.Visible THEN ZeigeFeld(feld,Form2.Canvas);




end;

procedure TForm1.ButtonStartClick(Sender: TObject);
VAR sortiertesFeld:tZahlenarray;
    verzoegerung:BYTE;
    zeitanfang:Int64;
    anzahlanweisungen:CARDINAL;
    graphisch:BOOLEAN;
begin
  //Grafik
  IF Form2.Visible THEN BEGIN
                          GrafikVorbereiten;
                          Application.ProcessMessages;
                          ZeigeFeld(feld,Form2.Canvas);
                          graphisch:=TRUE;
                        END
                   ELSE graphisch:=FALSE;
  Form1.Color:=13684991;
  //Feld
  sortiertesFeld:=feld;
  SetLength(sortiertesFeld,GVAnz);

  //Verzögerung
  verzoegerung:=StrToInt(Form1.RadioGroupVerzoegerung.Items[Form1.RadioGroupVerzoegerung.ItemIndex]);

  //Anzahl
  anzahlanweisungen:=0;

  //Zeit
  zeitanfang:=GetTickCount64;
  Form1.LabelZeit.Caption:='';
  Form1.LabelAnzahlZuweisungen.Caption:='';

  CASE Form1.RadioGroupVerfahren.ItemIndex OF
  0: SystematischesTauschen(sortiertesFeld,Form2.Canvas,verzoegerung,anzahlanweisungen,graphisch);
  1: Bubblesort(sortiertesFeld,Form2.Canvas,verzoegerung,anzahlanweisungen,graphisch);
  2: SelectionSort(sortiertesFeld,Form2.Canvas,verzoegerung,anzahlanweisungen,graphisch);
  3: InsertionSort(sortiertesFeld,Form2.Canvas,verzoegerung,anzahlanweisungen,graphisch);
  4: ShellSort(sortiertesFeld,Form2.Canvas,verzoegerung,anzahlanweisungen,graphisch);
  5: QuickSort(sortiertesFeld,0,Length(sortiertesFeld)-1,Form2.Canvas,verzoegerung,anzahlanweisungen,graphisch);
  6: MergeSort(sortiertesFeld,0,Length(sortiertesFeld)-1,Form2.Canvas,verzoegerung,anzahlanweisungen,graphisch);
  7: BinaryInsertionSort(sortiertesFeld,Form2.Canvas,verzoegerung,anzahlanweisungen,graphisch);
  ELSE
  end;

  //Zeit
  Form1.LabelZeit.Caption:=FloatToStr((GetTickCount64-zeitanfang)/1000)+'s';

  //Anzahl Zuweisungen
  Form1.LabelAnzahlZuweisungen.Caption:=IntToStr(anzahlanweisungen);

  //Anzeige
  AnzeigeListe(sortiertesFeld,Form1.ListBoxSortierteZahlen);
  //Grafik
  GrafikVorbereiten;
  Application.ProcessMessages;
  IF Form2.Visible THEN ZeigeFeld(sortiertesFeld,Form2.Canvas);

  Form1.Color:=clCream;
end;

procedure TForm1.CheckBoxVeranschaulichungClick(Sender: TObject);
begin
  GrafikVorbereiten;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
  Form1.LabelZeit.Caption:='';
  Form1.LabelAnzahlZuweisungen.Caption:='';
  GVAnz:=StrToInt(Form1.RadioGroupAnzahl.Items[Form1.RadioGroupAnzahl.ItemIndex]);
  Form1.Left:=Screen.Width-50-Form1.Width;
  Form1.Top:=50;
end;

procedure TForm1.RadioGroupAnzahlClick(Sender: TObject);
begin
  GVAnz:=StrToInt(Form1.RadioGroupAnzahl.Items[Form1.RadioGroupAnzahl.ItemIndex]);
end;

end.

