{
  Copyright (C) 2018  Yasumasa Suenaga

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
}

unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Data.Bind.EngExt, Vcl.Bind.DBEngExt, System.Rtti, System.Bindings.Outputs,
  Vcl.Bind.Editors, Data.Bind.Components, System.UITypes, DriveInfo, DeviceDialog;

type

  TMainForm = class(TForm)
    Label1: TLabel;
    SrcEdit: TEdit;
    Label2: TLabel;
    DestEdit: TEdit;
    CopySizeCheck: TCheckBox;
    CopySizeEdit: TEdit;
    BufferSizeEdit: TEdit;
    Button1: TButton;
    ProgressBar1: TProgressBar;
    BindingsList1: TBindingsList;
    LinkControlToPropertyEnabled2: TLinkControlToProperty;
    Label3: TLabel;
    ProgressLabel: TLabel;
    DeviceDialogButton: TButton;
    OpenFileDialogButton: TButton;
    OpenDialog1: TOpenDialog;
    DeviceDialogButton2: TButton;
    SaveFileDialogButton: TButton;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CopyThreadTerminated(Sender: TObject);
    procedure DeviceDialogButtonClick(Sender: TObject);
    procedure OpenFileDialogButtonClick(Sender: TObject);
  private
    procedure SetupParameter;
  public
    { Public 宣言 }
  end;

  ESetupError = class(Exception)
    Caption: string;
  end;

  TCopyThread = class(TThread)
  protected
    procedure Execute; override;
  end;

var
  MainForm: TMainForm;
  [volatile] CopyThread: TCopyThread;

implementation

{$R *.dfm}

const MB = 1024 * 1024;

procedure TCopyThread.Execute;
var hSrc, hDest: THandle;
    BufferSize, NumOfReadBytes, NumOfWriteBytes: DWORD;
    Cnt, Max: Integer;
    Buf: Pointer;
    Ret: Boolean;
begin
  Buf := nil;
  hSrc := INVALID_HANDLE_VALUE;
  hDest := INVALID_HANDLE_VALUE;

  Synchronize(procedure
    begin
      MainForm.ProgressBar1.Min := 0;
      Max := StrToInt(MainForm.CopySizeEdit.Text) div StrToInt(MainForm.BufferSizeEdit.Text);
      MainForm.ProgressBar1.Max := Max + 1;
      MainForm.ProgressBar1.Position := 0;
      MainForm.ProgressBar1.Step := 1;
    end
  );

  try
    hSrc := CreateFile(PChar(MainForm.SrcEdit.Text), GENERIC_READ,
                       FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,
                       nil, OPEN_EXISTING, FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_TEMPORARY, FILE_FLAG_SEQUENTIAL_SCAN);
    if hSrc = INVALID_HANDLE_VALUE then
      begin
        MessageBox(MainForm.Handle, PChar(SysErrorMessage(GetLastError)), PChar(MainForm.SrcEdit.Text), MB_OK or MB_ICONERROR);
        Exit;
      end;

    hDest := CreateFile(PChar(MainForm.DestEdit.Text), GENERIC_WRITE,
                        FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,
                        nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, FILE_FLAG_SEQUENTIAL_SCAN);
    if hDest = INVALID_HANDLE_VALUE then
      begin
        MessageBox(MainForm.Handle, PChar(SysErrorMessage(GetLastError)), PChar(MainForm.DestEdit.Text), MB_OK or MB_ICONERROR);
        Exit;
      end;

    BufferSize := StrToInt(MainForm.BufferSizeEdit.Text) * MB;
    GetMem(Buf, BufferSize);

    for Cnt := 0 to Max do
      begin

        if Terminated then Exit;

        Ret := ReadFile(hSrc, Buf^, BufferSize, NumOfReadBytes, nil);
        if not Ret then
          begin
            MessageDlg(SysErrorMessage(GetLastError), mtError, [mbOK], 0);
            Exit;
          end
        else if NumOfReadBytes = 0 then
          begin
            break;
          end;


        Ret := WriteFile(hDest, Buf^, NumOfReadBytes, NumOfWriteBytes, nil);
        if not Ret then
          begin
            MessageDlg(SysErrorMessage(GetLastError), mtError, [mbOK], 0);
            Exit;
          end
        else if NumOfReadBytes <> NumOfWriteBytes then
          begin
            MessageDlg('書き込みサイズ不一致', mtError, [mbOK], 0);
            Exit;
          end;

        Synchronize(procedure
          begin
            MainForm.ProgressBar1.StepIt;
            MainForm.ProgressLabel.Caption := IntToStr(Trunc(Cnt / Max * 100.0)) + '%';
          end
        );
      end;

    MessageDlg('書き込み完了', mtInformation, [mbOK], 0);
  finally
    if hSrc <> INVALID_HANDLE_VALUE then CloseHandle(hSrc);
    if hDest <> INVALID_HANDLE_VALUE then CloseHandle(hDest);
    if Buf <> nil then FreeMem(Buf);
  end;

