# open_file
[![pub package](https://img.shields.io/pub/v/open_app_file.svg)](https://pub.dartlang.org/packages/open_app_file)

A plugin to open files the app has permission to access with default system-provided applications.

Supports Android, iOS, Web, Linux, macOS and Windows.

## Fork info

The library is forked from [open_file](https://github.com/crazecoder/open_file) by [crazecoder](https://github.com/crazecoder)

This version:
* does not include REQUEST_INSTALL_PACKAGES permission on Android, so cannot install .apk's
* does not include READ_EXTERNAL_STORAGE permission on Android, so is made for opening files located in the app working directory. It is still possible to request storage permission separately and then open the file with this library.
* has deprecated explicit list of MIME types, UTI's, and Linux launch options
* web implementation is changed (see below)

The main use case for the plugin is opening a generated or downloaded file with a default system application (see example).  

## Usage

Add [open_file](https://pub.dartlang.org/packages/open_app_file#-installing-tab-) as a dependency in your pubspec.yaml file.
```yaml
dependencies:
  open_app_file: ^lastVersion
```

## Example
```dart
import 'package:open_app_file/open_app_file.dart';

OpenAppFile.open('/sdcard/example.txt');

// You can provide overrides for MIME type (Android) and/or UTI (iOS). This is not necessary
// in most cases, but if you know that the file extension does not match its content, you can
// help the system to provide correct response to your request.
OpenAppFile.open('/sdcard/example.abc', mimeType: 'text/plain', uti: 'public.plain-text');
```

## Behavior on web

Direct local file access is generally discouraged on web, therefore we chose the approach that in 
most cases is the most logical web alternative: imitate user clicking on an element that targets the requested file.
For most files it will result in browser downloading the requested file immediately.
Some file types, like images, texts, or videos might be opened directly, so the library adds `target: _blank` attribute
to prevent user from leaving the application by accident.

The important limitation of this approach is that there's no way to check file type or availability 
beforehand, so on web the `open` call always succeeds.

Check the example app for general idea on how app-generated or remote files can be handled on web. 