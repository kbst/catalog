resource "github_repository" "module" {
  for_each = var.names

  name         = "terraform-kustomization-${each.key}"
  description  = "${title(each.key)} Terraform Module for Kubernetes by Kubestack"
  homepage_url = "https://www.kubestack.com/catalog/${each.key}/"

  visibility = "public"

  auto_init = true

  has_issues      = false
  has_discussions = false
  has_projects    = false
  has_wiki        = false
  has_downloads   = false

  archive_on_destroy = true

  topics = [
    "kubernetes",
    "terraform",
    "terraform-module",
    "kustomize",
    "kubestack",
    each.key,
  ]
}

resource "github_branch" "main" {
  for_each = var.names

  repository = github_repository.module[each.key].name
  branch     = "main"
}

resource "github_branch_default" "default" {
  for_each = var.names

  repository = github_repository.module[each.key].name
  branch     = github_branch.main[each.key].branch
}

resource "github_repository_file" "readme" {
  for_each = var.names

  repository = github_repository.module[each.key].name
  branch     = github_branch.main[each.key].branch

  file = "README.md"
  content = templatefile(
    "${path.root}/README.md.tpl",
    { name : each.key }
  )

  commit_message      = "Create placeholder README.md for main branch"
  commit_author       = "Philipp Strube"
  commit_email        = "pst@kubestack.com"
  overwrite_on_create = true
}
