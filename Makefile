
# hashicorp/terraform:light
TERRAFORMIMAGE=follyengine/terraform
CONTAINERNAME=folly-terraform
TERRAFORMTAG=0.14.5

COMPUTER=follybase1

plan:
	echo "SHOW terraform plan"
	docker exec -it $(CONTAINERNAME) terraform plan computers/$(COMPUTER)/

shell:
	docker exec -it $(CONTAINERNAME) bash

build:
	cat Dockerfile | docker build --build-arg TERRAFORMTAG=$(TERRAFORMTAG) -t $(TERRAFORMIMAGE):$(TERRAFORMTAG) -


.terraform:
	docker exec -it $(CONTAINERNAME) terraform init

terraform.tfvars:
	echo
	echo "You need a valid terraform.tfvars file with the lastpass credentials in it"
	echo
	exit 1

init: #terraform.tfvars
	#docker cp $(CONTAINERNAME):/terraform.d .
	docker exec -it $(CONTAINERNAME) terraform login
	docker exec -it $(CONTAINERNAME) terraform init --reconfigure computers/$(COMPUTER)/
	#docker exec -it $(CONTAINERNAME) lpass login --trust $(shell grep lastpass_username terraform.tfvars | cut -f3 -d' ')

cloud-init-key:
	ssh-keygen -q -f ./cloud-init-key -N ""

apply: cloud-init-key .terraform
	# TODO: need to set STACKDOMAIN, and should use it in terraform...
	# Ensure Docker is installed first
	docker exec -it $(CONTAINERNAME) terraform apply -target=module.dockerd computers/follybase1/
	# then run the rest
	docker exec -it $(CONTAINERNAME) terraform apply computers/$(COMPUTER)/

show: .terraform
	docker exec -it $(CONTAINERNAME) terraform show

lastpass-login:
	docker exec -it $(CONTAINERNAME) lpass login sven@home.org.au

lastpass-check:
	docker exec -it $(CONTAINERNAME) lpass show --notes 3167287270339421105

destroy:
	docker exec -it $(CONTAINERNAME) terraform destroy

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