.PHONY: pre-commit

checks:
	@./scripts/checks.sh

.PHONY: clean
clean:
	@echo "Removing local SwiftPM build artifacts..."
	@find Packages -name .build -prune -exec rm -rf {} +
	@echo "Done."
