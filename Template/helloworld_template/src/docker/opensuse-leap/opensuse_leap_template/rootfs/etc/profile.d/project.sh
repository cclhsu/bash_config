# NOTE: copy and chang file name "project", it will use file name as package name
_PROJECT=$(basename ${0} .sh)

_PROJECT_UPPERCASE=$(echo ${_PROJECT} | tr '[:lower:]' '[:upper:]')
_HOME=/opt/${_PROJECT}/default
_WEB=/var/${_PROJECT}
export ${_PROJECT_UPPERCASE}_HOME=${_HOME}
export ${_PROJECT_UPPERCASE}_WEB_HOME=${_WEB}
