#!/bin/bash
#
# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

help()
{
  echo "Deploy cloud resource using AWS CLI, Terraform and Terragrunt"
  echo
  echo "Syntax: deploy.sh [-c|d|e|i|r|t]"
  echo "Options:"
  echo "c     Specify cleanup / destroy resources (e.g. true)"
  echo "d     Specify directory path (e.g. iac/api)"
  echo "i     Specify global id (e.g. abcd1234)"
  echo "r     Specify AWS region (e.g. us-east-1)"
  echo "s     Specify S3 bucket (e.g. fdp-backend-us-east-1)"
  echo
}

set -o pipefail

while getopts "h:c:d:i:r:s:" option; do
  case $option in
    h)
      help
      exit;;
    c)
      FDP_CLEANUP="$OPTARG";;
    d)
      FDP_DIR="$OPTARG";;
    i)
      FDP_GID="$OPTARG";;
    r)
      FDP_REGION="$OPTARG";;
    s)
      FDP_BUCKET="$OPTARG";;
    \?)
      echo "[ERROR] invalid option"
      echo
      help
      exit;;
  esac
done

if [ -z "${FDP_REGION}" ] && [ -n "${AWS_DEFAULT_REGION}" ]; then FDP_REGION="${AWS_DEFAULT_REGION}"; fi
if [ -z "${FDP_REGION}" ] && [ -n "${AWS_REGION}" ]; then FDP_REGION="${AWS_REGION}"; fi

if [ -z "${FDP_REGION}" ]; then
  echo "[DEBUG] FDP_REGION: ${FDP_REGION}"
  echo "[ERROR] FDP_REGION is missing..."; exit 1;
fi

if [ -z "${FDP_BUCKET}" ]; then
  echo "[DEBUG] FDP_BUCKET: ${FDP_BUCKET}"
  echo "[ERROR] FDP_BUCKET is missing..."; exit 1;
fi

if [ -z "${FDP_DIR}" ]; then
  echo "[DEBUG] FDP_DIR: ${FDP_DIR}"
  echo "[ERROR] FDP_DIR is missing..."; exit 1;
fi

WORKDIR="$( cd "$(dirname "$0")/../" > /dev/null 2>&1 || exit 1; pwd -P )"
if [ ! -d "${WORKDIR}/${FDP_DIR}/" ]; then
  echo "[DEBUG] FDP_DIR: ${FDP_DIR}"
  echo "[ERROR] ${WORKDIR}/${FDP_DIR}/ does not exist..."; exit 1;
fi

echo "[EXEC] cd ${WORKDIR}/${FDP_DIR}/"
cd "${WORKDIR}/${FDP_DIR}/"

case ${FDP_DIR} in app/gui*)
  echo "
  ###################################################################
  # Deployment Process for Frontend MicroSite Code                  #
  # 1. npm install dependencies and run build to compile new code   #
  # 2. run aws sync command to push new code from local build to s3 #
  ###################################################################
  "

  # aws --version > /dev/null 2>&1 || { wget -q https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip; unzip awscli-exe-linux-aarch64.zip; sudo ./aws/install; ln -s /usr/local/bin/aws ${WORKDIR}/bin/aws; }
  aws --version > /dev/null 2>&1 || { wget -q https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip; unzip awscli-exe-linux-x86_64.zip; sudo ./aws/install --bin-dir ${WORKDIR}/bin --install-dir ${WORKDIR}/awscli; }
  npm --version > /dev/null 2>&1 || { wget -q https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | /bin/bash; \. "$HOME/.nvm/nvm.sh"; nvm install 22; }

  echo "[EXEC] npm install"
  npm install || { echo "[ERROR] npm install failed. aborting..."; cd -; exit 1; }

  echo "[EXEC] npm run build"
  npm run build || { echo "[ERROR] npm run build failed. aborting..."; cd -; exit 1; }

  ### TODO: Generate amplifyconfiguration.json

  echo "[EXEC] aws s3 sync --delete ./build s3://${FDP_BUCKET}"
  aws s3 sync --delete ./build s3://${FDP_BUCKET} || { echo "[ERROR] aws s3 sync failed. aborting..."; cd -; exit 1; }

  FDP_QUERY="DistributionList.Items[*].{id:Id,origin:Origins.Items[0].Id}[?starts_with(origin,\`${FDP_BUCKET}\`)].id"
  echo "[EXEC] aws cloudfront list-distributions --region ${FDP_REGION} --query ${FDP_QUERY} --output text"
  FDP_RESULT=$(aws cloudfront list-distributions --region ${FDP_REGION} --query ${FDP_QUERY} --output text)

  if [ "${FDP_RESULT}" != "" ]; then
    echo "[EXEC] aws cloudfront create-invalidation --distribution-id ${FDP_RESULT} --paths '/*'"
    aws cloudfront create-invalidation --distribution-id ${FDP_RESULT} --paths '/*' || { echo "[WARN] aws cloudfront create-invalidation --distribution-id ${FDP_RESULT} failed..."; }
  fi
