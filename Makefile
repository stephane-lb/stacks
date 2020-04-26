DOMAIN=localhost

# Copy from https://medium.com/lebouchondigital/passer-des-arguments-%C3%A0-une-target-gnu-make-1ddab618c32f
SUPPORTED_COMMANDS := deploy
SUPPORTS_MAKE_ARGS := $(findstring $(firstword $(MAKECMDGOALS)), $(SUPPORTED_COMMANDS))
ifneq "$(SUPPORTS_MAKE_ARGS)" ""
  COMMAND_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(COMMAND_ARGS):;@:)
endif

.PHONY: start
start:
	@echo "Initialize docker swarm..."
	@docker swarm init > /dev/null 2>&1
	@echo "Deploy traefik reverse-proxy..."
	@docker network create --driver=overlay traefik-net >/dev/null 2>&1
	@DOMAIN=traefik.$(DOMAIN) docker stack deploy -c traefik.yml traefik > /dev/null 2>&1
	@echo "Ready to deploy"

.PHONY: stop
stop:
	@docker swarm leave --force

.PHONY: deploy
deploy:
	@DOMAIN=$(COMMAND_ARGS).$(DOMAIN) docker stack deploy -c $(COMMAND_ARGS).yml my$(COMMAND_ARGS)

.PHONY: kill
kill:
	@docker stack rm my$(COMMAND_ARGS)

.PHONY: install 
install:
	@echo "Executing docker install script..."
	curl -fsSL https://get.docker.com | sh > /dev/null 2>&1
	@echo "Use \"make start\" to launch the swarm"

.PHONY: restart
restart: stop start
 