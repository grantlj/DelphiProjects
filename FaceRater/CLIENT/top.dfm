object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = #32418#20154#27036
  ClientHeight = 400
  ClientWidth = 498
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 240
    Top = 25
    Width = 240
    Height = 320
    Proportional = True
    Stretch = True
  end
  object Button1: TButton
    Left = 8
    Top = 359
    Width = 472
    Height = 33
    Caption = #20851#38381
    TabOrder = 0
    OnClick = Button1Click
  end
  object ListBox1: TListBox
    Left = 8
    Top = 25
    Width = 209
    Height = 320
    ItemHeight = 13
    TabOrder = 1
    OnClick = ListBox1Click
  end
end
