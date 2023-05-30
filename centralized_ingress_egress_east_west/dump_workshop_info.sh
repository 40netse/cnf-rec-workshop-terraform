#!/usr/bin/env bash


#
# deploy the stack if it doesn't already exist
#
vpc_id=`aws ec2 describe-vpcs --region us-west-2 --filters Name=tag:Name,Values=tec-cnf-lab-inspection-vpc --query Vpcs[].VpcId --output text`
echo Inspection VPC ID = $vpc_id
public_subnet_id_az1=`aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=tec-cnf-lab-inspection-public-az1-subnet --query Subnets[].SubnetId --output text`
echo Inspection Public Subnet AZ1 ID = $public_subnet_id_az1
public_subnet_id_az2=`aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=tec-cnf-lab-inspection-public-az2-subnet --query Subnets[].SubnetId --output text`
echo Inspection Public Subnet AZ2 ID = $public_subnet_id_az2

fwaas_subnet_id_az1=`aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=tec-cnf-lab-inspection-fwaas-az1-subnet --query Subnets[].SubnetId --output text`
echo Inspection Fwaas Subnet AZ1 ID = $fwaas_subnet_id_az1
fwaas_subnet_id_az2=`aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=tec-cnf-lab-inspection-fwaas-az2-subnet --query Subnets[].SubnetId --output text`
echo Inspection Fwaas Subnet AZ2 ID = $fwaas_subnet_id_az2
nat_gateway_id_az1=`aws ec2 describe-nat-gateways --region us-west-2 --filter Name=subnet-id,Values=$public_subnet_id_az1 --query 'NatGateways[*].NatGatewayId' --output text`
echo Inspection NAT Gateway ID AZ1 = $nat_gateway_id_az1
nat_gateway_id_az2=`aws ec2 describe-nat-gateways --region us-west-2 --filter Name=subnet-id,Values=$public_subnet_id_az2 --query 'NatGateways[*].NatGatewayId' --output text`
echo Inspection NAT Gateway ID AZ2 = $nat_gateway_id_az2
tfile=$(mktemp /tmp/foostack1.XXXXXXXXX)
aws ec2 describe-vpc-endpoints --region=us-west-2 --filter Name=vpc-id,Values=$vpc_id --query 'VpcEndpoints[].VpcEndpointId' --output text > $tfile
for i in `cat $tfile`
do

  test_subnet_id=`aws ec2 describe-vpc-endpoints --regio=us-west-2 --vpc-endpoint-ids $i --query 'VpcEndpoints[].SubnetIds' --output text`
  if [ "$test_subnet_id" = "$fwaas_subnet_id_az1" ]
  then
    vpce_endpoint_az1=$i
  elif  [ "$test_subnet_id" = "$fwaas_subnet_id_az2" ]
  then
    vpce_endpoint_az2=$i
  fi
done
echo VPC Endpoint AZ1 = $vpce_endpoint_az1
echo VPC Endpoint AZ2 = $vpce_endpoint_az2
rm -f $tfile
exit

#
# End of the script
#
