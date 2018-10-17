object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'RDM (Raw Disk Manipulator)'
  ClientHeight = 199
  ClientWidth = 449
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 39
    Height = 13
    Caption = #12467#12500#12540#20803
  end
  object Label2: TLabel
    Left = 8
    Top = 35
    Width = 39
    Height = 13
    Caption = #12467#12500#12540#20808
  end
  object Label3: TLabel
    Left = 128
    Top = 105
    Width = 87
    Height = 13
    Caption = #12496#12483#12501#12449#12469#12452#12474#65288'MB'#65289
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 176
    Width = 431
    Height = 17
    TabOrder = 6
    object ProgressLabel: TLabel
      Left = 0
      Top = 0
      Width = 431
      Height = 17
      Align = alClient
      Alignment = taCenter
      Layout = tlCenter
      ExplicitWidth = 3
      ExplicitHeight = 13
    end
  end
  object SrcEdit: TEdit
    Left = 53
    Top = 5
    Width = 386
    Height = 21
    TabOrder = 0
  end
  object DestEdit: TEdit
    Left = 53
    Top = 32
    Width = 386
    Height = 21
    TabOrder = 1
  end
  object CopySizeCheck: TCheckBox
    Left = 120
    Top = 73
    Width = 105
    Height = 17
    Caption = #12467#12500#12540#12469#12452#12474#65288'MB'#65289
    TabOrder = 2
  end
  object CopySizeEdit: TEdit
    Left = 231
    Top = 71
    Width = 82
    Height = 21
    Alignment = taRightJustify
    Enabled = False
    ImeMode = imDisable
    TabOrder = 3
    Text = '1024'
  end
  object BufferSizeEdit: TEdit
    Left = 231
    Top = 102
    Width = 82
    Height = 21
    Alignment = taRightJustify
    ImeMode = imDisable
    TabOrder = 4
    Text = '4'
  end
  object Button1: TButton
    Left = 190
    Top = 145
    Width = 75
    Height = 25
    Caption = #12473#12479#12540#12488
    TabOrder = 5
    OnClick = Button1Click
  end
  object BindingsList1: TBindingsList
    Methods = <>
    OutputConverters = <>
    Left = 28
    Top = 69
    object LinkControlToPropertyEnabled2: TLinkControlToProperty
      Category = #12463#12452#12483#12463' '#12496#12452#12531#12487#12451#12531#12464
      Control = CopySizeCheck
      Track = True
      Component = CopySizeEdit
      ComponentProperty = 'Enabled'
    end
  end
end
