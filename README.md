# MSYS2 auto install

Automates the installation of MSYS2.

# Features
- Automates the following:
  - Downloading MSYS2 from its official website
  - Installing MSYS2 under the current directory
    - Does not affect the registry or system environment variables
    - Works even if moved to any directory
  - Installing gcc and clang in MSYS2
  - Compiling and executing "hello world"
    - Works even in environments without MSYS2 (does not depend on DLLs)
  - Generating a mingw64 launch .bat file
    - Running this .bat file logs you into MSYS2 in mingw64 mode, allowing you to use gcc and clang
  - Outputting logs for all the above steps

- Easy to use as it doesn't pollute your environment.
- Simply running this command from the command prompt automatically completes everything. No complicated operations are required.
```
curl.exe -L https://raw.githubusercontent.com/cat2151/msys2-auto-install/main/MSYS2_get_and_install.bat --output MSYS2_get_and_install.bat && MSYS2_get_and_install.bat
```

# Requirement
- Windows
- Approximately 3GB of free disk space
- Approximately 7 to 30 minutes (varies depending on network speed)
- The full path where the .bat file is executed must not contain spaces or Japanese characters