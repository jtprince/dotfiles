# nested JSON

## bash single-line heredoc
http POST https://hello.com/ <<<'{ "user": { "name": "john", "age": 10 } }'

## walrus operator
http POST https://hello.com/ user:='{"name": "john", "age": 10 }'

## echo to stdin
echo '{ "user": { "name": "john", "age": 10 } }' | http POST https://hello.com/
