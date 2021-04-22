_all: test-terraform dist

GITHUB_REF ?= $(shell echo "refs/heads/"`git rev-parse --abbrev-ref HEAD`)
GITHUB_SHA ?= $(shell echo `git rev-parse --verify HEAD^{commit}`)

test-terraform:
	cd src/_terraform_module/; terraform test

dist:
	docker build -t catalog:dist-${GITHUB_SHA} .github/actions/builder
	docker run --rm -v `pwd`:/workdir:z --workdir=/workdir -e GITHUB_REF=${GITHUB_REF} -e GITHUB_SHA=${GITHUB_SHA} catalog:dist-${GITHUB_SHA} 

test-kustomize: dist
	docker build -t catalog:test-kustomize-${GITHUB_SHA} test/kustomize/
	docker run --rm -v `pwd`/_dist:/_dist:z catalog:test-kustomize-${GITHUB_SHA}


test-kind: dist
	docker build -t catalog:test-kind-${GITHUB_SHA} test/kind/
	docker run --network host --rm -v `pwd`/_dist:/_dist:z -v ${HOME}/.kube/config:/opt/test/.kubeconfig:z catalog:test-kind-${GITHUB_SHA}
