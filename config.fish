# for ~/.config/fish/config.fish


set host (hostname)

##### Detect distro #####

#TODO: a workaround for the bug in else if with piped conditionals, to reduce
#      the number of grep processes that run
set distro ''
if echo $host | grep -Eq '(zen|main|nsto|yarr)'
  set distro 'ubuntu'
end
if echo $host | grep -Eq '(nfshost)'
  set distro 'freebsd'
end
if echo $host | grep -Eq '(brubeck)'
  set distro 'debian'
end
if echo $host | grep -Eq 'vbox'
  set distro 'cygwin'
end
# Do your best to detect the distro
# Uses info from http://www.novell.com/coolsolutions/feature/11251.html
# and http://en.wikipedia.org/wiki/Uname
if test -z $distro
  set kernel (uname -s | tr '[:upper:]' '[:lower:]')
  if echo $kernel | grep -Eq 'freebsd'
    set distro 'freebsd'
  else
    if echo $kernel | grep -Eq 'bsd$'
      set distro 'bsd'
    end
  end
  if echo $kernel | grep -Eq 'darwin'
    set distro 'mac'
  end
  if echo $kernel | grep -Eq 'cygwin'
    set distro 'cygwin'
  end
  if echo $kernel | grep -Eq 'mingw'
    set distro 'mingw'
  end
  if echo $kernel | grep -Eq 'sunos'
    set distro 'solaris'
  end
  if echo $kernel | grep -Eq 'haiku'
    set distro 'haiku'
  end
  if echo $kernel | grep -Eq 'linux'
    # try /etc/os-release
    if test -f /etc/os-release
      set distro (grep '^NAME' /etc/os-release | sed -E 's/^NAME="([^"]+)"$/\1/g' | tr '[:upper:]' '[:lower:]')
    end
    # try any /etc/*-release
    if test -z $distro
      set distro (ls /etc/*-release | sed -E 's#/etc/([^-]+)-release#\1#' | head -n 1)
    end
    # distro-specific variations of /etc/os-release
    if test -z $distro
      if test -f /etc/debian_version
        set distro 'debian'
      end
      if test -f /etc/redhat_version
        set distro 'redhat'
      end
      if test -f /etc/slackware-version
        set distro 'slackware'
      end
    end
    if test -z $distro
      set distro 'linux'
    end
  else
    set distro 'unknown'
  end
end

# if [[ $host =~ (brubeck) || $distro =~ (ubuntu|cygwin) ]]; then
if echo $distro | grep -Eq '(ubuntu|cygwin|debian)'
  function lsl; ls -lFhAb --color=auto --group-directories-first $argv; end
  function lsld; ls -lFhAbd --color=auto --group-directories-first $argv; end
else
  # long options don't work on nfshost (freebsd)
  function lsl; ls -lFhAb $argv; end
  function lsld; ls -lFhAbd $argv; end
end

function mvi; mv -i $argv; end
function cpi; cp -i $argv; end
function trash; trash-put $argv; end
function awkt; awk -F '\t' -v OFS='\t' $argv; end

function vif; vim ~/.config/fish/config.fish; end
if echo $distro | grep -Eq 'bsd$'
  function vib; vim ~/.bash_profile; end
else
  function vib; vim ~/.bashrc; end
end
function bak
  if not test -z $argv; and test -f $argv[1]
    cp -r $argv[1] $argv[1]'.bak'
  end
end
# readlink -f except it handles commands on the PATH too
function deref
  set file $argv[1]
  if not test -f $file
    set file (which $file)
  end
  readlink -f "$file"
end
# this requires deref!
function vil
  if not test -z $argv
    vim (deref "$argv[1]")
  end
end
function vix
  if test -z $argv
    return
  else if test -f $argv[1]
    vim $argv[1]
  else
    touch $argv[1]; chmod +x $argv[1]; vim $argv[1]
  end
end

function calc
  if test -z $argv
    python -i -c "from __future__ import division; from math import *"
  else
    python -c "from __future__ import division; from math import *; print $argv"
  end
end

# greeting and prompt
set fish_greeting ""
function fish_prompt
  set pwd (pwd | sed -e "s|^$HOME|~|")
  set_color green
  echo -n '['(date +'%a %b %d')'] '
  set_color blue
  echo -e "$USER@$host: $pwd\n) "
end

# on a remote machine?
if not test -z $SSH_CLIENT; or not test -z $SSH_TTY
  set remote 'true'
else
  set remote 'false'
end

if test $remote = 'true'
  # remove color from prompt on remote machines
  function fish_prompt
    set pwd (pwd | sed -e "s|^$HOME|~|")
    echo -e '['(date +'%a %b %d')"] $USER@$host: $pwd\n) "
  end
end