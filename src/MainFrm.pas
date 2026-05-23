unit MainFrm;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Menus,
  Vcl.Samples.Spin, Vcl.ComCtrls, Vcl.Forms, Vcl.Controls, System.Classes,
  System.IniFiles;

type
  // текущая фаза таймера
  TPomodoroMode = (pmWork, pmBreak);

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    pbTimer: TProgressBar;
    btnStart: TButton;
    btnStop: TButton;
    Label1: TLabel;
    Label2: TLabel;
    lblStatus: TLabel;
    seWorkTime: TSpinEdit;
    seBreakTime: TSpinEdit;
    tmrPomodoro: TTimer;
    btnPause: TButton;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    miRestore: TMenuItem;
    N1: TMenuItem;
    miStartPause: TMenuItem;
    miStop: TMenuItem;
    N2: TMenuItem;
    miExit: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure tmrPomodoroTimer(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure miRestoreClick(Sender: TObject);
    procedure miStartPauseClick(Sender: TObject);
    procedure miStopClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
  private
    { Private declarations }
    FMode: TPomodoroMode;        // Текущий режим (Работа/Отдых)
    FTotalSeconds: Integer;      // Всего секунд в текущей фазе
    FRemainingSeconds: Integer;  // Оставшихся секунд
    procedure UpdateUI;          // Процедура обновления интерфейса
    procedure AppMinimize(Sender: TObject);
    procedure UpdateTrayMenuCaption;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uWinNotification;

const
  SECTIONNAME     = 'Pomodoro';
  PAUSE_CAPTION   = 'Пауза';
  RESUME_CAPTION  = 'Продолжить';
  START_CAPTION   = 'Старт';
  READY_CAPTION   = 'Готов к работе';
  STOPPED_CAPTION = 'Остановлено';
  APPNAME_CAPTION = 'Помодоро: ';
  WORK_CAPTION    = ' - Работа';
  BREAK_CAPTION   = ' - Отдых';
  NOTIFY_TITLE    = 'Уведомление ';
  NOTIFY_MESSAGE  = 'Время работы истекло! Пора отдохнуть';
  CONFIG_NAME     = 'settings.ini';

  SETT_WORKTIME   = 'WorkTime';
  SETT_BREAKTIME  = 'BreakTime';
  SETT_FORMHEIGHT = 'FormHeight';
  SETT_FORMWIDTH  = 'FormWidth';
  SETT_FORMLEFT   = 'FormLeft';
  SETT_FORMTOP    = 'FormTop';

  SECONDS_IN_MINUTE = 60;

procedure TMainForm.btnPauseClick(Sender: TObject);
begin
  if tmrPomodoro.Enabled then
  begin
    // Ставим на паузу
    tmrPomodoro.Enabled := False;
    btnPause.Caption := RESUME_CAPTION;
  end
  else
  begin
    // Снимаем с паузы
    tmrPomodoro.Enabled := True;
    btnPause.Caption := PAUSE_CAPTION;
  end;
  UpdateTrayMenuCaption;
end;

procedure TMainForm.btnStartClick(Sender: TObject);
begin
  // Блокируем настройки и кнопку старта, разблокируем стоп
  seWorkTime.Enabled := False;
  seBreakTime.Enabled := False;
  btnStart.Enabled := False;
  btnStop.Enabled := True;
  btnPause.Enabled := True;
  btnPause.Caption := PAUSE_CAPTION;

  // Устанавливаем режим работы
  FMode := pmWork;
  FTotalSeconds := seWorkTime.Value * SECONDS_IN_MINUTE; // Переводим минуты в секунды
  FRemainingSeconds := FTotalSeconds;

  // Обновляем интерфейс и запускаем таймер
  UpdateUI;
  tmrPomodoro.Enabled := True;
  UpdateTrayMenuCaption;
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
  // Останавливаем таймер
  tmrPomodoro.Enabled := False;

  // Сбрасываем значения
  FRemainingSeconds := 0;
  pbTimer.Position := 0;
  lblStatus.Caption := STOPPED_CAPTION;

  // Разблокируем настройки и кнопку старта
  seWorkTime.Enabled := True;
  seBreakTime.Enabled := True;
  btnStart.Enabled := True;
  btnStop.Enabled := False;
  btnPause.Enabled := False;
  btnPause.Caption := PAUSE_CAPTION;
  UpdateTrayMenuCaption;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  IniFile: TIniFile;
  FilePath: string;
begin
  FilePath := ExtractFilePath(ParamStr(0)) + CONFIG_NAME;
  IniFile := TIniFile.Create(FilePath);
  try
    // Загружаем значения, если их нет - используются значения по умолчанию из компонента
    seWorkTime.Value := IniFile.ReadInteger(SECTIONNAME, SETT_WORKTIME, seWorkTime.Value);
    seBreakTime.Value := IniFile.ReadInteger(SECTIONNAME, SETT_BREAKTIME, seBreakTime.Value);
    Self.Height := IniFile.ReadInteger(SECTIONNAME, SETT_FORMHEIGHT, 220);
    Self.Width := IniFile.ReadInteger(SECTIONNAME, SETT_FORMWIDTH, 600);
    Self.Left := IniFile.ReadInteger(SECTIONNAME, SETT_FORMLEFT, 20);
    Self.Top := IniFile.ReadInteger(SECTIONNAME, SETT_FORMTOP, 20);
  finally
    IniFile.Free;
  end;

  FMode := pmWork;
  FTotalSeconds := 0;
  FRemainingSeconds := 0;

  lblStatus.Caption := READY_CAPTION;
  lblStatus.Font.Size := 16;
  lblStatus.Alignment := taCenter;

  pbTimer.Position := 0;

  btnStop.Enabled := False;
  btnPause.Enabled := False;
  btnPause.Caption := PAUSE_CAPTION;

  Application.OnMinimize := AppMinimize; // Перехватываем сворачивание
  TrayIcon1.Hint := APPNAME_CAPTION + READY_CAPTION;
  UpdateTrayMenuCaption;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  IniFile: TIniFile;
  FilePath: string;
begin
  // Путь к файлу настроек (рядом с исполняемым файлом)
  FilePath := ExtractFilePath(ParamStr(0)) + CONFIG_NAME;
  IniFile := TIniFile.Create(FilePath);
  try
    // Сохраняем текущие значения
    IniFile.WriteInteger(SECTIONNAME, SETT_WORKTIME, seWorkTime.Value);
    IniFile.WriteInteger(SECTIONNAME, SETT_BREAKTIME, seBreakTime.Value);
    IniFile.WriteInteger(SECTIONNAME, SETT_FORMHEIGHT, Self.Height);
    IniFile.WriteInteger(SECTIONNAME, SETT_FORMWIDTH, Self.Width);
    IniFile.WriteInteger(SECTIONNAME, SETT_FORMLEFT, Self.Left);
    IniFile.WriteInteger(SECTIONNAME, SETT_FORMTOP, Self.Top);
  finally
    IniFile.Free;
  end;
end;

procedure TMainForm.tmrPomodoroTimer(Sender: TObject);
begin
  // Уменьшаем оставшееся время на 1 секунду
  Dec(FRemainingSeconds);

  // Если время вышло
  if FRemainingSeconds < 0 then
  begin
    if FMode = pmWork then
    begin
      // Звуковой сигнал (опционально)
      // MessageBeep(MB_ICONEXCLAMATION);
      ShowNotification(NOTIFY_TITLE + DateTimeToStr(NOW), NOTIFY_MESSAGE);

      // Переключаемся на отдых
      FMode := pmBreak;
      FTotalSeconds := seBreakTime.Value * SECONDS_IN_MINUTE;
      FRemainingSeconds := FTotalSeconds;
    end
    else
    begin
      // Звуковой сигнал (опционально)
      MessageBeep(MB_ICONASTERISK);

      // Переключаемся на работу
      FMode := pmWork;
      FTotalSeconds := seWorkTime.Value * SECONDS_IN_MINUTE;
      FRemainingSeconds := FTotalSeconds;
    end;
  end;

  // Обновляем интерфейс
  UpdateUI;
end;

procedure TMainForm.UpdateUI;
var
  Minutes, Seconds: Integer;
  TimeStr: string;
  ProgressPercent: Integer;
begin
  // Вычисляем минуты и секунды
  Minutes := FRemainingSeconds div SECONDS_IN_MINUTE;
  Seconds := FRemainingSeconds mod SECONDS_IN_MINUTE;

  // Форматируем строку времени (например, 05:09)
  TimeStr := Format('%.2d:%.2d', [Minutes, Seconds]);

  // Обновляем текст в зависимости от режима
  case FMode of
    pmWork:  lblStatus.Caption := TimeStr + WORK_CAPTION;
    pmBreak: lblStatus.Caption := TimeStr + BREAK_CAPTION;
  end;
  TrayIcon1.Hint := APPNAME_CAPTION + lblStatus.Caption;

  // Вычисляем процент прогресса (шкала уменьшается по мере убывания времени)
  if FTotalSeconds > 0 then
    ProgressPercent := Round((FRemainingSeconds / FTotalSeconds) * 100)
  else
    ProgressPercent := 0;

  // Обновляем ProgressBar
  pbTimer.Position := ProgressPercent;
  Application.ProcessMessages;
end;

procedure TMainForm.AppMinimize(Sender: TObject);
begin
  // Скрываем форму вместо сворачивания в панель задач
  Hide();
end;

procedure TMainForm.UpdateTrayMenuCaption;
begin
  // Синхронизируем текст пункта меню с состоянием таймера
  if tmrPomodoro.Enabled then
    miStartPause.Caption := PAUSE_CAPTION
  else if btnStart.Enabled then
    miStartPause.Caption := START_CAPTION
  else
    miStartPause.Caption := RESUME_CAPTION;
end;

procedure TMainForm.TrayIcon1DblClick(Sender: TObject);
begin
  // Восстанавливаем окно по двойному клику на иконке в трее
  miRestoreClick(Sender);
end;

procedure TMainForm.miRestoreClick(Sender: TObject);
begin
  Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

procedure TMainForm.miStartPauseClick(Sender: TObject);
begin
  // Эмулируем нажатие кнопок на форме в зависимости от текущего состояния
  if not tmrPomodoro.Enabled then
  begin
    if btnStart.Enabled then
      btnStartClick(Sender)
    else
      btnPauseClick(Sender);
  end
  else
    btnPauseClick(Sender);

  UpdateTrayMenuCaption;
end;

procedure TMainForm.miStopClick(Sender: TObject);
begin
  if btnStop.Enabled then
    btnStopClick(Sender);
  UpdateTrayMenuCaption;
end;

procedure TMainForm.miExitClick(Sender: TObject);
begin
  Close;
end;

end.
