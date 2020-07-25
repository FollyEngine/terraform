
# hashicorp/terraform:light
TERRAFORMIMAGE=follyengine/terraform
CONTAINERNAME=folly-terraform

plan:
	echo "SHOW terraform plan"
	docker exec -it $(CONTAINERNAME) terraform plan

shell:
	docker exec -it $(CONTAINERNAME) bash

build:
	cat Dockerfile | docker build -t $(TERRAFORMIMAGE) -

.terraform:
	docker exec -it $(CONTAINERNAME) terraform init

terraform.tfvars:
	echo
	echo "You need a valid terraform.tfvars file with the lastpass credentials in it"
	echo
	exit 1

init: #terraform.tfvars
	docker cp $(CONTAINERNAME):/terraform.d .
	docker exec -it $(CONTAINERNAME) terraform init
	#docker exec -it $(CONTAINERNAME) lpass login --trust $(shell grep lastpass_username terraform.tfvars | cut -f3 -d' ')

cloud-init-key:
	ssh-keygen -q -f ./cloud-init-key -N ""

apply: cloud-init-key .terraform
	# TODO: need to set STACKDOMAIN, and should use it in terraform...
	docker exec -it $(CONTAINERNAME) terraform apply
	# TODO: wait for cloud-init to finish (docker swarm up, with the right number of nodes)
	# TODO: docker ona create --branch master -stack seaweedfs --stack traefik --stack prometheus --stack keycloak --stack cronicle swarm-infra

show: .terraform
	docker exec -it $(CONTAINERNAME) terraform show

destroy:
	docker exec -it $(CONTAINERNAME) terraform destroy

# runing container in the background so we don't have to keep putting in the lastpass 2fa key
start:
	docker run --name $(CONTAINERNAME) -dit \
		-v $(PWD):/data \
		-w /data \
		-v $(HOME)/:/home/terraform/ \
		-e HOME=/home/terraform/ \
		-u 1000 \
		--net=host \
		--entrypoint tail \
		$(TERRAFORMIMAGE) -f /dev/null

stop:
	docker rm -f $(CONTAINERNAME)