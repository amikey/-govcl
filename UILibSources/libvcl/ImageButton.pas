///=======================================================
/// 功能：图像状态按钮
///
/// 注： 一般使推荐使用png图片，当然jpg、bmp也是可以的，控件暂时只支持windows。
///      一张png图的排序为 Normal, Hover, Down, Disabled，其中
///      Disabled状态可忽略
///
///=======================================================

unit ImageButton;

// GDI+
{$DEFINE UseGDIPlus}

interface

uses
{$IFDEF UseGDIPlus}
  Winapi.Windows,
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ,
{$ENDIF}
  Winapi.Messages,
  System.Classes,
  System.Sysutils,
  System.Types,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Forms;

type

  TImageButton = class(TGraphicControl)
  private type
    TButtonState = (bsNormal, bsHover, bsDown, bsDisabled);
  private
    FState: TButtonState;
    FPicture: TPicture;
    FImageCount: Integer;
    FCaption: string;
    FShowCaption: Boolean;
    FFont: TFont;
    FWordwarp: Boolean;
    FModalResult: TModalResult;
    FMouseLeave: Boolean;
    FImgWidth: Integer;
    FImgHeight: Integer;
  {$IFDEF UseGDIPlus}
    FGPBitmap: TGPImage;
  {$ENDIF}
    procedure SetPicture(const Value: TPicture);
    procedure OnPictureChanged(Sender: TObject);
    procedure OnFontChanged(Sender: TObject);
    procedure SetImageCount(const Value: Integer);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure SetCaption(const Value: string);
    procedure SetShowCaption(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure SetWordwarp(const Value: Boolean);
  {$IFDEF UseGDIPlus}
    procedure AssGPBitmap;
  {$ENDIF}
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
    procedure SetEnabled(Value: Boolean); override;
    function  CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Paint; override;
    procedure ResetSize;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
  published
    property Action;
    property Align;
    property Anchors;
    property AutoSize;
    property Constraints;
    property Caption: string read FCaption write SetCaption;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font: TFont read FFont write SetFont;
    property ImageCount: Integer read FImageCount write SetImageCount default 3;
    property ModalResult: TModalResult read FModalResult write FModalResult default 0;
    property ParentShowHint;
    property ParentFont;
    property Picture: TPicture read FPicture write SetPicture;
    property PopupMenu;
    property ShowHint;
    property ShowCaption: Boolean read FShowCaption write SetShowCaption;
    property Touch;
    property Visible;
    property Wordwarp: Boolean read FWordwarp write SetWordwarp;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  Vcl.Consts;


{ TImageButton }

constructor TImageButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF UseGDIPlus}
  FGPBitmap := TGPImage.Create;
{$ENDIF}
  FPicture := TPicture.Create;
  FPicture.OnChange := OnPictureChanged;
  FFont := TFont.Create;
  FFont.OnChange := OnFontChanged;
  FState := bsNormal;
  FImageCount := 3;
  Width := 80;
  Height := 25;
  FShowCaption := False;
  FCaption := '';
  FModalResult := mrNone;
end;

destructor TImageButton.Destroy;
begin
  FFont.Free;
  FPicture.Free;
{$IFDEF UseGDIPlus}
  FGPBitmap.Free;
{$ENDIF}
  inherited;
end;

{$IFDEF UseGDIPlus}
procedure TImageButton.AssGPBitmap;
var
  Adapter: TStreamAdapter;
  Mem: TMemoryStream;
begin
  if Picture.Graphic <> nil then
  begin
    if FGPBitmap <> nil then
    begin
      FGPBitmap.Free;
      Mem := TMemoryStream.Create;
      try
        Picture.Graphic.SaveToStream(Mem);
        Mem.Position := 0;
        Adapter := TStreamAdapter.Create(Mem);
        FGPBitmap := TGPImage.Create(Adapter);
      finally
        Mem.Free;
      end;
    end;
  end;
