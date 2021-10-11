unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ToolWin, ComCtrls, Menus, ImgList,
  ExtDlgs;

type
  TfmMain = class(TForm)
    ScrollBox1: TScrollBox;
    Image1: TImage;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    tbEdit: TToolButton;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    ImageList1: TImageList;
    dlgOpen: TOpenPictureDialog;
    dlgSave: TSavePictureDialog;
    pmPoint: TPopupMenu;
    N5: TMenuItem;
    N6: TMenuItem;
    ToolButton2: TToolButton;
    procedure bStartClick(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N2Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    FNowDraw : Boolean;
    procedure LoadArray;
  public
    { Public declarations }
  end;

const
  GridSize = 64;

var
  fmMain: TfmMain;
  aR, aP : array[0..GridSize-1,0..GridSize-1] of byte;
  Ni: Integer = 0;
  Nk: Integer = 300;
  Xglob,Yglob : Integer;
  X,Y,X1,Y1 : Integer;
  
implementation

{$R *.dfm}

procedure TfmMain.bStartClick(Sender: TObject);
var
  i: Integer;
begin
  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.FillRect(rect(0,0,GridSize*5,GridSize*5));
  Image1.SetBounds(0,0,GridSize*5,GridSize*5);
  Image1.Canvas.Pen.Color := clLtGray;
  for i := 1 to GridSize do
    begin
      Image1.Canvas.MoveTo(i*5,0);
      Image1.Canvas.LineTo(i*5,GridSize*5);
      Image1.Canvas.MoveTo(0,i*5);
      Image1.Canvas.LineTo(GridSize*5,i*5);
    end;
  Ni := 0;
  Nk := 300;
end;

procedure TfmMain.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if tbEdit.Down then
   case Button of
     mbLeft:
           begin
             FNowDraw := True;
             Image1.Canvas.Brush.Color := clBlack;
           end;
     mbRight:
       begin
         Xglob := X;
         Yglob := Y;
         FNowDraw := False;
         pmPoint.Popup(Image1.ClientToScreen(point(x,y)).X,
                       Image1.ClientToScreen(point(x,y)).Y);
       end;
    end;
end;

procedure TfmMain.N2Click(Sender: TObject);
begin
  if dlgOpen.Execute
    then
      begin
        Ni := 0;
        Nk := 300;
        Image1.Picture.LoadFromFile(dlgOpen.FileName);
        Image1.Height := Image1.Picture.Height;
        Image1.Width  := Image1.Picture.Width;
        LoadArray;
      end;
end;

procedure TfmMain.N4Click(Sender: TObject);
begin
  if dlgSave.Execute then
    Image1.Picture.SaveToFile(dlgSave.FileName);
end;

procedure TfmMain.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FNowDraw := false;
end;

procedure TfmMain.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if FNowDraw then
    Image1.Canvas.FillRect(rect((X div 5) *5+1,(y div 5) *5+1,(X div 5) *5+5,(y div 5) *5+5));
end;

procedure TfmMain.N5Click(Sender: TObject);
begin
  Image1.Canvas.Brush.Color := clRed;
  Image1.Canvas.FillRect(rect((Xglob div 5) *5+1,(Yglob div 5) *5+1,(Xglob div 5) *5+5,(Yglob div 5) *5+5));
end;

procedure TfmMain.N6Click(Sender: TObject);
begin
  Image1.Canvas.Brush.Color := clGreen;
  Image1.Canvas.FillRect(rect((Xglob div 5) *5+1,(Yglob div 5) *5+1,(Xglob div 5) *5+5,(Yglob div 5) *5+5));
end;

procedure TfmMain.ToolButton2Click(Sender: TObject);
var
  i, j : Integer;
  min : Byte;
  ni: byte;
begin
  LoadArray;
  for Ni := 0 to 253 do
  for i := 0 to GridSize-1 do
    for j := 0 to GridSize-1 do
      begin
        if aP[i,j] = Ni then
          begin
            case aP[i+1,j] of
              253: break;
              254: aP[i+1,j] := Ni+1;
            end;
            case aP[i-1,j] of
              253: break;
              254: aP[i-1,j] := Ni+1;
            end;
            case aP[i,j+1] of
              253: break;
              254: aP[i,j+1] := Ni+1;
            end;
            case aP[i,j-1] of
              253: break;
              254: aP[i,j-1] := Ni+1;
            end;
          end;
      end;
  Image1.Canvas.Brush.Color := clBlue;
  while aP[x1,y1] <> 0 do
    begin
      Application.ProcessMessages;
      min := aP[x+1,y];
      if aP[x-1,y] < min then min := aP[x-1,y];
      if aP[x,y-1] < min then min := aP[x,y-1];
      if aP[x,y+1] < min then min := aP[x,y+1];
      if min = aP[x,y-1] then begin x1:=x; y1:=y-1;  end;
      if min = aP[x,y+1] then begin x1:=x; y1:=y+1;  end;
      if min = aP[x+1,y] then begin x1:=x+1; y1:=y;  end;

      if min = aP[x-1,y] then begin x1:=x-1; y1:=y;  end;
      x := x1;
      y := y1;
      Image1.Canvas.FillRect(rect(X  *5+1,Y  *5+1,X *5+5,Y  *5+5));
      Image1.Update;
    end;
end;

procedure TfmMain.LoadArray;
var
  i, j: integer;
begin
  for i :=0 to GridSize-1 do
    for j :=0 to GridSize-1 do
      begin
        case Image1.Canvas.Pixels[i*5+1,j*5+1] of
          clBlack : aP[i][j] := 255; //непроходимо
          clWhite : aP[i][j] := 254; //проходимо
          clRed   :
            begin
              aP[i][j] := 253; //старт
              X := i;
              Y := j;
            end;
          clGreen : aP[i][j] := 0;   //финиш
        end;
      end;
end;

procedure TfmMain.N3Click(Sender: TObject);
begin
 Close;
end;

end.
