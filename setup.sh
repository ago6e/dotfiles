#!/bin/bash
PRIVATE_KEY_FILE=${1:-${HOME}/ssh/id_rsa}

for package in bash curl sudo tar; do
  if ! type ${package} > /dev/null 2>&1; then
    echo "${package} is required"
    exit 1
  fi
done

package_manager () {
  declare -A args
  local pm_name=
  for arg in "$@"; do
    case "${arg}" in
    -apk | -apt | -brew | -dnf | -yum )
      pm_name=${arg#-} ;;
    *)
      [ "x${pm_name}" != 'x' ] && args[${pm_name}]="${args[${pm_name}]} ${arg}" ;;
    esac
  done

  for pm_name in apk apt brew dnf yum; do
    [ "x${args[${pm_name}]}" != 'x' ] && type ${pm_name} > /dev/null 2>&1 && {
      sudo ${pm_name} ${args[${pm_name}]}
      return
    }
  done
}

package_manager \
  -apk add git \
  -apt install -y git \
  -brew install git \
  -dnf install -y git \
  -yum install -y git

git config --global core.autoCRLF false
GIT_SSH_COMMAND="ssh -i \"${PRIVATE_KEY_FILE}\" -o IdentitiesOnly=yes" git clone git@bitbucket.org:ago6e/dotfiles.git ~/.dotfiles
~/.dotfiles/setup.sh

