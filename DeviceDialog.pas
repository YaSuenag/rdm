unit DeviceDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Grids, System.Win.Registry, DriveInfo;

type
  TDeviceSelector = class(TForm)
    OkButton: TButton;
    CancelButton: TButton;
    DeviceList: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
  private
    numDevice: Integer;
    FDeviceName: String;
    procedure ScanRegistry(Reg: TRegistry; Key, DevnamePrefix: String);
  public
    constructor Create(AOwner: TComponent); override;
    property DeviceName: String read FDeviceName;
  end;

var
  DeviceSelector: TDeviceSelector;

implementation

{$R *.dfm}

const REGKEY_BASE = '\SYSTEM\CurrentControlSet\Services';

constructor TDeviceSelector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDeviceName := '';
end;

procedure TDeviceSelector.ScanRegistry(Reg: TRegistry; Key, DevnamePrefix: String);
var Count, Cnt: Integer;
    RegVal: String;
    Hnd: THandle;
    Splitter: TStringList;
begin
  if Reg.OpenKeyReadOnly(Key) then
    begin
      Count := Reg.ReadInteger('Count');
      for Cnt := 0 to Count - 1 do
        begin
          RegVal := Reg.ReadString(IntToStr(Cnt));
          Hnd := CreateFile(PChar(DevnamePrefix + IntToStr(Cnt)), GENERIC_READ,
                            FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,
                            nil, OPEN_EXISTING, FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_TEMPORARY, FILE_FLAG_SEQUENTIAL_SCAN);
          if Hnd <> INVALID_HANDLE_VALUE then
            begin

              try
                // Disk read test
                GetDriveSize(Hnd);

                Splitter := TStringList.Create;
                Splitter.Delimiter := '&';
                Splitter.DelimitedText := RegVal;
                NumDevice := NumDevice + 1;
                DeviceList.RowCount := NumDevice;
                DeviceList.Cells[0, NumDevice - 1] := Splitter[2].Substring(5);
                DeviceList.Cells[1, NumDevice - 1] := DevnamePrefix + IntToStr(Cnt);
              except
                on DeviceError: Exception do
                  begin
                    // Do nothing
                  end;
              end;

              CloseHandle(Hnd);
            end;
        end;
    end;
end;

procedure TDeviceSelector.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TDeviceSelector.FormShow(Sender: TObject);
var Reg: System.Win.Registry.TRegistry;
begin
  NumDevice := 0;
  Reg := TRegistry.Create(KEY_READ);

  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    ScanRegistry(Reg, REGKEY_BASE + '\disk\Enum', '\\.\PhysicalDrive');
    ScanRegistry(Reg, REGKEY_BASE + '\cdrom\Enum', '\\.\CdRom');
  finally
    Reg.Free;
  end;

end;

procedure TDeviceSelector.OkButtonClick(Sender: TObject);
begin
  FDeviceName := DeviceList.Cells[1, DeviceList.Row];
  Close;
end;

end.
