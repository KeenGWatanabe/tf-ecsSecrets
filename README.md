
git add .
git commit -m "msg"  
git push origin -u main

# cli force deployment
aws ecs update-service --cluster ce994-app-cluster --service ce994-app-service-da4e5155 --force-new-deployment