end;

procedure TMainForm.CopyThreadTerminated(Sender: TObject);
begin
  SrcEdit.Enabled := True;
  DestEdit.Enabled := True;
  CopySizeCheck.Enabled := True;
  CopySizeEdit.Enabled := MainForm.CopySizeCheck.Checked;
  BufferSizeEdit.Enabled := True;
  ProgressBar1.Position := 0;
  ProgressLabel.Caption := '';
  Button1.Caption := 'スタート';

  CopyThread := nil;
end;

procedure TMainForm.DeviceDialogButtonClick(Sender: TObject);
var Dlg: TDeviceSelector;
begin
  Dlg := TDeviceSelector.Create(Self);

  try
    Dlg.ShowModal;
    if Sender = DeviceDialogButton then
      begin
        SrcEdit.Text := Dlg.DeviceName;
      end
    else
      begin
        DestEdit.Text := Dlg.DeviceName;
      end;
  finally
    Dlg.Free;
  end;

end;

procedure TMainForm.Button1Click(Sender: TObject);
begin

  if CopyThread = nil then
    begin

      try
        SetupParameter;
      except
        on SetupError: ESetupError do
          begin
            MessageBox(Self.Handle, PChar(SetupError.Message), PChar(SetupError.Caption), MB_OK or MB_ICONERROR);
            Exit;
          end;
      end;

      SrcEdit.Enabled := False;
      DestEdit.Enabled := False;
      CopySizeCheck.Enabled := False;
      CopySizeEdit.Enabled := False;
      BufferSizeEdit.Enabled := False;
      Button1.Caption := 'キャンセル';

      CopyThread := TCopyThread.Create(True);
      CopyThread.OnTerminate := CopyThreadTerminated;
      CopyThread.FreeOnTerminate := True;
      CopyThread.Start;
    end
  else
    begin
      CopyThread.Terminate;
    end;

end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  CopyThread := nil;
end;

procedure TMainForm.OpenFileDialogButtonClick(Sender: TObject);
begin
  if Sender = OpenFileDialogButton then
    begin
      if OpenDialog1.Execute then
        begin
          SrcEdit.Text := OpenDialog1.FileName;
        end;
    end
  else
    begin
      if SaveDialog1.Execute then
        begin
          DestEdit.Text := SaveDialog1.FileName;
        end;
    end;
end;

procedure TMainForm.SetupParameter;
var SrcPath: string;
    hSrc: THandle;
    SectorSize: Integer;
    FileLength: Int64;
    Ret: Boolean;
    CopySize: UInt64;
    SetupError: ESetupError;
begin
  SrcPath := SrcEdit.Text;
  hSrc := INVALID_HANDLE_VALUE;

  try
    hSrc := CreateFile(PChar(SrcPath), GENERIC_READ,
                       FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,
                       nil, OPEN_EXISTING, FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_TEMPORARY, FILE_FLAG_RANDOM_ACCESS);

    if hSrc = INVALID_HANDLE_VALUE then
      begin
        SetupError := ESetupError.Create(SysErrorMessage(GetLastError));
        SetupError.Caption := SrcPath;
        raise SetupError;
      end;

    if SrcPath.StartsWith('\\.\') then
      begin

        SectorSize := GetDriveSectorSize(hSrc);
        if ((StrToInt(BufferSizeEdit.Text) * MB) mod SectorSize) <> 0 then
          begin
            SetupError := ESetupError.CreateFmt('バッファサイズがセクタサイズの倍数ではありません（セクタサイズ：%d bytes）', [SectorSize]);
            SetupError.Caption := 'バッファサイズエラー';
            raise SetupError;
          end;

        CopySize := (GetDriveSize(hSrc) div MB) + 1;
      end
    else
      begin
        Ret := GetFileSizeEx(hSrc, FileLength);
        if not Ret then
          begin
            SetupError := ESetupError.Create(SysErrorMessage(GetLastError));
            SetupError.Caption := SrcPath;
            raise SetupError;
          end;

        CopySize := (FileLength div MB) + 1;
      end;

    CopySizeEdit.Text := IntToStr(CopySize);
  finally
    if hSrc <> INVALID_HANDLE_VALUE then
      begin
        CloseHandle(hSrc);
      end;
  end;

end;

end.
