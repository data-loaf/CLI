dataloaf-cli:
	@echo "Building DataLoaf CLI..."
	@if [ -f "$$HOME/.bashrc" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.bashrc"; then \
	        echo "Found .bashrc, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.bashrc"; \
	    fi; \
	    /bin/bash -c "source $$HOME/.bashrc"; \
	fi
	@if [ -f "$$HOME/.bash_profile" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.bash_profile"; then \
	        echo "Found .bash_profile, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.bash_profile"; \
	    fi; \
	    /bin/bash -c "source $$HOME/.bash_profile"; \
	fi
	@if [ -f "$$HOME/.bash_login" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.bash_login"; then \
	        echo "Found .bash_login, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.bash_login"; \
	    fi; \
	    /bin/bash -c "source $$HOME/.bash_login"; \
	fi
	@if [ -f "$$HOME/.profile" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.profile"; then \
	        echo "Found .profile, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.profile"; \
	    fi; \
	    /bin/bash -c "source $$HOME/.profile"; \
	fi
	@if [ -f "$$HOME/.zshrc" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.zshrc"; then \
	        echo "Found .zshrc, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.zshrc"; \
	    fi; \
	    /bin/zsh -c "source $$HOME/.zshrc"; \
	fi
	@if ! [ -f "$$HOME/.bashrc" ] && ! [ -f "$$HOME/.bash_profile" ] && ! [ -f "$$HOME/.bash_login" ] && ! [ -f "$$HOME/.profile" ] && ! [ -f "$$HOME/.zshrc" ]; then \
	    export PATH="$$PATH:$(pwd)/cli"; \
	fi
	@cd ./cli && go build -o loaf
	@echo "CLI done building, run 'loaf' for available commands"

