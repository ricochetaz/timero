unit uWinNotification;

interface

uses
  System.Notification;

procedure ShowNotification(const ATitle, ABody: string);

implementation

procedure ShowNotification(const ATitle, ABody: string);
var
  notification: TNotification;
  notificationCenter: TNotificationCenter;
begin
  notificationCenter := TNotificationCenter.Create(nil);
//  notificationCenter.OnReceiveLocalNotification := ReceiveLocalNotification;
  notification := notificationCenter.CreateNotification;
  try
    notification.Name := 'Pomodoro Notifyer';
    notification.Title := ATitle;
    notification.AlertBody := ABody;
    notificationCenter.PresentNotification(notification);
  finally
    notification.Free;
    notificationCenter.Free;
  end;
end;

end.
