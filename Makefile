
# hashicorp/terraform:light
TERRAFORMIMAGE=follyengine/terraform
CONTAINERNAME=folly-terraform

TERRAFORM_TOKEN=$(shell cat ~/.terraform_csiro_cloud.token)
TERRAFORMTAG=0.14.5

COMPUTER=sven-screen1
COMPUTER=follybase1
TARGET="$(PWD)/computers/$(COMPUTER)/"

plan:
	echo "SHOW terraform plan"
	docker exec -it -w $(TARGET) -e TERRAFORM_TOKEN $(CONTAINERNAME) terraform plan

shell:
	docker exec -it -w $(TARGET) -e TERRAFORM_TOKEN $(CONTAINERNAME) bash

build:
	cat Dockerfile | docker build --build-arg TERRAFORMTAG=$(TERRAFORMTAG) -t $(TERRAFORMIMAGE):$(TERRAFORMTAG) -


.terraform:
	docker exec -it -w $(TARGET) -e TERRAFORM_TOKEN $(CONTAINERNAME) terraform init \
		--backend-config 'token=$(TERRAFORM_TOKEN)' \
		--reconfigure

terraform.tfvars:
	echo
	echo "You need a valid terraform.tfvars file with the lastpass credentials in it"
	echo
	exit 1

init: #terraform.tfvars
	#docker cp $(CONTAINERNAME):/terraform.d .
	docker exec -it -w $(TARGET) -e TERRAFORM_TOKEN $(CONTAINERNAME) terraform login
	docker exec -it -w $(TARGET) -e TERRAFORM_TOKEN $(CONTAINERNAME) terraform init \
		--backend-config 'token=$(TERRAFORM_TOKEN)' \
		--reconfigure
	#docker exec -it -w $(TARGET) $(CONTAINERNAME) lpass login --trust $(shell grep lastpass_username terraform.tfvars | cut -f3 -d' ')

cloud-init-key:
	ssh-keygen -q -f ./cloud-init-key -N ""

apply: cloud-init-key .terraform
	# TODO: need to set STACKDOMAIN, and should use it in terraform...
	# Ensure Docker is installed first
	docker exec -it -w $(TARGET) -e TERRAFORM_TOKEN $(CONTAINERNAME) terraform apply -target=module.dockerd
	# then run the rest
	docker exec -it -w $(TARGET) -e TERRAFORM_TOKEN $(CONTAINERNAME) terraform apply

show: .terraform
	docker exec -it -w $(TARGET) -e TERRAFORM_TOKEN $(CONTAINERNAME) terraform show

lastpass-login:
	docker exec -it -w $(TARGET) -e TERRAFORM_TOKEN $(CONTAINERNAME) lpass login sven@home.org.au

lastpass-check:
	docker exec -it -w $(TARGET) -e TERRAFORM_TOKEN $(CONTAINERNAME) lpass show --notes 3167287270339421105

destroy:
	docker exec -it -w $(TARGET) -e TERRAFORM_TOKEN $(CONTAINERNAME) terraform destroy

# runing container in the background so we don't have to keep putting in the lastpass 2fa key
# mounting my $HOME in twice so my current path is good, and the terraform user has my ssh config
start:
	docker run --name $(CONTAINERNAME) -dit \
		-u $(shell id -u):$(shell id -g) \
		-v $(HOME):/home/terraform \
		-v $(HOME):$(HOME) \
		-w $(PWD) \
		-e HOME=/home/terraform \
		-e LASTPASS_USER=sven@home.org.au \
		-e LASTPASS_PASSWORD=secret \
		--net=host \
		--entrypoint tail \
		$(TERRAFORMIMAGE):$(TERRAFORMTAG) -f /dev/null

stop:
	docker rm -f $(CONTAINERNAME)