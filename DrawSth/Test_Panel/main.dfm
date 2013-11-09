object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Test_Panel'
  ClientHeight = 492
  ClientWidth = 831
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 64
    Top = 79
    Width = 673
    Height = 365
    OnMouseDown = Image1MouseDown
    OnMouseMove = Image1MouseMove
    OnMouseUp = Image1MouseUp
  end
  object Button1: TButton
    Left = 80
    Top = 8
    Width = 249
    Height = 41
    Caption = 'Start Draw!'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 415
    Top = 8
    Width = 249
    Height = 34
    Caption = 'SAVE'
    TabOrder = 1
    OnClick = Button2Click
  end
  object RadioButton1: TRadioButton
    Left = 352
    Top = 16
    Width = 57
    Height = 17
    Caption = 'Pen'
    Checked = True
    TabOrder = 2
    TabStop = True
    OnClick = RadioButton1Click
  end
  object RadioButton2: TRadioButton
    Left = 352
    Top = 48
    Width = 57
    Height = 17
    Caption = 'Eraser'
    TabOrder = 3
    OnClick = RadioButton2Click
  end
  object ComboBox1: TComboBox
    Left = 96
    Top = 52
    Width = 145
    Height = 21
    TabOrder = 4
    Text = 'ComboBox1'
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
      '20')
  end
  object Button3: TButton
    Left = 415
    Top = 48
    Width = 249
    Height = 25
    Caption = 'Color'
    TabOrder = 5
    OnClick = Button3Click
  end
  object ColorDialog1: TColorDialog
    Left = 696
    Top = 24
  end
end
