{
  Copyright (C) 2018, 2022, Yasumasa Suenaga

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

unit DriveInfo;

interface

uses Winapi.Windows, System.SysUtils;

type

  TDiskGeometry = packed record
    Cylinders: Int64;
    MediaType: Integer;
    TracksPerCylinder: DWORD;
    SectorsPerTrack: DWORD;
    BytesPerSector: DWORD;
  end;

  TGetLengthInformation = record
    Length: LARGE_INTEGER;
  end;

  function GetDriveSize(DriveHandle: THandle): UInt64;
  function GetDriveSectorSize(DriveHandle: THandle): Integer;

implementation

function GetDiskGeometry(DriveHandle: THandle): TDiskGeometry;
var Ret: Boolean;
    BytesReturned: DWORD;
begin
  Ret := DeviceIoControl(DriveHandle, IOCTL_DISK_GET_DRIVE_GEOMETRY, nil, 0, @Result, SizeOf(TDiskGeometry), BytesReturned, nil);

  if not Ret then
    raise Exception.Create(SysErrorMessage(GetLastError));

end;

function GetDriveSize(DriveHandle: THandle): UInt64;
var info: TGetLengthInformation;
    Ret: Boolean;
    BytesReturned: DWORD;
begin
  Ret := DeviceIoControl(DriveHandle, IOCTL_DISK_GET_LENGTH_INFO, nil, 0, @info, SizeOf(info), BytesReturned, nil);
  if not Ret then
    raise Exception.Create(SysErrorMessage(GetLastError));

  Result := info.Length.QuadPart;
end;

function GetDriveSectorSize(DriveHandle: THandle): Integer;
var DiskGeom: TDiskGeometry;
begin
  DiskGeom := GetDiskGeometry(DriveHandle);
  Result := DiskGeom.BytesPerSector;
end;

end.
