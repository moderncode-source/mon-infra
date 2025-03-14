{
  writeShellApplication,
  gojsontoyaml,
  jsonnet,
}:
writeShellApplication rec {
  name = "build-manifests";
  runtimeInputs = [
    gojsontoyaml
    jsonnet
  ];
  text = ''
    if [ "$#" -eq 0 ]; then
        find . -type f \
               -name "manifests.build" \
               -execdir sh -c \
               'echo "Building manifests in $(pwd): $@" && $@' sh {} +
    elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "Usage: ${name}"
        echo ""
        echo "Build manifest files for all of the project's libraries and"
        echo "packages. The exact steps taken are specified in"
        echo "\"manifests.build\" shell scripts for each such library or"
        echo "package. This command will find and run them."
        exit 0
    else
        echo "Unknown option: \"$1\""
        exit 1
    fi
  '';
}
