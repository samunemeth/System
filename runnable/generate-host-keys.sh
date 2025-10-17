# bash
# This file is built with nix, so no shebang or executable flag required.

# Generate some useful variables for formatting text.
TEXTBOLD=$(tput bold)
TEXTRED=$(tput setaf 1)
TEXTNORMAL=$(tput sgr0)

echo
printf "    ${TEXTBOLD}This is a simple script for generating host ssh keys.${TEXTNORMAL}\n"
echo

getopts u:a:f: flag

# Show a warning if the script is not running as root.
if [[ "$EUID" != 0 ]]; then
  printf "$TEXTRED"
  echo "This script probably requires root privalages."
  printf "It is currently running as: $TEXTBOLD$USER$TEXTNORMAL$TEXTRED\n"
  echo "The script will continue, and try to do all operations until one fails."
  echo "If you need to, just re-run the script with sudo."
  printf "$TEXTNORMAL"
  echo
fi

# Get the location to generate the ssh keys into.
GENERATETO=/etc/ssh/
if [[ $# == 0 ]]; then

  # If there is no positional argument, just use the default.
  echo "No argument passed, the keys will be generated into the default location:"

else

  # If there is an argument, override the default.
  GENERATETO=$1

  # Check if the path ends with a slash. If not, add one to the end.
  if [[ "$GENERATETO" != *"/" ]]; then
    GENERATETO=$GENERATETO/
  fi

  echo "An argument passed, the keys will be generated into the given location:"

fi
printf "${TEXTBOLD}%s$TEXTNORMAL\n" $GENERATETO
echo

# See if there are ssh keys present in that directory.
EXISTINGKEYS=($(ls -1 ${GENERATETO}ssh_*_key* 2>/dev/null))

if [[ "${#EXISTINGKEYS[@]}" != 0 ]]; then
  printf "$TEXTRED$TEXTBOLD"
  echo "There are already ssh keys in this folder, with the following names:"
  printf "$TEXTNORMAL$TEXTRED"
  for x in "${EXISTINGKEYS[@]}"; do
    echo "$x"
  done
  printf "$TEXTRED$TEXTBOLD"
  echo "You probably do not want to override these, so this script will not do that."
  echo "If you really want to replace them, and you probably should not, then delete"
  echo "these keys first manually and run this script again."
  printf "$TEXTNORMAL"
  echo
  exit
fi

echo "There are no exsisting ssh keys in this folder, so the script will continue."
echo

echo "The following new keys will be generated:"
echo "${GENERATETO}ssh_host_ed25519_key"
echo "${GENERATETO}ssh_host_ed25519_key.pub"
echo "${GENERATETO}ssh_host_rsa_key"
echo "${GENERATETO}ssh_host_rsa_key.pub"
echo

printf "Are you sure you want to create these files [Y/n]? "
read
if [[ ! $REPLY =~ (^$|^[Yy]) ]]; then
  echo "Aborting."
  echo
  exit
fi
echo

echo "Some stuff will happen now!"
echo
