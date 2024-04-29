dataloaf-cli:
	@echo "Building DataLoaf CLI..."
	@if [ -f "$$HOME/.bashrc" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.bashrc"; then \
	        echo "Found .bashrc, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.bashrc"; \
	    fi; \
	    /bin/bash -c "source $$HOME/.bashrc"; \
	elif [ -f "$$HOME/.bash_profile" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.bash_profile"; then \
	        echo "Found .bash_profile, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.bash_profile"; \
	    fi; \
	    /bin/bash -c "source $$HOME/.bash_profile"; \
	elif [ -f "$$HOME/.bash_login" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.bash_login"; then \
	        echo "Found .bash_login, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.bash_login"; \
	    fi; \
	    /bin/bash -c "source $$HOME/.bash_login"; \
	elif [ -f "$$HOME/.profile" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.profile"; then \
	        echo "Found .profile, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.profile"; \
	    fi; \
	    /bin/bash -c "source $$HOME/.profile"; \
	elif [ -f "$$HOME/.zshrc" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.zshrc"; then \
	        echo "Found .zshrc, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.zshrc"; \
	    fi; \
	    /bin/bash -c "source $$HOME/.zshrc"; \
	else \
	    export PATH="$$PATH:$(pwd)/cli"; \
	fi
	@cd ./cli && go build -o loaf
	@echo "CLI done building, run 'loaf' for available commands"
