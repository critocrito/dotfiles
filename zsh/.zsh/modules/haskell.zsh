###
# Functions
###

is_cabal() {
  local -r cabal_files=(*.cabal(N))
  local ret=1

  [[ ${#cabal_files} -gt 0 ]] && ret=0

  return ret
}

is_cabal_sandbox() {
  local ret=1

  [[ -f cabal.sandbox.config ]] && ret=0

  return ret
}

## Cabal autocompletion
# Taken from oh-my-zsh cabal plugin
_cabal_commands() {
  local ret=1 state
  _arguments ':subcommand:->subcommand' && ret=0
  case $state in
    subcommand)
      subcommands=(
        "bench:Run the benchmark, if any (configure with UserHooks)"
        "build:Compile all targets or specific target."
        "check:Check the package for common mistakes"
        "clean:Clean up after a build"
        "copy:Copy the files into the install locations"
        "configure:Prepare to build the package"
        "exec:Run a command with the cabal environment"
        "fetch:Downloads packages for later installation"
        "freeze:Freeze dependencies."
        "get:Gets a package's source code"
        "haddock:Generate Haddock HTML documentation"
        "help:Help about commands"
        "hscolour:Generate HsColour colourised code, in HTML format"
        "info:Display detailed information about a particular package"
        "init:Interactively create a .cabal file"
        "install:Installs a list of packages"
        "list:List packages matching a search string"
        "register:Register this package with the compiler"
        "repl:Open an interpreter session for the given target"
        "report:Upload build reports to a remote server"
        "run:Runs the compiled executable"
        "sandbox:Create/modify/delete a sandbox"
        "sdist:Generate a source distribution file (.tar.gz)"
        "test:Run the test suite, if any (configure with UserHooks)"
        "unpack:Unpacks packages for user inspection"
        "update:Updates list of known packages"
        "upload:Uploads source packages to Hackage"
      )
      _describe -t subcommands 'cabal subcommands' subcommands &&
      ret=0
  esac

  return ret
}

compdef _cabal_commands cabal
