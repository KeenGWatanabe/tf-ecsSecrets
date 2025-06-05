
git add .
git commit -m "msg"  
git push origin -u main

# cli force deployment
aws ecs update-service --cluster ce-grp-4r-app-cluster --service ce-grp-4r-app-service-ac34ede7 --force-new-deployment