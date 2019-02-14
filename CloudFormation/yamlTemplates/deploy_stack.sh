#!/usr/bin/env bash
AWS_PROFILE=dudenmf
STACK_PREFIX=K8S
JUMPHOSTKEY=marlon.schultz-duden_key
#networking
# vpc, 2 priv subnets, 2 public subnets, 2 nat, 1 igw, 2 eip's
aws cloudformation create-stack --stack-name $STACK_PREFIX-networking --template-body file://networking/network.yaml --profile=$AWS_PROFILE
echo "Waiting for stack to complete"
aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-networking --profile=$AWS_PROFILE

#jumphost
aws cloudformation create-stack --stack-name $STACK_PREFIX-sg-jumphost --template-body file://jumphost/securityGroupJumpHost.yaml --profile=$AWS_PROFILE --parameters ParameterKey=NetworkStackNameParameter,ParameterValue=$STACK_PREFIX-networking
echo "Waiting for stack to complete"
aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-sg-jumphost --profile=$AWS_PROFILE

aws cloudformation create-stack --stack-name $STACK_PREFIX-jumphost --template-body file://jumphost/jumpHost.yaml --profile=$AWS_PROFILE \
--parameters \
ParameterKey=PublicSubnetOne,ParameterValue=$STACK_PREFIX-networking-PubSubNet1 \
ParameterKey=SecurityGroupJumpHostSSH,ParameterValue=$STACK_PREFIX-sg-jumphost-sg-jumphost \
ParameterKey=JumpHostKey,ParameterValue=$JUMPHOSTKEY

echo "Waiting for stack to complete"
aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-jumphost --profile=$AWS_PROFILE
