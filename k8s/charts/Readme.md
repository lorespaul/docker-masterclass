# Use Helm  

## Check install chart dry run  
helm install --dry-run --debug --create-namespace --namespace my-node-feature-test -f values.yaml --set node.appname=my-node,node.image.tag=feature-test --set-file db.initFile=../../migrations/init-pg.sql my-node ./  

## Inatll chart  
helm install --create-namespace --namespace my-node-feature-test -f values.yaml --set node.appname=my-node,node.image.tag=feature-test --set-file db.initFile=../../migrations/init-pg.sql my-node ./  

## Upgrade chart  
replace install with upgrade  

helm upgrade --install --create-namespace --namespace my-node-feature-test -f values.yaml --set node.appname=my-node,node.image.tag=feature-test --set-file db.initFile=../../migrations/init-pg.sql my-node ./  

## Delete chart  
helm delete my-node --namespace my-node-feature-test  
