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

  TDiskGeometry = record
    Cylinders: Int64;
    MediaType: Integer;
    TracksPerCylinder: DWORD;
    SectorsPerTrack: DWORD;
    BytesPerSector: DWORD;
  end;

  TDiskGeometryEx = record
    Geometry: TDiskGeometry;
    DiskSize: LARGE_INTEGER;
    Data: array[0..0] of BYTE;
  end;

  TGetLengthInformation = record
    Length: LARGE_INTEGER;
  end;

  function GetDriveSize(DriveHandle: THandle): UInt64;
  function GetDriveSectorSize(DriveHandle: THandle): Integer;

implementation

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
var Ret: Boolean;
    BytesReturned: DWORD;
    Geom: TDiskGeometryEx;
begin
  Ret := DeviceIoControl(DriveHandle, IOCTL_DISK_GET_DRIVE_GEOMETRY_EX, nil, 0, @Geom, SizeOf(Geom), BytesReturned, nil);
  if not Ret then
    raise Exception.Create(SysErrorMessage(GetLastError));

  Result := Geom.Geometry.BytesPerSector;
end;

end.