esac

case ${FDP_DIR} in iac*)
  echo "
  #################################################################
  # Deployment Process for Infrastructure as Code                 #
  # 1. pass specific environment variables as terraform variables #
  # 2. run terragrunt commands across specific directory          #
  #################################################################
  "

  terraform -v > /dev/null 2>&1 || { wget -q https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_linux_arm64.zip; unzip terraform_*.zip; mv terraform ${WORKDIR}/bin/terraform; }
  terragrunt -v > /dev/null 2>&1 || { wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.77.17/terragrunt_linux_arm64; chmod 0755 terragrunt_*; mv terragrunt_* ${WORKDIR}/bin/terragrunt; }
  # terraform -v > /dev/null 2>&1 || { wget -q https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_linux_386.zip; unzip terraform_*.zip; mv terraform ${WORKDIR}/bin/terraform; }
  # terragrunt -v > /dev/null 2>&1 || { wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.77.17/terragrunt_linux_386; chmod 0755 terragrunt_*; mv terragrunt_* ${WORKDIR}/bin/terragrunt; }
  # terraform -v > /dev/null 2>&1 || { wget -q https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_darwin_arm64.zip; unzip terraform_*.zip; mv terraform ${WORKDIR}/bin/terraform; }
  # terragrunt -v > /dev/null 2>&1 || { wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.78.0/terragrunt_darwin_arm64; chmod 0755 terragrunt_*; mv terragrunt_* ${WORKDIR}/bin/terragrunt; }

  if [ -z "${FDP_TFVAR_BACKEND_BUCKET}" ]; then
    export FDP_TFVAR_BACKEND_BUCKET={\"${FDP_REGION}\"=\"${FDP_BUCKET}\"}
  fi

  if [ -z "${FDP_TFVAR_GID}" ] && [ -n "${FDP_GID}" ]; then
    export FDP_TFVAR_GID=$FDP_GID
  fi

  OPTIONS=""
  FDP_TFVARS=$(env | grep FDP_TFVAR_)
  while IFS= read -r LINE; do
    KEY=$(echo $LINE | cut -d"=" -f1)
    BACK=${LINE/$KEY=/}
    FRONT=$(echo ${KEY/FDP_TFVAR_/} | tr "[:upper:]" "[:lower:]")
    if [ -n "${BACK}" ]; then OPTIONS=" ${OPTIONS} -var fdp_${FRONT}=${BACK}"; fi
  done <<< "$FDP_TFVARS"

  echo "[EXEC] terragrunt run-all init -backend-config region=${FDP_REGION} -backend-config bucket=${FDP_BUCKET} --no-color"
  terragrunt run-all init -backend-config region="${FDP_REGION}" -backend-config="bucket=${FDP_BUCKET}" --no-color || { echo "[ERROR] terragrunt run-all init failed. aborting..."; cd -; exit 1; }

  if [ -n "${FDP_CLEANUP}" ] && [ "${FDP_CLEANUP}" == "true" ]; then
    echo "[EXEC] terragrunt run-all destroy -auto-approve -var-file default.tfvars $OPTIONS --no-color"
    echo "Y" | terragrunt run-all destroy -auto-approve -var-file default.tfvars $OPTIONS --no-color || { echo "[ERROR] terragrunt run-all destroy failed. aborting..."; cd -; exit 1; }
  else
    echo "[EXEC] terragrunt run-all apply -auto-approve -var-file default.tfvars $OPTIONS --no-color"
    echo "Y" | terragrunt run-all apply -auto-approve -var-file default.tfvars $OPTIONS --no-color || { echo "[ERROR] terragrunt run-all apply failed. aborting..."; cd -; exit 1; }
  fi

esac

echo "[EXEC] cd -"
cd -
