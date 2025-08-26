passmeta() {
  pass show "$1" | tail -n +2
}

compdef passmeta=pass

pass() {
  if [[ $# -eq 0 ]]; then
    command pass ls
  else
    case "$1" in
      show|insert|edit|generate|rm|mv|cp|git|grep|find|init|help|version|ls)
        command pass "$@"
        ;;
      *)
        command pass -c "$@"
        ;;
    esac
  fi
}
