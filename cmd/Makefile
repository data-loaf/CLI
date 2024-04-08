dataloaf-cli:
	@echo "Building DataLoaf CLI..."
	@if [ -f "$$HOME/.bashrc" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.bashrc"; then \
	        echo "Found .bashrc, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.bashrc"; \
	    fi; \
	    /bin/bash -c "source $$HOME/.bashrc"; \
	fi
	@if [ -f "$$HOME/.zshrc" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.zshrc"; then \
	        echo "Found .zshrc, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.zshrc"; \
	    fi; \
	    /bin/bash -c "source $$HOME/.zshrc"; \
	fi
	@if ! [ -f "$$HOME/.bashrc" ] && ! [ -f "$$HOME/.zshrc" ]; then \
	    export PATH="$$PATH:$(pwd)/cli"; \
	fi
	@cd ./cli && go build -o loaf
	@echo "CLI done building, run 'loaf' for available commands"

