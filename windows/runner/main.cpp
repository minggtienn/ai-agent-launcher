#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>
#include <shellapi.h>
#include <windows.h>

#include <string>

#include "flutter_window.h"
#include "utils.h"

auto bitsdojo_window =
    bitsdojo_window_configure(BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP);

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  std::wstring helper_exit_path;
  int argument_count = 0;
  wchar_t** arguments =
      ::CommandLineToArgvW(::GetCommandLineW(), &argument_count);
  if (arguments != nullptr) {
    const std::wstring prefix = L"--helper-exit=";
    for (int index = 1; index < argument_count; index++) {
      const std::wstring argument(arguments[index]);
      if (argument.rfind(prefix, 0) == 0) {
        helper_exit_path = argument.substr(prefix.size());
        break;
      }
    }
    ::LocalFree(arguments);
  }

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(440, 300);
  if (!window.Create(L"ai_agent_launcher", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  bool running = true;
  while (running) {
    while (::PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
      if (msg.message == WM_QUIT) {
        running = false;
        break;
      }
      ::TranslateMessage(&msg);
      ::DispatchMessage(&msg);
    }
    if (!running) {
      break;
    }
    if (!helper_exit_path.empty() &&
        ::GetFileAttributesW(helper_exit_path.c_str()) != INVALID_FILE_ATTRIBUTES) {
      break;
    }
    ::MsgWaitForMultipleObjects(0, nullptr, FALSE, 100, QS_ALLINPUT);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
