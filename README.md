# Dotfiles

This is a collection of config files for different (mainly command-line) tools,
together with a utility for managing the sharing of configuration across
different computers.

## Motivation

I find myself managing different computers: my computer at work, my computer at
home, different servers. On all of them I use a number of same tools: zsh, vim,
i3, etc. However, although the configuration is mostly the same on all of the
machines, there are always specific settings for each computer, e.g.

* I want different prompt colors for different machines.
* My `PATH` is adapted to the different machines.
* My i3 status bar (actually polybar) at work monitors my work email and calendar, but at home I want it to monitor my private email.
* Et cetera, et cetera...

Of course you can build some conditional blocks to accomplish this, something
in the form of
```bash
if [[ $HOST == blablub ]]; then
    export PS1="fancyColor"
    export PATH=/path/to/machine/specific/tools:$PATH
fi
```
but this is ugly and not possible with all config files, which can lead to
synchronization problems.

## cfg

The [cfg tool](cfg) is my attempt to solve this problem. It is basically a
wrapper around git, but before adding files to the repository, it scans them
for a magic string (`-= LOCAL-CONFIG =-`) that you cleverly inserted
beforehand.

```bash
$ cfg add .zshrc
```
Everything *before* the line containing the magic string gets added
to a git repository located in `$HOME/.dotfiles/common/`. Everything *after*
the magic string (including the magic line itself) is copied to
`$HOME/.dotfiles/local/` (not version controlled). The `common` repository can
be uploaded to you favorite git hosting (you are looking at my `common`
directory right now) to synchronize between the machines. The machine-dependent
configuration is stored in the `local` directory.

Let's be a bit more specific. You can have a look at [my .zshrc file](.zshrc).
Buried at some point in there is a line
```bash
PROMPT="$(print '\n'$promptBeginColor'[%j] '$promptMachine':%'$pwdSize'<...<%~%<<\n%(!.#.$)'$promptEndColor) "
```
No need to go into details of what this accomplishes, but the important bit is
the `$promptBeginColor` variable in there. This variable is defined a couple of
lines before with my preferred (default) color, but nothing prevents us from
redefining it later. The last part of my `.zshrc` file on another machine looks
like this:
```bash
[...]

# -= LOCAL-CONFIG =-
promptBeginColor='%{\e[0;37m%}'
export PATH=$HOME/toolbox/bin:$PATH
```
so that I get my custom prompt color and custom `PATH`. (Incidentally: you can
also overwrite `$promptMachine` in case your hostname is some kind of serial
number.)

Synchronization across machines happens through normal git merge mechanisms.
`cfg` supports the `retrieve` command for merging the `common` and `local`
parts.
```bash
cfg retrieve .zshrc
```

**WARNING:** make sure that you have your local part in synch before
retrieving, it will overwrite the config file Other git command are also
supported (call the tool with `--help` to get a list).

## Installation

If you want to use my config files, go ahead and clone this whole repo to
`$HOME/.dotfiles/common`. If you just want the cfg tool itself, [download](cfg)
it and put it somewhere in your path.

You will need following libraries to be installed (you can pip install all of them):
* click
* GitPython
* python-magic
* click_completion

## Disclaimer

This tool will overwrite you config file without any warning. Make sure you
know what you are doing when invoking the `retrieve` command. As always,
backups are your best friends.

I developed this tool for my personal use. At the moment it is in alpha stage,
I am uploading it to github mainly for synchronization purposes. Feel free
to experiment with it and submit feedback, but don't expect much support at the
moment.
