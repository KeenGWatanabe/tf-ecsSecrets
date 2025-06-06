# useful commands to troubleshoot IAM roles and tasks

$ aws ecs describe-task-definition --task-definition ce-grp-4r-app-task | grep "ssm"
output:  "name": "ecs.capability.secrets.ssm.environment-variables"


$ aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::255945442255:role/ecs-task-execution-role-ce-grp-4r \
  --action-names "secretsmanager:GetSecretValue" "ssm:GetParameters"                


output: 
  {
    "EvaluationResults": [
        {
            "EvalActionName": "secretsmanager:GetSecretValue",
            "EvalResourceName": "*",
            "EvalDecision": "implicitDeny",
            "MatchedStatements": [],
            "MissingContextValues": []
        },
        {
            "EvalActionName": "ssm:GetParameters",
            "EvalResourceName": "*",
            "EvalDecision": "explicitDeny",
            "MatchedStatements": [
                {
                    "SourcePolicyId": "role_ecs-task-execution-role-ce-grp-4r_ecs_execution_secrets",        
                    "SourcePolicyType": "IAM Policy",
                    "StartPosition": {
                        "Line": 1,
                        "Column": 38
                    },
                    "EndPosition": {
                        "Line": 1,
                        "Column": 89
                    }
                }
            ],
            "MissingContextValues": []
        }
`implicitDeny` is working, but secretsmanager isn't `whitelisted`