
# hashicorp/terraform:light
TERRAFORMIMAGE=test


plan:
	echo "SHOW terraform plan"
	docker run --rm -it \
		-v $(PWD):/data \
		-w /data \
		-e HOME=/data \
		$(TERRAFORMIMAGE) plan

shell:
	docker run --rm -it \
		-v $(PWD):/data \
		-w /data \
		-e HOME=/data \
		--entrypoint bash \
		$(TERRAFORMIMAGE)

build:
	cat Dockerfile | docker build -t $(TERRAFORMIMAGE) -

.terraform:
	docker run -i -t -v $(PWD):/data -w /data $(TERRAFORMIMAGE) init

init:
	docker run -i -t -v $(PWD):/data -w /data $(TERRAFORMIMAGE) init

cloud-init-key:
	ssh-keygen -q -f ./cloud-init-key -N ""

apply: cloud-init-key .terraform
	# TODO: need to set STACKDOMAIN, and should use it in terraform...
	docker run --rm -it \
		-v $(PWD):/data \
		-w /data \
		-e HOME=/data \
		$(TERRAFORMIMAGE) apply
	# TODO: wait for cloud-init to finish (docker swarm up, with the right number of nodes)
	# TODO: docker ona create --branch master -stack seaweedfs --stack traefik --stack prometheus --stack keycloak --stack cronicle swarm-infra

show: .terraform
	docker run --rm -it \
		-v $(PWD):/data \
		-w /data \
		-e HOME=/data \
		$(TERRAFORMIMAGE) show

destroy:
	docker run --rm -it \
		-v $(PWD):/data \
		-w /data \
		-e HOME=/data \
		$(TERRAFORMIMAGE) destroy
