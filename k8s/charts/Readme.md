helm install --dry-run --debug --create-namespace --namespace my-node-feature-test -f values.yaml --set node.appname=my-node,node.image.tag=feature-test --set-file db.initFile=../../migrations/init-pg.sql my-node ./
helm install --create-namespace --namespace my-node-feature-test -f values.yaml --set node.appname=my-node,node.image.tag=feature-test --set-file db.initFile=../../migrations/init-pg.sql my-node ./

replace install with upgrade

helm delete my-node --namespace my-node-feature-test