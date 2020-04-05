object DeviceSelector: TDeviceSelector
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #12458#12531#12521#12452#12531#12487#12496#12452#12473#36984#25246
  ClientHeight = 264
  ClientWidth = 428
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  DesignSize = (
    428
    264)
  PixelsPerInch = 96
  TextHeight = 13
  object OkButton: TButton
    Left = 120
    Top = 232
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = OkButtonClick
  end
  object CancelButton: TButton
    Left = 248
    Top = 232
    Width = 75
    Height = 25
    Caption = #12461#12515#12531#12475#12523
    TabOrder = 2
    OnClick = CancelButtonClick
  end
  object DeviceList: TStringGrid
    Left = 8
    Top = 8
    Width = 412
    Height = 218
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 2
    DefaultColWidth = 200
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
    TabOrder = 0
  end
end
