# Third-Party Notices

This directory contains third-party source code and/or dependencies used by Pythia-Webview2 demos or by the Pythia-Webview2 development environment.

The presence of third-party code in this directory does not imply that the third-party project is maintained by the Pythia-Webview2 project.

## WebView4Delphi

**Project:** WebView4Delphi  
**Author / maintainer:** Salvador Díaz Fau  
**Repository:** https://github.com/salvadordf/WebView4Delphi  
**License:** MIT License  
**Copyright:** Copyright (c) 2026 Salvador Díaz Fau

WebView4Delphi is an open source project used to embed Microsoft Edge WebView2 / Chromium-based browser components in Delphi or Lazarus/FPC applications.

Pythia-Webview2 relies on WebView4Delphi for its WebView2 hosting layer.

### Bundled copy

The version of WebView4Delphi included in this `dependencies/` directory may not be the latest upstream version.

It is provided primarily to make the examples easier to compile and to improve the first-run experience for developers discovering Pythia-Webview2.

For production projects, it is recommended to clone or download WebView4Delphi directly from the official upstream repository, then add its source path to the Delphi project options.

### License notice

WebView4Delphi is distributed under the MIT License.

If this repository includes a copy or substantial portions of WebView4Delphi, the original copyright notice and MIT license text must be preserved.

A copy of the WebView4Delphi MIT License is included next to this file as `LICENSE`.

## Microsoft WebView2 Runtime

**Project:** Microsoft Edge WebView2 Runtime  
**Provider:** Microsoft  
**Documentation:** https://learn.microsoft.com/microsoft-edge/webview2/

Pythia-Webview2 and WebView4Delphi require the Microsoft Edge WebView2 Runtime on the target machine.

The WebView2 Runtime is not authored, maintained, or redistributed by Pythia-Webview2 unless explicitly stated elsewhere in the repository.

Users and integrators should refer to Microsoft's official documentation and redistribution terms for WebView2 Runtime deployment.