end;
{$ENDIF}

procedure TImageButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  FMouseLeave := False;
  if csDesigning in ComponentState then Exit;
  if not Enabled then Exit;
  FState := bsDown;
  Invalidate;
end;

procedure TImageButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
 // inherited;
  if csDesigning in ComponentState then Exit;
  if not Enabled then Exit;
  if FState = bsDown then Exit;
  if FState <> bsHover then
  begin
    FState := bsHover;
    Invalidate;
  end;
end;

procedure TImageButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if csDesigning in ComponentState then Exit;
  if not Enabled then Exit;
  if not FMouseLeave then
    FState := bsHover
  else FState := bsNormal;
  Invalidate;
end;

procedure TImageButton.OnFontChanged(Sender: TObject);
begin
  inherited Canvas.Font.Assign(Font);
  Invalidate;
end;

procedure TImageButton.OnPictureChanged(Sender: TObject);
begin
  if Picture.Graphic <> nil then
  begin
    FImgWidth := FPicture.Width div FImageCount;
    FImgHeight := FPicture.Height;
  end;
  if AutoSize and (Picture.Width > 0) and (Picture.Height > 0) then
  begin
    ResetSize;
    SetEnabled(True);
  end;
{$IFDEF UseGDIPlus}
  AssGPBitmap;
{$ENDIF}
  Invalidate;
end;

function TImageButton.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := True;
  if (FPicture.Graphic <> nil) and ((FPicture.Width > 0) and (FPicture.Height > 0)) then
  begin
    if Align in [alNone, alLeft, alRight] then
      NewWidth := FImgWidth;
    if Align in [alNone, alTop, alBottom] then
      NewHeight := FImgHeight;
  end;
end;

procedure TImageButton.Click;
var
  Form: TCustomForm;
begin
  Form := GetParentForm(Self);
  if Form <> nil then Form.ModalResult := ModalResult;
  inherited Click;
end;

procedure TImageButton.Paint;
{$IFDEF UseGDIPlus}
const
  ColorMatrix2: TColorMatrix = (
    (0.229, 0.229, 0.229, 0.0, 0.0),
    (0.587, 0.587, 0.587, 0.0, 0.0),
    (0.144, 0.144, 0.144, 0.0, 0.0),
    (0.0,  0.0,  0.0,  0.5, 0.0),
    (0.0,  0.0,  0.0,  0.0, 1.0));

var
  GP: TGPGraphics;
{$ENDIF}

  procedure DrawText;
  var
    LR: TRect;
  begin
    if FShowCaption then
    begin
      LR := ClientRect;
      inherited Canvas.Brush.Style := bsClear;
      if FWordwarp then
        Canvas.TextRect(LR, FCaption, [tfCenter, tfVerticalCenter, tfWordBreak])
      else
        Canvas.TextRect(LR, FCaption, [tfCenter, tfSingleLine, tfVerticalCenter]);
    end;
  end;

  procedure PngBrushCopy(const Dest, Source: TRect);
  {$IFDEF UseGDIPlus}
  var
    R:TGPRectF;
    LImageAttributes: TGPImageAttributes;
  begin
    R.X := 0;
    R.Y := 0;
    R.Width := Dest.Width;
    R.Height := Dest.Height;
    if FState = bsDisabled then
    begin
      LImageAttributes := TGPImageAttributes.Create;
      try
        LImageAttributes.SetColorMatrix(ColorMatrix2);
        GP.DrawImage(FGPBitmap, R, Source.Left, Source.Top, Source.Width, Source.Height, UnitPixel, LImageAttributes);
      finally
        LImageAttributes.Free;
      end;
    end
    else
      GP.DrawImage(FGPBitmap, R, Source.Left, Source.Top, Source.Width, Source.Height, UnitPixel);
  end;
  {$ELSE}
  begin
    Canvas.Draw(-Source.Left, Dest.Top , FPicture.Graphic);
  end;
  {$ENDIF}

