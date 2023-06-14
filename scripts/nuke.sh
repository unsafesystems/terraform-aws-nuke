function handler () {
    aws-nuke -c config.yaml --force --force-sleep 3 --no-dry-run -q

    echo "{\"statusCode\": 200, \"body\": \"ok\"}"
}
