program rdm;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  DriveInfo in 'DriveInfo.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
