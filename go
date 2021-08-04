#!/usr/bin/env bash

set -e
script_dir=$(cd "$(dirname "$0")" ; pwd -P)

app=data-mesh-bootstrap

goal_build() {
  pushd "${script_dir}/dev-tools" > /dev/null
    docker build -t ${app} .
  popd > /dev/null
}

goal_run() {
  pushd "${script_dir}/dev-tools" > /dev/null
    docker run -v ${script_dir}:/app -it ${app}
  popd > /dev/null
}


goal_apply() {
  workdir=${1}
  pushd "${script_dir}/../${workdir}" > /dev/null
        terraform init --backend-config=bucket=${app}-terraform-state --backend-config=dynamodb_table=${app}-terraform-lock
        terraform apply
  popd > /dev/null
}

goal_plan() {
  workdir=${1}
  pushd "${script_dir}/../${workdir}" > /dev/null
        terraform init --backend-config=bucket=${app}-terraform-state --backend-config=dynamodb_table=${app}-terraform-lock
        terraform plan
  popd > /dev/null
}

goal_login-beach() {
    pushd "${script_dir}" > /dev/null
      saml2aws login \
        --idp-account=beach --idp-provider Okta --mfa Auto \
        --url "https://thoughtworks.okta.com/home/amazon_aws/0oa1c9mun8aIqVj7I0h8/272" \
        --profile beach --region eu-central-1 --username=kmok@thoughtworks.com
    popd > /dev/null
}

goal_login-twdu() {
  pushd "${script_dir}" > /dev/null
    saml2aws login \
      --idp-account=twdu-europe --idp-provider Okta --mfa Auto \
      --url "https://thoughtworks.okta.com/home/amazon_aws/0oa1kzdqca8OEU6ju0h8/272" \
      --profile twdu-europe-base --region eu-central-1 --username=kmok@thoughtworks.com

    assume-role twdu-europe-base federated-admin twdu-europe
  popd > /dev/null

}

TARGET=${1:-}
if type -t "goal_${TARGET}" &>/dev/null; then
  "goal_${TARGET}" ${@:2}
else
  echo "Usage: $0 <goal>

goal:
    build                    - Builds development container
    apply                    - Runs terraform apply
"
  exit 1
fi