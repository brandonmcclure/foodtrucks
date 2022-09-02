# What I would have done differently (and what next steps are for production)

- Focused more on [prometheus alerts](http://localhost:9090/alerts?search=) instead of grafana/visualizations. 
- Setup IAM and private ECR resources. This [tutorial](https://blog.gitguardian.com/managing-aws-iam-with-terraform-part-1/) seems like a good start. I would need to do some more research on IAM in general to ensure I keeping best practices in mind. (and write some form of CI to help force me to follow that!)
- I wanted to allow users to setup their own alerts via a json file saved in the repo, and our production alerting protected via branch policies and github actions. I ran out of time, but am happy with the functionality I did complete in [Invoke-FoodTruckEtl.ps1](https://github.com/brandonmcclure/foodtrucks/blob/main/src/Invoke-FoodTruckEtl/Invoke-FoodTruckEtl.ps1)

Github actions and some more "git ops" would be my next focus on making this truly production worthy. Running github runners inside of my AWS environment would be helpful, although we could make use of public runners quickly to check prometheus config files, and run our pwsh unit tests. 