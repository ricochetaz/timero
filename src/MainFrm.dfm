object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = #1058#1072#1081#1084#1077#1088' '#1055#1086#1084#1080#1076#1086#1088#1086
  ClientHeight = 190
  ClientWidth = 874
  Color = clBtnFace
  Constraints.MinHeight = 220
  Constraints.MinWidth = 590
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -21
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 30
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 874
    Height = 65
    Align = alTop
    TabOrder = 0
    DesignSize = (
      874
      65)
    object lblStatus: TLabel
      Left = 24
      Top = 24
      Width = 143
      Height = 30
      Caption = #1043#1086#1090#1086#1074' '#1082' '#1088#1072#1073#1086#1090#1077
    end
    object btnPause: TButton
      Left = 725
      Top = 16
      Width = 129
      Height = 43
      Anchors = [akTop, akRight]
      Caption = #1055#1072#1091#1079#1072
      TabOrder = 0
      OnClick = btnPauseClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 65
    Width = 874
    Height = 125
    Align = alClient
    TabOrder = 1
    DesignSize = (
      874
      125)
    object Label1: TLabel
      Left = 564
      Top = 16
      Width = 124
      Height = 30
      Anchors = [akTop, akRight]
      Caption = #1056#1072#1073#1086#1090#1072' ('#1084#1080#1085')'
      ExplicitLeft = 567
    end
    object Label2: TLabel
      Left = 564
      Top = 72
      Width = 118
      Height = 30
      Anchors = [akTop, akRight]
      Caption = #1054#1090#1076#1099#1093' ('#1084#1080#1085')'
      ExplicitLeft = 567
    end
    object pbTimer: TProgressBar
      AlignWithMargins = True
      Left = 24
      Top = 16
      Width = 448
      Height = 89
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object btnStart: TButton
      Left = 725
      Top = 16
      Width = 129
      Height = 33
      Anchors = [akTop, akRight]
      Caption = #1053#1072#1095#1072#1090#1100
      TabOrder = 1
      OnClick = btnStartClick
    end
    object btnStop: TButton
      Left = 725
      Top = 71
      Width = 129
      Height = 34
      Anchors = [akTop, akRight]
      Caption = #1057#1090#1086#1087
      TabOrder = 2
      OnClick = btnStopClick
    end
    object seWorkTime: TSpinEdit
      Left = 492
      Top = 13
      Width = 66
      Height = 40
      Anchors = [akTop, akRight]
      MaxValue = 120
      MinValue = 1
      TabOrder = 3
      Value = 25
    end
    object seBreakTime: TSpinEdit
      Left = 493
      Top = 64
      Width = 65
      Height = 40
      Anchors = [akTop, akRight]
      MaxValue = 30
      MinValue = 1
      TabOrder = 4
      Value = 5
    end
  end
  object tmrPomodoro: TTimer
    Enabled = False
    OnTimer = tmrPomodoroTimer
    Left = 496
    Top = 16
  end
  object TrayIcon1: TTrayIcon
    PopupMenu = PopupMenu1
    Visible = True
    OnDblClick = TrayIcon1DblClick
    Left = 584
    Top = 16
  end
  object PopupMenu1: TPopupMenu
    Left = 656
    Top = 16
    object miRestore: TMenuItem
      Caption = #1055#1086#1082#1072#1079#1072#1090#1100
      OnClick = miRestoreClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miStartPause: TMenuItem
      Caption = #1057#1090#1072#1088#1090
      OnClick = miStartPauseClick
    end
    object miStop: TMenuItem
      Caption = #1057#1090#1086#1087
      OnClick = miStopClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miExit: TMenuItem
      Caption = #1042#1099#1093#1086#1076
      OnClick = miExitClick
    end
  end
end
