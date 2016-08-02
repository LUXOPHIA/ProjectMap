unit Main;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors,
  FMX.Types3D, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Controls3D, FMX.Objects3D, FMX.Viewport3D, FMX.TabControl,
  LUX, LUX.FMX,
  LIB.Material;

type
  TForm1 = class(TForm)
    TabControl1: TTabControl;
      TabItemR: TTabItem;
        Viewport3D1: TViewport3D;
          Light1: TLight;
          Dummy1: TDummy;
            Dummy2: TDummy;
              Camera1: TCamera;
          Camera2: TCamera;
          Grid3D1: TGrid3D;
            Plane1: TPlane;
          Grid3D2: TGrid3D;
            Plane2: TPlane;
          Sphere1: TSphere;
    TabItemS: TTabItem;
      TabControlS: TTabControl;
        TabItemSV: TTabItem;
          MemoV: TMemo;
        TabItemSP: TTabItem;
          MemoP: TMemo;
    Panel1: TPanel;
    ScrollBar1: TScrollBar;
    procedure FormCreate(Sender: TObject);
    procedure Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ScrollBar1Change(Sender: TObject);
  private
    { private 宣言 }
    Viewport3D2 :TLuxViewport3D;
    _MouseS     :TShiftState;
    _MouseP     :TPointF;
    _MouseA     :TPointF;
  public
    { public 宣言 }
    _Material :TMyMaterialSource;
  end;

var
  Form1: TForm1;

implementation //############################################################### ■

uses System.Math;

{$R *.fmx}

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     Viewport3D2 := TLuxViewport3D.Create( Self );

     with Viewport3D2 do
     begin
          Parent      := Panel1;

          Camera      := Camera2;

          Width       := 300;
          Height      := 300;
          Position.X  := 10;
          Position.Y  := 10;

          Color       := TAlphaColors.Dimgray;

          OnMouseDown := Viewport3D2MouseDown;
          OnMouseMove :=Viewport3D2MouseMove;
          OnMouseUp   := Viewport3D2MouseUp  ;
     end;

     _MouseS := [];
     _MouseP := TPointF.Zero;
     _MouseA := TPointF.Zero;

     _Material := TMyMaterialSource.Create( Self );

     with _Material do
     begin
          ShaderV.Source.Text := MemoV.Text;
          ShaderP.Source.Text := MemoP.Text;

          EmisLight  := TAlphaColorF.Create( 0, 0, 0 );
          AmbiLight  := TAlphaColorF.Create( 0, 0, 0 );
          DiffRatio  := TAlphaColorF.Create( 1, 1, 1 );
          SpecRatio  := TAlphaColorF.Create( 1, 1, 1 );
          SpecShiny  := 50;
          ProjImage  .  LoadFromFile( '..\..\_DATA\Lena_512.png' );
          ProjMatrix := Camera2.AbsoluteMatrix;
          ProjAngleW := DegToRad( ScrollBar1.Value );
          ProjAngleH := DegToRad( ScrollBar1.Value );
     end;

     Plane1 .MaterialSource := _Material;
     Plane2 .MaterialSource := _Material;
     Sphere1.MaterialSource := _Material;

     Viewport3D2.RebuildRenderingList;
end;

//------------------------------------------------------------------------------

procedure TForm1.Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     _MouseS := Shift;
     _MouseP := TPointF.Create( X, Y );
end;

procedure TForm1.Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
   P :TPointF;
begin
     if ssLeft in _MouseS then
     begin
          P := TPointF.Create( X, Y );

          with Dummy1.RotationAngle do Y := Y + ( P.X - _MouseP.X ) / 2;
          with Dummy2.RotationAngle do X := X - ( P.Y - _MouseP.Y ) / 2;

          _MouseP := P;
     end;
end;

procedure TForm1.Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     Viewport3D1MouseMove( Sender, Shift, X, Y );

     _MouseS := [];
end;

//------------------------------------------------------------------------------

procedure TForm1.Viewport3D2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     _MouseS := Shift;
     _MouseP := TPointF.Create( X, Y );
end;

procedure TForm1.Viewport3D2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
   P :TPointF;
begin
     if ssLeft in _MouseS then
     begin
          P := TPointF.Create( X, Y );

          _MouseA := _MouseA + ( P - _MouseP );

          Camera2.LocalMatrix := TMatrix3D.CreateRotationX( +DegToRad( _MouseA.Y / 4 ) )
                               * TMatrix3D.CreateRotationY( -DegToRad( _MouseA.X / 4 ) )
                               * TMatrix3D.CreateTranslation( TPoint3D.Create( 0, 0, -10 ) );

          _Material.ProjMatrix := Camera2.AbsoluteMatrix;

          Viewport3D2.Repaint;

          _MouseP := P;
     end;
end;

procedure TForm1.Viewport3D2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     Viewport3D2MouseMove( Sender, Shift, X, Y );

     _MouseS := [];
end;

//------------------------------------------------------------------------------

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
     with _Material do
     begin
          ProjAngleW := DegToRad( ScrollBar1.Value );
          ProjAngleH := DegToRad( ScrollBar1.Value );
     end;

     Viewport3D1.Repaint;
     Viewport3D2.Repaint;
end;

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

     //GlobalUseDX := False;

end. //######################################################################### ■
