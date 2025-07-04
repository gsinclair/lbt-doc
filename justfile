#
# justfile for lbt-documents project
#
# Whatever subdirectory you are in (like Curriculum, Enrichment, ...)
# you can run
#   just build      to build the PDF from the correct .tex file
#   just edit       to open neovim with the .tex file and all chapters
#

project := file_name(invocation_directory())

default:
  just -l

# Build _the_ Latex file in this project directory.
[no-cd]
build:
  ../etc/build.sh {{project}}

# Build a named file.
[no-cd]
build-specific filename:
  ../etc/build.sh {{filename}}

# Edit main file and all chapter files in nvim.
[no-cd]
edit:
  nvim {{project}}.tex chapters/*.tex

# Create/update file lbt-by-example-LATEST.pdf (for github release)
[no-cd]
latest:
  cp {{project}}.pdf ../{{project}}-LATEST.pdf
