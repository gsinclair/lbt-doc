# lbt-doc

This is a documentation project to support gsinclair/lbt.

It contains two parts:
* "LBT by Example", which is in active development;
* "LBT Manual", which is not yet started.

(Status above as at 31 May 2025.)

## Main file of interest

See <lbt-by-example-LATEST.pdf> for the latest good documentation.

## Build instructions

    cd lbt-by-example
    just build
    # open lbt-by-example.pdf

Note the following lines in lbt-by-example.tex:

      \lbtSettings{
        SettingsFile = .lbtSettings,
      }

If you put an `.lbtSettings` file at the project root, it will influence the build. Here is the settings file I use during active development.

    DraftMode = true, HaltOnWarning = true, LogChannels = all, DebugAllExpansions = true

DraftMode means only the LBT documents marked !DRAFT will be included, thus reducing compile times. HaltOnWarning means compilation stops if, for example, a nonexistent opcode is encountered. LogChannels and DebugAllExpansions give as much debugging info as possible. In particular, you can see the resuling Latex code in the `lbt-expansions` directory.

If you do not create an `.lbtSettings` file then the compilation will proceed with the default value of all settings.
