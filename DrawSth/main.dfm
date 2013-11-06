object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'DrawSomething'
  ClientHeight = 517
  ClientWidth = 722
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
    Left = 24
    Top = 31
    Width = 52
    Height = 13
    Caption = 'IP Address'
  end
  object Label2: TLabel
    Left = 24
    Top = 110
    Width = 22
    Height = 13
    Caption = 'Key:'
  end
  object Label3: TLabel
    Left = 414
    Top = 95
    Width = 275
    Height = 33
    Caption = 'INFORMATIONS HERE!'
    Color = clRed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Image1: TImage
    Left = 24
    Top = 144
    Width = 673
    Height = 365
    OnMouseDown = Image1MouseDown
    OnMouseMove = Image1MouseMove
    OnMouseUp = Image1MouseUp
  end
  object Edit1: TEdit
    Left = 104
    Top = 28
    Width = 193
    Height = 21
    TabOrder = 0
  end
  object Button1: TButton
    Left = 328
    Top = 24
    Width = 113
    Height = 25
    Caption = 'Connect 2 Play!'
    TabOrder = 1
  end
  object Button2: TButton
    Left = 456
    Top = 24
    Width = 113
    Height = 25
    Caption = 'Disconnect'
    Enabled = False
    TabOrder = 2
  end
  object Button3: TButton
    Left = 585
    Top = 24
    Width = 112
    Height = 25
    Caption = 'About'
    TabOrder = 3
  end
  object Button4: TButton
    Left = 24
    Top = 55
    Width = 305
    Height = 34
    Caption = 'Draw!'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 392
    Top = 55
    Width = 305
    Height = 34
    Caption = 'Clear'
    Enabled = False
    TabOrder = 5
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 336
    Top = 56
    Width = 49
    Height = 33
    Caption = 'Save'
    Enabled = False
    TabOrder = 6
    OnClick = Button6Click
  end
  object Edit2: TEdit
    Left = 55
    Top = 107
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 7
  end
  object Button7: TButton
    Left = 328
    Top = 107
    Width = 80
    Height = 21
    Caption = 'SetColor'
    Enabled = False
    TabOrder = 8
    OnClick = Button7Click
  end
  object ComboBox1: TComboBox
    Left = 126
    Top = 107
    Width = 105
    Height = 21
    Enabled = False
    TabOrder = 9
    Text = '10'
    OnChange = ComboBox1Change
    Items.Strings = (
      '5'
      '6'
      '7'
      '8'
      '9'
      '10'
      '11'
      '12'
      '13'
      '14'
      '15'
      '16'
      '17'
      '18'
      '19'
      '20'
      '')
  end
  object RadioButton1: TRadioButton
    Left = 240
    Top = 104
    Width = 41
    Height = 25
    Caption = 'Pen'
    Checked = True
    Enabled = False
    TabOrder = 10
    TabStop = True
    OnClick = RadioButton1Click
  end
  object RadioButton2: TRadioButton
    Left = 288
    Top = 104
    Width = 41
    Height = 25
    Caption = 'Rub'
    Enabled = False
    TabOrder = 11
    OnClick = RadioButton2Click
  end
  object ColorDialog1: TColorDialog
    Left = 672
    Top = 96
  end
end