var
  R: TRect;
//  LNewWidth, LNewHeight: Integer;
begin
  inherited Paint;


  if csDesigning in ComponentState then
  begin
    with inherited Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;
  end else
  if not Visible then
    Exit;

  if FPicture.Graphic = nil then
  begin
    DrawText;
    Exit;
  end;
  R := ClientRect;
//  LNewWidth := Width;
//  LNewHeight := Height;
  if (FImgWidth = 0) or (FImgHeight = 0) then
    Exit;
{$IFDEF UseGDIPlus}
  GP := TGPGraphics.Create(Canvas.Handle);
{$ENDIF}
  case FState of
    bsNormal :
       PngBrushCopy(R, TRect.Create(Point(0, 0), FImgWidth, FImgHeight));
    bsHover :
      begin
        if FImageCount < 2 then
          PngBrushCopy(R, TRect.Create(Point(0, 0), FImgWidth, FImgHeight))
        else
          PngBrushCopy(R, Rect(FImgWidth, 0, FImgWidth * 2, FImgHeight))
      end;
    bsDown :
      begin
        if FImageCount < 3 then
          PngBrushCopy(R, TRect.Create(Point(0, 0), FImgWidth, FImgHeight))
        else
          PngBrushCopy(R, Rect(FImgWidth * 2, 0, FImgWidth * 3, FImgHeight));
      end;
    bsDisabled :
      begin
        if FImageCount = 4 then
          PngBrushCopy(R, Rect(FImgWidth * 3, 0, FImgWidth * 4, FImgHeight))
        else  if FImageCount > 0 then
          PngBrushCopy(R, TRect.Create(Point(0, 0), FImgWidth, FImgHeight))
      end;
  end;
{$IFDEF UseGDIPlus}
  GP.Free;
{$ENDIF}
  DrawText;
end;

procedure TImageButton.ResetSize;
begin
  if (FPicture.Graphic <> nil) and ((FPicture.Width > 0) and (FPicture.Height > 0)) then
  begin
    if Align in [alNone, alLeft, alRight] then
      Width := FImgWidth;
    if Align in [alNone, alTop, alBottom] then
      Height := FImgHeight;
  end;
end;

procedure TImageButton.Resize;
begin
  inherited;
  Invalidate;
end;


procedure TImageButton.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    if FShowCaption then
      Invalidate;
  end;
end;

procedure TImageButton.SetEnabled(Value: Boolean);
begin
  inherited SetEnabled(Value);
  if not Value then
    FState := bsDisabled
  else FState := bsNormal;
  Invalidate;
end;

procedure TImageButton.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TImageButton.SetImageCount(const Value: Integer);
begin
  if FImageCount <> Value then
  begin
    FImageCount := Value;
    if FImageCount <= 0 then
      FImageCount := 1;
    if FImageCount > 4 then
      FImageCount := 4;
    ResetSize;
    Invalidate;
  end;
end;

procedure TImageButton.SetPicture(const Value: TPicture);
begin
  FPicture.Assign(Value);
end;

procedure TImageButton.SetShowCaption(const Value: Boolean);
begin
  if FShowCaption <> Value then
  begin
    FShowCaption := Value;
    Invalidate;
  end;
end;

procedure TImageButton.SetWordwarp(const Value: Boolean);
begin
  if FWordwarp <> Value then
  begin
    FWordwarp := Value;
    if FShowCaption then
      Invalidate;
  end;
end;

procedure TImageButton.CMMouseEnter(var Message: TMessage);
begin
  FMouseLeave := False;
  if csDesigning in ComponentState then Exit;
  if not Enabled then Exit;
  FState := bsHover;
  Invalidate;
end;

procedure TImageButton.CMMouseLeave(var Message: TMessage);
begin
  FMouseLeave := True;
  if csDesigning in ComponentState then Exit;
  if not Enabled then Exit;
  FState := bsNormal;
  Invalidate;
end;

end.