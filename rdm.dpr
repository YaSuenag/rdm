program rdm;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  DriveInfo in 'DriveInfo.pas',
  DeviceDialog in 'DeviceDialog.pas' {DeviceSelector};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDeviceSelector, DeviceSelector);
  Application.Run;
end.
