workflow "Deploy changes" {
  on = "push"
  resolves = ["deploy"]
}

action "Filter master branch" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "deploy" {
  needs = "Filter master branch"
  uses = "./deploy-action"
  secrets = [
    "CF_USERNAME",
    "CF_PASSWORD",
    "CF_SPACE",
    "CF_API",
    "CF_ORG",
    "CF_APP"
  ]
}
