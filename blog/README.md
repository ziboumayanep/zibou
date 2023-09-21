create version
VERSION=v1
build docker image
`docker build -t namnguyen107/blog:$VERSION .`

push to dockerhub
```
docker login
docker push namnguyen107/blog:$VERSION
```

run hugo server

`hugo server`

generate static files

`hugo`
