dataloaf-cli:
	@echo "Building DataLoaf CLI..."
	@if [ -f "$$HOME/.bashrc" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.bashrc"; then \
	        echo "Found .bashrc, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.bashrc"; \
	        if [ -x "/bin/bash" ]; then \
	            /bin/bash -c "source $$HOME/.bashrc"; \
	        else \
	            echo "Bash interpreter not found. Please manually source $$HOME/.bashrc."; \
	        fi; \
	    fi; \
	elif [ -f "$$HOME/.bash_profile" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.bash_profile"; then \
	        echo "Found .bash_profile, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.bash_profile"; \
	        if [ -x "/bin/bash" ]; then \
	            /bin/bash -c "source $$HOME/.bash_profile"; \
	        else \
	            echo "Bash interpreter not found. Please manually source $$HOME/.bash_profile."; \
	        fi; \
	    fi; \
	elif [ -f "$$HOME/.bash_login" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.bash_login"; then \
	        echo "Found .bash_login, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.bash_login"; \
	        if [ -x "/bin/bash" ]; then \
	            /bin/bash -c "source $$HOME/.bash_login"; \
	        else \
	            echo "Bash interpreter not found. Please manually source $$HOME/.bash_login."; \
	        fi; \
	    fi; \
	elif [ -f "$$HOME/.profile" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.profile"; then \
	        echo "Found .profile, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.profile"; \
	        if [ -x "/bin/bash" ]; then \
	            /bin/bash -c "source $$HOME/.profile"; \
	        else \
	            echo "Bash interpreter not found. Please manually source $$HOME/.profile."; \
	        fi; \
	    fi; \
	elif [ -f "$$HOME/.zshrc" ]; then \
	    if ! grep -qF "$(pwd)/cli" "$$HOME/.zshrc"; then \
	        echo "Found .zshrc, adding to PATH..."; \
	        echo 'export PATH="$$PATH:'"`pwd`/cli"'"' >> "$$HOME/.zshrc"; \
	        if [ -x "/bin/bash" ]; then \
	            /bin/bash -c "source $$HOME/.zshrc"; \
	        else \
	            echo "Bash interpreter not found. Please manually source $$HOME/.zshrc."; \
	        fi; \
	    fi; \
	else \
	    export PATH="$$PATH:$(pwd)/cli"; \
	fi
	@cd ./cli && go build -o loaf
	@echo "CLI done building, run 'loaf' for available commands"
